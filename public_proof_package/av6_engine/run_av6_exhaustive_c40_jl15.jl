#!/usr/bin/env julia
# AX: AV6 | SUM: Bounded enumeration engine C1-C25 Julia group-gate (jl14 + canonical seeding fix: alpha_family decoupled from shell cap, seeds up to maximum budget so cost-28 canonical full form is emitted for budget>=28 evaluation) | SIG: jl15

using Printf
using Random
using Serialization
using SHA
using Base.Threads

# === Paths & Constants ===
const OUT = @__DIR__
const LOG_DIR = joinpath(OUT, "logs")
mkpath(LOG_DIR)
const LOG_PATH = joinpath(LOG_DIR, "run_julia_jl15.log")
const CHECKPOINT = joinpath(OUT, "c14_c25_checkpoint_jl15.jls")
const SPEC_PATH = joinpath(OUT, "spec.json")

const EXPECTED_SPEC_HASH = "eedd88f2d6af37ada448370dfa4d5d562202d00ff8b677dfa8958a56f2630f7c"
const EXPECTED_SPEC_FILE_SHA256 = "d57bf956bcd849c8a0e670e5e876f560f2d6f414da8727c00150ef5d00f56943"
const CANONICAL_G_EXPR = "4/3 * alpha^21 * exp((-5/2)*alpha)"
const TOP_K = 25

# === Config ===
const PER_GROUP_LIMIT = 12
const MANTISSA_BINS = 16
const LOG10_BIN_SCALE = 8
const SOFT_TOTAL_LIMIT = 200_000
const SOFT_TOTAL_GROUP_TRIM = 8
const MAX_GENERAL_SHELL_COST = 16

const POWERS = Dict{Int,Int}(2 => 1, 3 => 2, -1 => 1, -2 => 2, -3 => 3)
const UNARY_OPS = Dict{String,Int}("exp" => 3, "log" => 3)
const BIN_OPS = Dict{String,Int}("add" => 1, "sub" => 1, "mul" => 1, "div" => 1)

const SKIP_IDENTITY_INFLATION = get(ENV, "AV6_SKIP_IDENTITY_INFLATION", "1") == "1"
const AV6_USE_CHEAP_GROUP_GATE = get(ENV, "AV6_USE_CHEAP_GROUP_GATE", "1") == "1"
const AV6_GROUP_GATE_KEEP = parse(Int, get(ENV, "AV6_GROUP_GATE_KEEP", string(PER_GROUP_LIMIT * 4)))

const ALPHA = 1.0 / 137.035999084
const MP_ME = 1836.15267343
const MMU_ME = 206.7682827
const MTAU_ME = 3477.23

# === Logging (thread-safe) ===
const _log_lock = ReentrantLock()
function w(message::String)
    println(message)
    flush(stdout)
    lock(_log_lock) do
        open(LOG_PATH, "a") do io
            write(io, message * "\n")
        end
    end
end

# === Expr struct ===
struct Expr
    form::Any
    text::String
    cost::Int
    value::Float64
    root::String
    exact_cost::Int
    group_key::Tuple{String,Int,Int,String}  # cached bounded_group_key
end

expr_sort_key(e::Expr) = (e.cost, length(e.text), e.text, abs(e.value))
better_expr(a::Expr, b::Expr) = expr_sort_key(a) < expr_sort_key(b)

# === Helpers ===
finite(x::Float64) = isfinite(x) && abs(x) <= 1e300

function bcost(n::Int)
    max(1, ceil(Int, log2(abs(n) + 1)))
end

qcost(p::Int, q::Int) = bcost(p) + bcost(q)

@inline function make_expr(form, text::String, cost::Int, value::Float64, root::String)
    gk = bounded_group_key(value, root)
    Expr(form, text, cost, value, root, cost, gk)
end

# === Canonical forms ===
# Flatten nested mul/add, collect terms, sort, rebuild canonical tuple.
function _flatten_op(tag::String, form)
    items = Any[]
    if form isa Tuple && length(form) >= 1 && form[1] == tag
        for i in 2:length(form)
            push!(items, form[i])
        end
    else
        push!(items, form)
    end
    items
end

function _canon_op(tag::String, a, b)
    items = vcat(_flatten_op(tag, a), _flatten_op(tag, b))
    sort!(items, by=hash)
    (tag, items...)
end

canon_mul(a, b) = _canon_op("mul", a, b)
canon_add(a, b) = _canon_op("add", a, b)

# === Expression constructors ===
function try_pow(expr::Expr, k::Int)
    if expr.value == 0.0 && k < 0
        return nothing
    end
    if expr.value < 0.0 && !(k in (-3, -2, -1, 2, 3))
        return nothing
    end
    value = expr.value^k
    !finite(value) && return nothing
    if expr.form isa Tuple && length(expr.form) >= 2 && expr.form[1] == "pow"
        base, prior_k = expr.form[2], expr.form[3]
        next_k = prior_k * k
        if haskey(POWERS, next_k)
            return make_expr(("pow", base, next_k), "($(expr.text))^$k",
                             expr.cost + POWERS[k], value, "pow")
        end
    end
    make_expr(("pow", expr.form, k), "($(expr.text))^$k",
              expr.cost + POWERS[k], value, "pow")
end

function try_unary(op::String, expr::Expr)
    if op == "log"
        expr.value <= 0.0 && return nothing
        value = log(expr.value)
        !finite(value) && return nothing
        # jl13: disabled log(exp(x))→x simplification — it returned correct value
        # but kept the outer text "exp(x)" instead of reconstructing inner text.
        # The cost reduction (no extra cost) was also suspicious.
        return make_expr(("log", expr.form), "log($(expr.text))",
                         expr.cost + UNARY_OPS[op], value, "log")
    end
    if op == "exp"
        if expr.value < -50.0 || expr.value > 50.0
            return nothing
        end
        value = exp(expr.value)
        !finite(value) && return nothing
        # jl13: disabled exp(log(x))→x simplification — same text mismatch bug.
        return make_expr(("exp", expr.form), "exp($(expr.text))",
                         expr.cost + UNARY_OPS[op], value, "exp")
    end
    nothing
end

function try_bin(op::String, left::Expr, right::Expr)
    if op == "mul"
        left.value == 1.0 && return make_expr(right.form, right.text, left.cost + right.cost + 1, right.value, "mul_id")
        right.value == 1.0 && return make_expr(left.form, left.text, left.cost + right.cost + 1, left.value, "mul_id")
        value = left.value * right.value
        !finite(value) && return nothing
        form = canon_mul(left.form, right.form)
        t1, t2 = left.text, right.text
        text = t1 < t2 ? "$t1 * $t2" : "$t2 * $t1"
        return make_expr(form, text, left.cost + right.cost + 1, value, "mul")
    end
    if op == "div"
        right.value == 0.0 && return nothing
        value = left.value / right.value
        !finite(value) && return nothing
        return make_expr(("div", left.form, right.form), "($(left.text))/($(right.text))",
                         left.cost + right.cost + 1, value, "div")
    end
    if op == "add"
        value = left.value + right.value
        !finite(value) && return nothing
        form = canon_add(left.form, right.form)
        t1, t2 = left.text, right.text
        text = t1 < t2 ? "$t1 + $t2" : "$t2 + $t1"
        return make_expr(form, text, left.cost + right.cost + 1, value, "add")
    end
    if op == "sub"
        value = left.value - right.value
        !finite(value) && return nothing
        return make_expr(("sub", left.form, right.form), "($(left.text))-($(right.text))",
                         left.cost + right.cost + 1, value, "sub")
    end
    nothing
end

# === Cheap validity check (no allocation, inline) ===
@inline function _cheap_bin_valid_value(op::String, lv::Float64, rv::Float64)::Float64
    if op == "mul"
        if SKIP_IDENTITY_INFLATION && (lv == 1.0 || rv == 1.0)
            return NaN
        end
        return lv * rv
    elseif op == "div"
        if rv == 0.0 || (SKIP_IDENTITY_INFLATION && rv == 1.0)
            return NaN
        end
        return lv / rv
    elseif op == "add"
        if SKIP_IDENTITY_INFLATION && (lv == 0.0 || rv == 0.0)
            return NaN
        end
        return lv + rv
    elseif op == "sub"
        if SKIP_IDENTITY_INFLATION && rv == 0.0
            return NaN
        end
        return lv - rv
    end
    return NaN
end

# === Group-gate cheap candidate struct ===
struct CheapCand
    lc::Int16
    rc::Int16
    li::Int32
    ri::Int32
    text_len::Int32
    abs_value::Float64
end

const CheapGroupKey = Tuple{String,Int,Int,String}

@inline function _cheap_better(a::CheapCand, b::CheapCand)::Bool
    if a.text_len != b.text_len
        return a.text_len < b.text_len
    end
    return a.abs_value < b.abs_value
end

function _push_cheap!(d::Dict{CheapGroupKey,Vector{CheapCand}}, key::CheapGroupKey, cand::CheapCand, keep::Int)
    vec = get!(Vector{CheapCand}, d, key)
    if length(vec) < keep
        push!(vec, cand)
        return
    end
    worst_i = 1
    worst = vec[1]
    @inbounds for i in 2:length(vec)
        vi = vec[i]
        if _cheap_better(worst, vi)
            worst_i = i
            worst = vi
        end
    end
    if _cheap_better(cand, worst)
        vec[worst_i] = cand
    end
end

# === Base atoms ===
function base_atoms()
    atoms = Expr[]
    for p in 1:5, q in 1:5
        value = p / q
        if 0.2 <= value <= 5.0
            text = q == 1 ? string(p) : "$p/$q"
            push!(atoms, make_expr(("rat", p, q), text, qcost(p, q), value, "rat"))
        end
    end
    push!(atoms, make_expr(("const", "pi"), "pi", 3, Float64(pi), "const"))
    push!(atoms, make_expr(("const", "e"), "e", 3, Float64(ℯ), "const"))
    push!(atoms, make_expr(("const", "alpha"), "alpha", 4, ALPHA, "const"))
    push!(atoms, make_expr(("const", "mp_me"), "mp/me", 8, MP_ME, "mass_ratio"))
    push!(atoms, make_expr(("const", "mmu_me"), "mmu/me", 8, MMU_ME, "mass_ratio"))
    push!(atoms, make_expr(("const", "mtau_me"), "mtau/me", 8, MTAU_ME, "mass_ratio"))
    # Dedup by form
    seen = Dict{Any,Expr}()
    for a in atoms
        get!(seen, a.form, a)
    end
    collect(values(seen))
end

function base_atoms_by_cost()
    grouped = Dict{Int,Vector{Expr}}()
    for e in base_atoms()
        vec = get!(() -> Expr[], grouped, e.cost)
        push!(vec, e)
    end
    grouped
end

# === Alpha family ===
function alpha_family(max_cost::Int)
    rationals = [(p, q) for p in 1:5 for q in 1:5 if 0.2 <= p/q <= 5.0]
    cs = [-5.0, -4.0, -3.0, -2.5, -2.0, -1.5, -1.0, -0.5, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]
    out = Expr[]
    for (p, q) in rationals
        prefactor = p / q
        pref_cost = qcost(p, q)
        for n in 1:40
            base_value = prefactor * (ALPHA^n)
            text = q == 1 ? "$p * alpha^$n" : "$p/$q * alpha^$n"
            plain = make_expr(("fam", p, q, n, nothing), text,
                              pref_cost + 4 + bcost(n) + 1, base_value, "alpha_family")
            plain.cost <= max_cost && push!(out, plain)
            for c in cs
                value = base_value * exp(c * ALPHA)
                !finite(value) && continue
                if isinteger(c)
                    cp, cq = abs(Int(c)), 1
                else
                    cp, cq = abs(Int(round(c * 2))), 2
                end
                c_text = c < 0 ? (cq == 1 ? "-$cp" : "-$cp/$cq") : (cq == 1 ? "$cp" : "$cp/$cq")
                text = q == 1 ? "$p * alpha^$n * exp(($c_text)*alpha)" :
                                "$p/$q * alpha^$n * exp(($c_text)*alpha)"
                expr = make_expr(("fam", p, q, n, c), text,
                                 pref_cost + 4 + bcost(n) + 3 + 4 + qcost(cp, cq) + 2,
                                 value, "alpha_exp_family")
                expr.cost <= max_cost && push!(out, expr)
            end
        end
    end
    unique = Dict{Any,Expr}()
    for e in out
        old = get(unique, e.form, nothing)
        if old === nothing || better_expr(e, old)
            unique[e.form] = e
        end
    end
    collect(values(unique))
end

# === Bounded Frontier ===
@inline @fastmath function bounded_group_key(value::Float64, root::String)
    value == 0.0 && return ("z", 0, 0, root)
    magnitude = abs(value)
    log10_mag = log10(magnitude)
    exponent = floor(Int, log10_mag)
    mantissa = 10.0^(log10_mag - exponent)
    sgn = value > 0.0 ? "p" : "n"
    exponent_bin = floor(Int, log10_mag * LOG10_BIN_SCALE)
    mantissa_bin = max(0, min(MANTISSA_BINS - 1,
                              floor(Int, (mantissa - 1.0) / 9.0 * MANTISSA_BINS)))
    (sgn, exponent_bin, mantissa_bin, root)
end

# GroupKey = Tuple{String, Int, Int, String} — concrete, efficient Dict key.
# Inner key = Any (the form tuple) — heterogeneous by nature, only used for dedup.

mutable struct BoundedFrontier
    by_group::Dict{Tuple{String,Int,Int,String}, Dict{Any, Expr}}
    total::Int
end

BoundedFrontier() = BoundedFrontier(Dict{Tuple{String,Int,Int,String}, Dict{Any,Expr}}(), 0)

function _trim_group!(bf::BoundedFrontier, key, keep_limit::Int)
    group = get(bf.by_group, key, nothing)
    (group === nothing || isempty(group)) && return
    sorted = sort!(collect(values(group)),
                   by=e -> (length(e.text), abs(e.value), e.text))
    keep = sorted[1:min(keep_limit, length(sorted))]
    new_group = Dict{Any,Expr}(e.form => e for e in keep)
    bf.total += length(new_group) - length(group)
    bf.by_group[key] = new_group
end

function _soft_trim!(bf::BoundedFrontier)
    for (key, group) in bf.by_group
        length(group) > SOFT_TOTAL_GROUP_TRIM || continue
        _trim_group!(bf, key, SOFT_TOTAL_GROUP_TRIM)
    end
end

@inline function offer!(bf::BoundedFrontier, expr::Expr)
    key = expr.group_key
    group = get!(Dict{Any,Expr}, bf.by_group, key)
    prev = get(group, expr.form, nothing)
    if prev === nothing
        group[expr.form] = expr
        bf.total += 1
    elseif better_expr(expr, prev)
        group[expr.form] = expr
    end
    if length(group) > PER_GROUP_LIMIT * 2
        _trim_group!(bf, key, PER_GROUP_LIMIT)
    end
    if bf.total > SOFT_TOTAL_LIMIT
        _soft_trim!(bf)
    end
end

function frontier_values(bf::BoundedFrontier)
    out = Expr[]
    for group in values(bf.by_group)
        append!(out, values(group))
    end
    sort!(out, by=expr_sort_key)
end

function merge_frontier!(main::BoundedFrontier, other::BoundedFrontier)
    for (key, other_group) in other.by_group
        main_group = get!(Dict{Any,Expr}, main.by_group, key)
        for (form, expr) in other_group
            prev = get(main_group, form, nothing)
            if prev === nothing
                main_group[form] = expr
                main.total += 1
            elseif better_expr(expr, prev)
                main_group[form] = expr
            end
        end
        if length(main_group) > PER_GROUP_LIMIT * 2
            _trim_group!(main, key, PER_GROUP_LIMIT)
        end
    end
    if main.total > SOFT_TOTAL_LIMIT
        _soft_trim!(main)
    end
end

# Fast merge without global soft-trim — defers _soft_trim! to batch end
function merge_frontier_fast!(main::BoundedFrontier, other::BoundedFrontier)
    for (key, other_group) in other.by_group
        main_group = get!(Dict{Any,Expr}, main.by_group, key)
        for (form, expr) in other_group
            prev = get(main_group, form, nothing)
            if prev === nothing
                main_group[form] = expr
                main.total += 1
            elseif better_expr(expr, prev)
                main_group[form] = expr
            end
        end
        if length(main_group) > PER_GROUP_LIMIT * 2
            _trim_group!(main, key, PER_GROUP_LIMIT)
        end
    end
end

# Parallel merge: split thread frontiers into groups, merge each in parallel
function parallel_merge_frontiers!(main::BoundedFrontier, frontiers::Vector{BoundedFrontier})
    n = length(frontiers)
    if n <= 3
        for tf in frontiers
            merge_frontier_fast!(main, tf)
        end
        main.total > SOFT_TOTAL_LIMIT && _soft_trim!(main)
        return
    end
    n_merge = min(nthreads(), 8)
    chunk_size = cld(n, n_merge)
    partials = [BoundedFrontier() for _ in 1:n_merge]
    Threads.@threads :static for gi in 1:n_merge
        start_idx = (gi - 1) * chunk_size + 1
        end_idx = min(gi * chunk_size, n)
        start_idx > n && continue
        for i in start_idx:end_idx
            merge_frontier_fast!(partials[gi], frontiers[i])
        end
    end
    for p in partials
        merge_frontier_fast!(main, p)
    end
    main.total > SOFT_TOTAL_LIMIT && _soft_trim!(main)
end

# === Dedup ===
function dedup_exprs(exprs::Vector{Expr})
    unique = Dict{Any,Expr}()
    for e in exprs
        old = get(unique, e.form, nothing)
        if old === nothing || better_expr(e, old)
            unique[e.form] = e
        end
    end
    sort!(collect(values(unique)), by=expr_sort_key)
end

# === Target pack ===
function target_pack()
    hbar = 1.054571817e-34
    speed_of_light = 299792458.0
    electron_mass = 9.1093837139e-31
    newton_g = 6.67430e-11
    alpha_ge = newton_g * electron_mass * electron_mass / (hbar * speed_of_light)
    lam = 1.08891e-52 * (hbar / (electron_mass * speed_of_light))^2
    Dict{String,Float64}(
        "g_decode_alpha_ge" => alpha_ge,
        "lambda_e2_over_mec2" => lam,
        "sin2_theta_w" => 0.23121,
        "sin_theta_c" => 0.225,
        "mw_over_mz" => 0.88153,
    )
end

function sham_targets(base::Float64; seed::Int=20260429, count::Int=256)
    rng = MersenneTwister(seed)
    out = Float64[]
    for _ in 1:count
        log10_value = log10(base) + rand(rng) * 2.0 - 1.0
        push!(out, 10.0^log10_value)
    end
    out
end

# === Build budget views ===
function build_budget_views(exprs::Vector{Expr}, budgets::Vector{Int})
    positives = sort!([e for e in exprs if e.value > 0.0], by=e -> e.value)
    views = Dict{Int,Dict}()
    for budget in budgets
        eligible = [e for e in positives if e.cost <= budget]
        views[budget] = Dict(
            "exprs" => eligible,
            "values" => [e.value for e in eligible],
        )
    end
    views
end

function nearest_top_k(eligible_exprs, eligible_values, target_value::Float64, k::Int)
    isempty(eligible_exprs) && return []
    idx = searchsortedfirst(eligible_values, target_value)
    left, right = idx - 1, idx
    picked = Tuple{Float64,Expr}[]
    used = Set{Any}()
    n = length(eligible_exprs)
    while length(picked) < k && (left >= 1 || right <= n)
        choose_left = false
        if left >= 1 && right <= n
            choose_left = abs(eligible_values[left] - target_value) <=
                          abs(eligible_values[right] - target_value)
        elseif left >= 1
            choose_left = true
        end
        local expr::Expr
        if choose_left
            expr = eligible_exprs[left]; left -= 1
        else
            expr = eligible_exprs[right]; right += 1
        end
        expr.form in used && continue
        push!(used, expr.form)
        rel = abs(expr.value - target_value) / target_value
        push!(picked, (rel, expr))
    end
    sort!(picked, by=item -> (item[1], item[2].cost, length(item[2].text), item[2].text))
    picked[1:min(k, length(picked))]
end

function sibling_or_trash(expr::Expr)
    text = expr.text
    text == CANONICAL_G_EXPR && return "CANONICAL_G"
    expr.root == "alpha_exp_family" && occursin("alpha^21", text) && occursin("4/3", text) &&
        return "SIBLING_LOCAL_DEFORMATION"
    expr.root == "alpha_family" && occursin("alpha^21", text) &&
        return "SIBLING_PRE_EXP_TRUNCATION"
    occursin("alpha^21", text) && return "SIBLING_SHARED_ALPHA21"
    expr.root in ("alpha_family", "alpha_exp_family") && return "SIBLING_ALPHA_FAMILY_OTHER"
    "TRASH_BROAD_GRAMMAR"
end

# === Evaluation ===
function evaluate_targets(exprs::Vector{Expr}, targets::Dict{String,Float64}, budgets::Vector{Int})
    views = build_budget_views(exprs, budgets)
    target_rows = Vector{Dict}()
    target_curves = Dict{String,Dict}()
    g_best = Dict{Int,Float64}()

    for (target_name, target_value) in targets
        target_curves[target_name] = Dict{String,Dict}()
        for budget in budgets
            eligible_exprs = views[budget]["exprs"]
            eligible_values = views[budget]["values"]
            nearest = nearest_top_k(eligible_exprs, eligible_values, target_value, TOP_K)

            top_rows = Dict[]
            for (rank, (rel, expr)) in enumerate(nearest)
                row = Dict{String,Any}(
                    "budget" => budget, "target" => target_name, "rank" => rank,
                    "expr" => expr.text, "value" => expr.value, "cost" => expr.cost,
                    "rel_err" => rel, "family" => expr.root,
                    "sibling_or_trash" => sibling_or_trash(expr),
                )
                push!(target_rows, row)
                push!(top_rows, row)
            end

            best_row = isempty(top_rows) ? nothing : top_rows[1]
            curve_entry = Dict{String,Any}(
                "best_rel_err" => (best_row !== nothing ? best_row["rel_err"] : nothing),
                "best_expr" => (best_row !== nothing ? best_row["expr"] : nothing),
                "best_value" => (best_row !== nothing ? best_row["value"] : nothing),
                "best_cost" => (best_row !== nothing ? best_row["cost"] : nothing),
                "family" => (best_row !== nothing ? best_row["family"] : nothing),
                "sibling_or_trash" => (best_row !== nothing ? best_row["sibling_or_trash"] : nothing),
                "top_k" => top_rows,
            )
            target_curves[target_name][string(budget)] = curve_entry

            if target_name == "g_decode_alpha_ge" && best_row !== nothing
                g_best[budget] = best_row["rel_err"]
            end
        end
    end
    target_curves, target_rows, g_best
end

function evaluate_shams(exprs::Vector{Expr}, budgets::Vector{Int}, base_target::Float64, g_best::Dict)
    shams = sham_targets(base_target)
    views = build_budget_views(exprs, budgets)
    ledger = Vector{Dict}()
    summary = Dict{String,Any}(
        "seed" => 20260429, "count" => length(shams),
        "window_log10_pm" => 1.0, "budgets" => Dict{String,Dict}(),
    )

    for budget in budgets
        rels = Float64[]
        for (sham_index, sham_value) in enumerate(shams)
            eligible_exprs = views[budget]["exprs"]
            eligible_values = views[budget]["values"]
            nearest = nearest_top_k(eligible_exprs, eligible_values, sham_value, 1)
            isempty(nearest) && continue
            rel, expr = nearest[1]
            push!(rels, rel)
            push!(ledger, Dict{String,Any}(
                "budget" => budget, "sham_index" => sham_index, "sham_value" => sham_value,
                "best_expr" => expr.text, "best_value" => expr.value, "best_cost" => expr.cost,
                "rel_err" => rel, "family" => expr.root,
                "sibling_or_trash" => sibling_or_trash(expr),
                "matches_or_beats_g" => rel <= get(g_best, budget, Inf),
            ))
        end
        sort!(rels)
        n = length(rels)
        budget_key = string(budget)
        summary["budgets"][budget_key] = Dict{String,Any}(
            "min" => rels[1],
            "p10" => rels[max(1, floor(Int, 0.1 * (n - 1)) + 1)],
            "median" => n % 2 == 1 ? rels[(n+1)÷2] : (rels[n÷2] + rels[n÷2+1]) / 2,
            "p90" => rels[max(1, floor(Int, 0.9 * (n - 1)) + 1)],
            "max" => rels[end],
            "count_match_or_beat_g" => count(r -> r <= get(g_best, budget, Inf), rels),
        )
    end
    summary, ledger
end

# === CSV write ===
function write_csv(path::String, rows::Vector, fieldnames::Vector{String})
    open(path, "w") do io
        write(io, join(fieldnames, ",") * "\n")
        for row in rows
            vals = String[]
            for fn in fieldnames
                v = get(row, fn, "")
                push!(vals, something(string(v), ""))
            end
            write(io, join(vals, ",") * "\n")
        end
    end
end

# === Enumerate one cost level (multi-threaded binary ops) ===
function enumerate_cost!(by_cost::Dict{Int,Vector{Expr}}, cost::Int, grouped_atoms::Dict)
    frontier = BoundedFrontier()
    raw_gen = Threads.Atomic{Int}(0)
    total_pool = sum(length(v) for v in values(by_cost); init=0)
    w("cost=$cost starting... pool=$total_pool")

    # Atoms at this cost
    for expr in get(grouped_atoms, cost, Expr[])
        Threads.atomic_add!(raw_gen, 1)
        offer!(frontier, expr)
    end

    # Unary ops (parallel — each expression independent, local counters jl13)
    for (op, op_cost) in UNARY_OPS
        src = cost - op_cost
        (src <= 0 || !haskey(by_cost, src)) && continue
        exprs = by_cost[src]
        n_u = length(exprs)
        n_u == 0 && continue
        n_th_u = min(nthreads(), n_u)
        u_chunk_size = max(1, cld(n_u, n_th_u))
        u_frontiers = [BoundedFrontier() for _ in 1:n_th_u]
        u_counts = zeros(Int, n_th_u)
        Threads.@threads :static for ci in 1:n_th_u
            tf = u_frontiers[ci]
            local_count = 0
            start_idx = (ci - 1) * u_chunk_size + 1
            end_idx = min(ci * u_chunk_size, n_u)
            for i in start_idx:end_idx
                candidate = try_unary(op, exprs[i])
                if candidate !== nothing && candidate.cost == cost
                    local_count += 1
                    offer!(tf, candidate)
                end
            end
            u_counts[ci] = local_count
        end
        Threads.atomic_add!(raw_gen, sum(u_counts))
        for tf in u_frontiers; merge_frontier_fast!(frontier, tf); end
    end

    # Powers (parallel — each expression independent, local counters jl13)
    for (k, k_cost) in POWERS
        src = cost - k_cost
        (src <= 0 || !haskey(by_cost, src)) && continue
        exprs = by_cost[src]
        n_p = length(exprs)
        n_p == 0 && continue
        n_th_p = min(nthreads(), n_p)
        p_chunk_size = max(1, cld(n_p, n_th_p))
        p_frontiers = [BoundedFrontier() for _ in 1:n_th_p]
        p_counts = zeros(Int, n_th_p)
        Threads.@threads :static for ci in 1:n_th_p
            tf = p_frontiers[ci]
            local_count = 0
            start_idx = (ci - 1) * p_chunk_size + 1
            end_idx = min(ci * p_chunk_size, n_p)
            for i in start_idx:end_idx
                candidate = try_pow(exprs[i], k)
                if candidate !== nothing && candidate.cost == cost
                    local_count += 1
                    offer!(tf, candidate)
                end
            end
            p_counts[ci] = local_count
        end
        Threads.atomic_add!(raw_gen, sum(p_counts))
        for tf in p_frontiers; merge_frontier_fast!(frontier, tf); end
    end

    # Binary ops — group-gate (jl14): two-pass cheap numeric pre-filter per bounded group
    for (op, op_cost) in BIN_OPS
        pair_list = Tuple{Int,Int}[]
        for lc in 1:(cost-1)
            rc = cost - op_cost - lc
            rc < 1 && continue
            (op in ("mul", "add") && lc > rc) && continue
            haskey(by_cost, lc) && haskey(by_cost, rc) && push!(pair_list, (lc, rc))
        end
        isempty(pair_list) && continue

        work_items = Tuple{Int,Int,Int}[]
        for (lc, rc) in pair_list
            lefts = by_cost[lc]
            sizehint!(work_items, length(work_items) + length(lefts))
            for li in eachindex(lefts)
                push!(work_items, (lc, rc, li))
            end
        end

        n_work = length(work_items)
        n_th = min(nthreads(), max(1, n_work))
        n_work > 1000 && w("  bin_op=$op n_work=$n_work n_th=$n_th gate=$(AV6_USE_CHEAP_GROUP_GATE) keep=$(AV6_GROUP_GATE_KEEP)")
        chunk_size = max(1, cld(n_work, n_th))
        thread_frontiers = [BoundedFrontier() for _ in 1:n_th]
        bin_counts = zeros(Int, n_th)
        gate_counts = zeros(Int, n_th)
        chunks = [chunk_start:min(chunk_start + chunk_size - 1, n_work)
                  for chunk_start in 1:chunk_size:n_work]

        Threads.@threads :static for ci in 1:length(chunks)
            tf = thread_frontiers[ci]
            local_raw = 0

            if AV6_USE_CHEAP_GROUP_GATE
                gate = Dict{CheapGroupKey,Vector{CheapCand}}()

                # Pass 1: numeric-only bounded candidate gate.
                for idx in chunks[ci]
                    lc, rc, li = work_items[idx]
                    lefts = by_cost[lc]
                    rights = by_cost[rc]
                    left = lefts[li]
                    lv = left.value
                    start_ri = (op in ("mul", "add") && lc == rc) ? li : firstindex(rights)
                    @inbounds for ri in start_ri:lastindex(rights)
                        right = rights[ri]
                        value = _cheap_bin_valid_value(op, lv, right.value)
                        finite(value) || continue
                        local_raw += 1
                        gk = bounded_group_key(value, op)
                        tlen = length(left.text) + length(right.text) + 5
                        cc = CheapCand(Int16(lc), Int16(rc), Int32(li), Int32(ri), Int32(tlen), abs(value))
                        _push_cheap!(gate, gk, cc, AV6_GROUP_GATE_KEEP)
                    end
                end

                # Pass 2: materialize only candidates kept by the cheap gate.
                local_gate_count = 0
                for vec in values(gate)
                    for cc in vec
                        left = by_cost[Int(cc.lc)][Int(cc.li)]
                        right = by_cost[Int(cc.rc)][Int(cc.ri)]
                        candidate = try_bin(op, left, right)
                        if candidate !== nothing && candidate.cost == cost
                            local_gate_count += 1
                            offer!(tf, candidate)
                        end
                    end
                end
                gate_counts[ci] = local_gate_count
            else
                for idx in chunks[ci]
                    lc, rc, li = work_items[idx]
                    lefts = by_cost[lc]
                    rights = by_cost[rc]
                    left = lefts[li]
                    start_ri = (op in ("mul", "add") && lc == rc) ? li : firstindex(rights)
                    @inbounds for ri in start_ri:lastindex(rights)
                        right = rights[ri]
                        value = _cheap_bin_valid_value(op, left.value, right.value)
                        finite(value) || continue
                        local_raw += 1
                        candidate = try_bin(op, left, right)
                        if candidate !== nothing && candidate.cost == cost
                            offer!(tf, candidate)
                        end
                    end
                end
                gate_counts[ci] = local_raw
            end

            bin_counts[ci] = local_raw
        end

        Threads.atomic_add!(raw_gen, sum(bin_counts))
        w("  bin_op=$op raw_valid=$(sum(bin_counts)) materialized=$(sum(gate_counts))")
        parallel_merge_frontiers!(frontier, thread_frontiers)
    end

    shell = frontier_values(frontier)
    by_cost[cost] = shell
    raw_gen[], shell
end

# === Main ===
function main()
    mkpath(OUT)
    w("=== Julia AV6 Bounded Enumeration C1-C$MAX_GENERAL_SHELL_COST ===")
    w("Threads: $(nthreads()) | Julia $(VERSION)")

    budgets = [20, 30, 40]

    grouped_atoms = base_atoms_by_cost()
    by_cost = Dict{Int,Vector{Expr}}()
    stats = Vector{Dict}()
    start_cost = 1
    growth_factors = Dict{Int,Float64}()

    # Try resume from Julia checkpoint
    if isfile(CHECKPOINT)
        try
            saved = deserialize(CHECKPOINT)
            by_cost = saved["by_cost"]
            stats = saved["stats"]
            start_cost = saved["next_cost"]
            growth_factors = get(saved, "growth_factors", Dict{Int,Float64}())
            pool_size = sum(length(v) for v in values(by_cost); init=0)
            w("Resumed from checkpoint at cost=$start_cost, pool_size=$pool_size")
        catch e
            w("Checkpoint load failed: $e, starting fresh from C1")
            start_cost = 1
        end
    end

    append_stats = Vector{Dict}()
    for cost in start_cost:MAX_GENERAL_SHELL_COST
        t0 = time()
        raw_gen, shell = enumerate_cost!(by_cost, cost, grouped_atoms)
        elapsed = time() - t0

        prev_kept = (!isempty(stats) && stats[end]["kept"] > 0) ? stats[end]["kept"] :
                    (!isempty(append_stats) && append_stats[end]["kept"] > 0) ? append_stats[end]["kept"] : nothing
        growth = (prev_kept !== nothing && prev_kept > 0) ? length(shell) / prev_kept : nothing

        entry = Dict{String,Any}(
            "cost" => cost, "raw_generated" => raw_gen, "canonical_unique" => length(shell),
            "kept" => length(shell), "status" => "bounded_shell",
            "elapsed_sec" => round(elapsed, digits=1),
            "growth_factor" => growth !== nothing ? round(growth, digits=4) : nothing,
        )
        push!(append_stats, entry)

        pool_size = sum(length(v) for v in values(by_cost); init=0)
        gs = growth !== nothing ? @sprintf("%.4f", growth) : "None"
        w("bounded cost=$cost offered=$raw_gen kept=$(length(shell)) growth=$gs")
        w("  elapsed=$(round(elapsed, digits=1))s pool_size=$pool_size")

        growth !== nothing && (growth_factors[cost] = growth)

        # Checkpoint after each level
        serialize(CHECKPOINT, Dict(
            "by_cost" => by_cost,
            "stats" => vcat(stats, append_stats),
            "next_cost" => cost + 1,
            "growth_factors" => growth_factors,
        ))
        w("  checkpoint saved for cost=$cost")
    end

    all_stats = vcat(stats, append_stats)

    # Build final expression list.
    # FIX (jl15): alpha_family seed is decoupled from shell cap. Previously seeded at
    # MAX_GENERAL_SHELL_COST which silently dropped any canonical-family entry whose
    # alpha_family-formula cost exceeded the brute-force enumeration cap. The G-DECODE
    # canonical 4/3 * alpha^21 * exp((-5/2)*alpha) has alpha_family cost 28 and was
    # therefore absent from every C18 ledger even though budgets [30,40] could see it.
    # Seeding up to maximum(budgets) emits all family entries an evaluation budget can
    # legitimately reach. Each seed carries its true alpha_family cost so the budget
    # filter in build_budget_views remains honest.
    w("Building final expression list...")
    exprs = Expr[]
    for c in 1:MAX_GENERAL_SHELL_COST
        append!(exprs, get(by_cost, c, Expr[]))
    end
    final_seed_cap = maximum(budgets)
    af_seeds = alpha_family(final_seed_cap)
    w("alpha_family seeded: count=$(length(af_seeds)) cap=$final_seed_cap (was MAX_GENERAL_SHELL_COST=$MAX_GENERAL_SHELL_COST in jl14)")
    append!(exprs, af_seeds)
    exprs = dedup_exprs(exprs)
    w("Total expressions: $(length(exprs))")
    canonical_present = any(e -> e.text == CANONICAL_G_EXPR, exprs)
    w("CANONICAL_G_EXPR present in final expression list: $canonical_present")

    # Write stats CSV
    w("Writing stats...")
    write_csv(
        joinpath(OUT, "c14_c25_bounded_shell_stats.csv"),
        all_stats,
        ["cost", "raw_generated", "canonical_unique", "kept", "status", "elapsed_sec", "growth_factor"],
    )

    # Target evaluation
    w("Running target evaluation...")
    targets = target_pack()
    target_curves, target_rows, g_best = evaluate_targets(exprs, targets, budgets)
    sham_summary, sham_ledger = evaluate_shams(exprs, budgets, targets["g_decode_alpha_ge"], g_best)

    # Write CSVs
    write_csv(
        joinpath(OUT, "c14_c25_same_target_rank_tables.csv"),
        target_rows,
        ["budget", "target", "rank", "expr", "value", "cost", "rel_err", "family", "sibling_or_trash"],
    )
    write_csv(
        joinpath(OUT, "c14_c25_sham_best_ledger.csv"),
        sham_ledger,
        ["budget", "sham_index", "sham_value", "best_expr", "best_value", "best_cost",
         "rel_err", "family", "sibling_or_trash", "matches_or_beats_g"],
    )

    # Growth summary
    w("\n=== GROWTH FACTOR SUMMARY ===")
    for c in sort(collect(keys(growth_factors)))
        w("  C$(c-1)->C$c: $(growth_factors[c])x")
    end

    # Final summary
    w("\n=== FINAL SUMMARY ===")
    done_costs = [s["cost"] for s in all_stats if s["kept"] > 0]
    w("Highest cost completed: $(maximum(done_costs))")
    g40_rel = haskey(target_curves, "g_decode_alpha_ge") &&
              haskey(target_curves["g_decode_alpha_ge"], "40") ?
              target_curves["g_decode_alpha_ge"]["40"]["best_rel_err"] : "N/A"
    sham40 = haskey(sham_summary["budgets"], "40") ?
             sham_summary["budgets"]["40"]["count_match_or_beat_g"] : "N/A"
    w("g40_rel=$g40_rel sham40_match_or_beat=$sham40")
    w("done")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
