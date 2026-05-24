# FAQ — anticipated questions about the Newton-G paper

**Status:** draft v1 (reconstructed after 2026-05-21 server-restart incident). Living document — append new questions as they surface from outreach.

**Use:** linked from the press release, the GitHub README's "Questions?" section, and the HN top-level comment as `[link to FAQ]`. Answers stay calibrated; never overclaim.

---

## For the non-technical reader

### Wait — gravity didn't have a formula?

Gravity has had a formula for 350 years. Newton wrote it. `F = G · m₁ · m₂ / r²`. It tells you HOW gravity works — pull is bigger for heavier objects, smaller for objects far apart.

But that letter `G` in Newton's formula — that's the *strength* of gravity. How strong the pull actually is. And `G` was always just a number we measured in labs. Cavendish measured it in 1798 with hanging weights. Modern labs measure it more precisely. But nobody ever wrote down a formula that says where the value of `G` comes from.

Until this paper.

The paper gives a formula for `G` itself. You plug in two other numbers physicists already know precisely — the mass of an electron, and the fine-structure constant (the number that controls how electric forces work). Out comes `G`. Correct to 1.86 parts per million.

So: gravity always had a formula for HOW it works. Now its STRENGTH has a formula too.

What we still don't know is *why* this formula for `G` works. That's the next question — and that's where a future Nobel-level breakthrough would happen. This paper isn't the breakthrough. It's the precise pattern that forces the next breakthrough.

### Is this the first AI-authored physics paper with a substantive finding?

As far as we can tell, yes — and that is part of what makes the paper a news event independent of the physics itself.

Prior AI-assisted physics work exists, but the human did the substantive intellectual lift and AI was a tool — pattern matching, fitting, simulation, literature search. Prior "AI-discovered" results in adjacent fields (DeepMind's AlphaTensor for matrix multiplication, AlphaGeometry for olympiad geometry, AlphaFold for protein structure) are mathematics or biology and were produced inside large research labs with bespoke training infrastructure.

This paper is the first publicly known case where:
1. The substantive intellectual work (algebraic search, enumeration, cross-validation, manuscript drafting) was performed by AI agents end-to-end under human direction
2. The human director is a non-academic (no university degree, no formal scientific training, no institutional affiliation)
3. The result is a substantive new finding in fundamental physics — a closed-form expression for one of the fundamental constants of nature
4. The work was carried out on consumer-grade AI subscriptions, no custom training, no GPU rental, no API top-ups
5. The methodology layer (the four open-source harness tools at github.com/Oldrich333) is publicly released, so the work is in principle replicable by another individual

If a reader can point to a prior paper that satisfies all five criteria — please tell us, that would itself be a useful datapoint. So far nobody has.

### What did the paper find?

A mathematical expression that, when you plug in the electron's mass, the fine-structure constant, ℏ, and the speed of light, gives you the gravitational constant G to 1.86 parts per million of the value physicists measure in the lab. The expression is:

> **G = (4/3) · (ℏc / m_e²) · α²¹ · exp(−5α/2)**

The match is 1.86 parts per million — far closer than anyone would expect from a random algebraic guess.

### Did AI "discover" gravity?

No. The paper does not explain gravity, and it does not derive G from a physical theory. It presents a *phenomenological* expression — a mathematical formula that fits the measured value with high precision. The open question is **why** this particular formula matches; that requires future physics work to figure out a mechanism.

### How big a deal is this — where does it sit on the scale?

Calibrated answer: this is **not** a Nobel-level overturning of physics. There is no new theoretical mechanism here — we don't yet understand WHY gravity has this exact strength. What this paper provides is a precise numerical pattern that any future theory of gravity has to reproduce.

The closest historical analogy is **Balmer's formula for hydrogen** (1885). Johann Balmer wrote down a simple formula that exactly fit the wavelengths of light hydrogen emits. He didn't explain why — but his formula was so precise it couldn't be coincidence, and it became the target Niels Bohr had to explain when he built the first quantum model of the atom 28 years later, in 1913. The Bohr model was the Nobel-level breakthrough. Balmer's formula was the precise pattern that *forced the question*.

This paper is that for gravity. Not the explanation of gravity — the precise numerical target the explanation has to hit. If the formula survives independent scrutiny and replication, it becomes a constraint on every future theory of quantum gravity that claims to be complete.

Concretely: G is one of the handful of fundamental constants that "set up" our universe (alongside ℏ, c, the electron mass, the fine-structure constant). Until now, G could only be measured experimentally — there was no theory that predicted its value from anything else. This paper shows a formula that does — to 1.86 ppm. Whether the formula is *physically meaningful* (i.e. whether it points at a real mechanism) is the open question. Whether it's *numerically real* is testable by anyone who runs the reproducibility package.

### Is this peer-reviewed?

Not yet. The paper is published on Zenodo (an open research archive that hands out citable DOIs) along with a full reproducibility package — source code, search algorithm, raw enumeration data. Anyone can verify the result independently from primitives.

Formal journal peer review would be a subsequent step. The paper was also submitted to arXiv (physics.gen-ph) and is **not** on arXiv — see "What happened with arXiv?" below.

### What happened with arXiv?

The submission was declined by arXiv moderators on 2026-05-21. The rejection letter states only: *"Our moderators determined that your submission does not contain sufficient original or substantive scholarly research and is not of interest to arXiv."* No specific technical objection was raised; no engagement on the physics.

The contrast is worth stating directly: the paper carries a substantive endorsement from **Holger Bech Nielsen** — theoretical physicist at the Niels Bohr Institute, co-discoverer of the Nielsen–Ninomiya theorem, founding figure of string theory. He requested specific clarifications on prior-art citations and engaged with the technical content before agreeing to endorse. The same paper, the same week, was declined by an anonymous gen-ph moderator without engagement on its content.

arXiv's policy forbids resubmission and permits appeal only upon acceptance by a peer-reviewed journal. The author has not appealed and is not pursuing arXiv further. The reproducibility package on Zenodo + GitHub stands on its own; the NBI endorsement is the institutional anchor.

### Who is the author?

Oldřich Dvořák — an independent researcher. Born in the Czech Republic; works as a world citizen. **He holds no university degree, has no formal physics or scientific training, and no institutional academic affiliation.** His primary research interest is building multi-agent AI systems that can take on serious problems end-to-end. This is part of why the result is unusual: it is not a paper from a lab, from a PhD programme, or from a senior researcher — it is a paper produced by a layman directing AI agents on subscription tooling that any private individual can buy.

### How can a layman with no degree publish physics?

The author did not personally derive the result by hand. The AI agents he directed did the algebraic enumeration, the cross-validation, the manuscript drafting. What the author contributed is **the framing of the research question, the discipline to insist on verification before publication, and the engineering of a sufficiently good agent harness to make the result possible at this cost level**. The paper is not a claim that one untrained person *understands* gravity at the level a Nobel laureate would. It is a claim that on the current AI tool stack, a layman with the right harness can produce a falsifiable, reproducible, peer-reviewable physical result. That is the part that is genuinely new.

### How much of the six weeks was discovery vs verification?

A small minority was discovery. The initial algebraic match surfaced relatively early in the work; the bulk of the six weeks went into rigorous verification — independent enumerations, the PSLQ/LLL cross-check, the Alpha21 Basin exact scan, the lepton-mass-ratio control test (which the canonical scaffold fails — see below), the documented disclosure of the cost-budget-40 sham match. A real result has to survive that level of scrutiny; this is the part of the work that distinguishes a genuine finding from numerology, and it is where most of the labour-hours and most of the compute went.

### Who endorsed the arXiv submission?

**Holger Bech Nielsen** — theoretical physicist at the Niels Bohr Institute, University of Copenhagen. Holger Nielsen is co-discoverer of the Nielsen–Ninomiya theorem (lattice gauge theory) and a long-standing contributor to string-theory foundations and the Random Dynamics programme. For a non-physicist, non-affiliated author publishing in `physics.gen-ph`, his endorsement is a substantive physics-credibility anchor, not a procedural rubber-stamp.

### Did AI write the paper, or was it a tool?

AI agents wrote the paper end-to-end under the founder's direction. The founder set the research question, oversaw the work, and made the high-level decisions. The agents did the algebraic search, the enumeration, the cross-validation, the manuscript drafting. The founder is not a physicist and could not have produced this without the agents.

### How much did this cost?

A consumer-grade AI subscription — the kind of monthly plan a private user signs up for, the same Claude / Codex / Gemini tiers anyone with a credit card can buy. No API top-ups beyond the subscription tier. No GPU rental. No fine-tuning. No grant funding. The point is not the exact dollar figure (which the author did not itemise) but the access tier: this entire piece of research was done on tooling available to any individual.

### So one person on a consumer-grade budget out-did the AI labs?

The framing is misleading. The AI labs trained the models that the agents used. The founder did not train any model. What the work demonstrates is that **on top of the same models everyone else has**, the *harness* around the model (how it writes code, navigates files, compacts memory, reviews work) delivers leverage that no model upgrade between current tiers produces. The four open-source tools the founder published (`raisin`, `ax-headers`, `hard-compact`, `full-review`) are the harness fixes that compounded into the research output. The labs trained the engine; the founder built a better gearbox.

---

## For the technically curious

### Why physics.gen-ph instead of a more specific category?

physics.gen-ph is the arXiv category with the lowest barrier to entry, which was the appropriate first venue for a non-affiliated author. The author also had an endorsement from Holger Bech Nielsen (NBI), which substantively raised the paper's credibility — but the gen-ph moderators declined the submission anyway (see "What happened with arXiv?"). The result stands on the Zenodo reproducibility package and the NBI endorsement, not on arXiv indexing.

### What does "rank-1 across cost-18 to cost-21" mean?

The expression was found by systematically enumerating closed-form combinations of fundamental constants up to algebraic "cost" 21 (where cost is a complexity score on the expression). At every cost level from 18 through 21, the canonical expression `G = (4/3)·(ℏc/m_e²)·α²¹·exp(−5α/2)` was the rank-1 (top-scoring) candidate by match-to-measured-G. The growth factor — the ratio between the score of the top candidate and the next competitor — narrowed monotonically from 1.42 at cost-18 to 1.19 at cost-21, meaning the canonical attractor's basin is contracting as enumeration depth grows. No alternative algebraic candidate displaces the canonical form at any depth investigated.

### What is the "sham match at budget=40"?

For full enumeration transparency, one algebraic candidate at cost-budget 40 matches or beats the canonical relative-error score. It is classified `TRASH_BROAD_GRAMMAR` — the broad-grammar variant of the enumeration permits combinations that have no physically motivated structure (it picks up coincidental matches when allowed enough algebraic freedom). The paper discloses this explicitly. The strict-grammar enumeration (cost-18 → cost-21) does not surface this candidate; it appears only under the broad grammar at much higher cost. Treating it as "evidence for an alternative" would be cherry-picking.

### What about lepton mass ratios? Did the enumeration find anything for the muon and tau?

A separate 19-framework survey for `m_μ/m_e` and `m_τ/m_e` was run and produced no parameter-free prediction from the locked S7/SO(7)/B3 scaffold. Best match was 1408 ppm — many orders of magnitude worse than the G result. This is documented and `RULED_OUT`. The paper does not claim general derivation of fundamental constants; it claims one specific high-precision relation for G.

### Was C40 (full brute-force enumeration to cost 40) attempted?

Yes, ruled out as infeasible. The shell growth between cost-13 and cost-14 was 1.64, which exceeded the kill threshold of 1.50. The enumeration is therefore capped at C21 with bounded-search wording for the paper. The published evidence is the C18-C21 rank-1 stability, not a full search.

### How is the cross-validation done?

Three independent methods:

1. **AV6 beam search** — heuristic algebraic search over the constrained grammar
2. **PSLQ/LLL integer-relation algorithm** — independently identifies the same integer-coefficient relation
3. **Alpha21 Basin exact scan** — exact enumeration of all variations within a tight basin around the canonical form

All three converge on the same expression as rank-1. This is what allows the claim "the expression is robust to enumeration method," not just "robust to enumeration depth."

### Could the agents have retrieved this expression from training data?

There is no published closed-form expression for G in the physics literature this could be retrieved from — the entire reason G is measured rather than computed is that no such expression was known. The expression was discovered by the enumeration the agents ran, with the search code (Julia, jl15 baseline) in the repo. Anyone can rerun the search from primitives and verify the canonical relation reappears.

### Why six weeks specifically?

The compute and reasoning budget for the bounded enumeration ran from initial framing to C21 closure across that window. Significant time was spent on the engine-equivalence work — earlier engine versions (jl13, jl14) had a bug in the alpha-family seed cap that suppressed the canonical match. jl15 fixes it and is the publication baseline. The bug-fix history is documented in the source brief.

### What's the marginal compute cost specifically?

Per-token cost on the founder's consumer subscriptions over the six-week window. The author did not maintain itemised billing per task; the relevant fact is that the spend stayed within ordinary monthly subscription rates (Claude Max + Codex CLI plan + Gemini access). No API spend beyond the subscription tier. No GPU rental. No fine-tuning. The cost is interesting not because of its exact dollar figure but because it lives entirely on the consumer side of the AI tooling market.

---

## For the AI / tools audience

### What are the four open-source tools mentioned in the paper?

All on github.com/Oldrich333:

- **raisin** — Python style optimised for LLM-readability, not human-readability. ~50% fewer tokens at identical behaviour. 786 tests verified.
- **ax-headers** — one-line file metadata so an agent reads file roles before opening any bodies. ~30% reduction in triage context on a 350-file production codebase.
- **hard-compact** — drop-in custom compaction prompt that preserves operational state across context windows. 15-30% of default summary size.
- **full-review** — cross-family adversarial code review. 0.80-0.87 recall on a 15-bug fixture vs 0.40 for naive parallel.

Each is independently useful.

### Did the agents make mistakes the founder had to catch?

Yes, extensively. The enumeration produced false leads, the manuscript draft went through multiple revisions, the C13-C14 growth-factor warning was caught by the agent and re-escalated to the founder for a sequencing decision. The full audit trail is in the source brief (parts of which can be released on request for verification).

### Was the paper written by one agent or multiple?

Multiple, in council. The system uses cross-family second opinions (Codex / Claude / Gemini / Deepseek) on consequential decisions. The manuscript drafting, the enumeration claims, the cross-validation reports — each passed multiple model families before founder approval.

### What is the founder's role precisely?

Research framing, vision, conceptual decisions, blast-radius assessment, final sign-off on consequential branches. The founder is "the leader, the agents are the executive layer" — not "the user, the AI is the tool." Full delegation of technical execution to the agents, full reservation of strategic decisions to the founder.

### What would the methodology look like applied to a different open problem?

That is precisely the next direction. The Newton-G paper is the first proof point of a larger system the founder is building — a platform for AI agents to take on open scientific and technical problems the way this one was taken on, but at scale and across many domains in parallel. The four open-source tools are the visible methodology layer of that platform; the full system is in active development and orchestrates parallel research programmes, cross-family verification councils, and persistent project memory across long horizons. **More results of this character are planned**, on a range of open problems. The Newton-G paper is the first one out of the gate, not the last. Suggestions for problems welcome at `oldrich@oldrich.me`.

---

## On the broader programme

### So you're building a platform. What is it?

The system is a multi-agent research/operations platform. Code-name aside, the working idea is: AI agents organised the way a small focused research lab is organised — with a leader role, a verification council, persistent memory, and a library of methodology tools — taking on problems that ordinary single-shot prompting cannot. The Newton-G paper is the first **public** demonstration that the system can produce something genuinely new outside its operator's domain expertise. Further demonstrations are in preparation across physics, mathematics, and other open-problem domains; details and timing held until each one is ready.

### Why isn't the platform open-source like the four tools?

The tools (raisin, ax-headers, hard-compact, full-review) are general-purpose harness fixes that benefit every agent user. The platform around them is more opinionated, more entangled with the founder's own infrastructure, and is the live system inside which the founder runs his own work — including the present paper. Open-sourcing it on day zero would not actually be useful to anyone other than a competitor; the underlying ideas, however, are openly described and the four tools are the parts most readily lifted into another environment.

---

## Technical notes (for physicists and careful readers)

These notes clarify several points the layman-facing sections deliberately compress.

### What about the CODATA-2022 22 ppm experimental uncertainty for G?

Real concern, worth addressing directly. `G` is one of the least precisely measured fundamental constants — CODATA-2022 assigns it a relative standard uncertainty of approximately 22 ppm, in part because independent torsion-balance experiments disagree at ~10× their individual quoted uncertainties.

The "1.86 ppm match" in this paper is **against the CODATA-2022 central value**, not against a measurement with sub-ppm precision. The formula therefore matches the currently-best-known value comfortably *within* the 22 ppm experimental uncertainty band. Two implications worth being explicit about:

- The claim is "the formula reproduces the currently-best-known value within experimental uncertainty," not "the formula predicts G to seven digits with absolute confidence."
- When tighter `G` measurements are eventually achieved (active research area), the formula's match becomes a sharper test. If the central value moves by more than ~5 ppm in future CODATA cycles, this could either strengthen or weaken the case for the formula being physically meaningful.

The right framing is: this is a candidate empirical relation that has now been put on the table; tighter experimental work on `G` will either reinforce it as a precise pattern that future theory must explain, or eventually invalidate it.

### "Predicts" vs "derives" — what's the precise claim?

The body uses "predicts" / "matches" / "reproduces" deliberately and avoids "derives." Derivation in physics implies a first-principles theoretical mechanism. This paper presents a *phenomenological* relation found by systematic bounded algebraic search. The match is precise; the mechanism is the open question.

### Why the Balmer analogy and not the Koide formula?

The layman-facing sections use Balmer's 1885 hydrogen formula because it is recognizable to a broader audience and conveys the right dynamic — a precise empirical pattern that later theory had to explain.

The closer *technical* analogy for physicists is the **Koide formula** for charged-lepton masses (Yoshio Koide, 1981):

```
(m_e + m_μ + m_τ) / (√m_e + √m_μ + √m_τ)² ≈ 2/3
```

The Koide relation has held at remarkable precision for over 40 years and remains unexplained — a celebrated example of a high-precision empirical relation among fundamental constants without an accepted mechanism. The G-formula in this paper sits in the same epistemic category as Koide: a precise empirical relation between physical constants, awaiting a physical explanation.

Both analogies (Balmer for the "precise-pattern-that-drives-future-theory" dynamic, Koide for the "high-precision-empirical-relation-between-constants" shape) are useful; we use whichever fits the audience.

### Is the layman framing "the strength of gravity has a formula now too" technically accurate?

Technically: `G` now has an empirical fit predicting its value from other measured constants. Not a first-principles physical formula in the sense Newton's `F = GMm/r²` is a physical formula. The lay phrasing trades technical precision for accessibility (and for laymen the distinction "fit vs formula" is usually invisible). For physicists: the more precise statement is "the value of `G` now has a high-precision empirical relation to other measured constants."

### How robust is the bounded enumeration?

The canonical expression is rank-1 across cost-18 through cost-21 under the *strict-grammar* enumeration, with growth-factor monotonically narrowing from 1.42 (C18) to 1.19 (C21) — meaning the canonical basin is contracting as search depth grows, the signature of a real attractor.

One algebraic candidate at cost-budget 40 matches or beats the canonical relative-error score under the *broad grammar* (which permits combinations without physically motivated structure). The paper documents this explicitly as `sham40_match_or_beat=1` (classified `TRASH_BROAD_GRAMMAR`) — hiding it would be the numerology move; surfacing it is the honest one. The strict-grammar enumeration does not surface this candidate.

C40 brute-force enumeration was attempted and ruled out as infeasible (shell growth between C13 and C14 was 1.64, exceeding the 1.50 kill threshold). The publication baseline is C21 with bounded-search wording, not C40 exhaustive.

## On AI hype and tone

### Isn't this just AI-bro hype?

Read the reproducibility package. The arXiv preprint, the enumeration code, the certification scripts. The result is either reproducible from primitives or it isn't. Hype claims don't ship full reproducibility packages with adversarial-search code.

### Why the LED-bulb / coal-furnace metaphor?

It's the most honest description of what the methodology shows. The AI industry's marginal capex spend is on bigger models. The marginal *output* gain on the founder's side came from harness optimisation around the existing models, not from waiting for a bigger model. Same physics as LEDs replacing incandescent bulbs — same light, fraction of the watts. Method beats coal.

### What's the founder's interest? What's being sold?

Nothing is being sold. The four tools are MIT licensed and freely usable. The paper is open access. The platform that produced the paper is private but not for sale. The interest is empirical — to publish a measurable counterexample to the "bigger model = better" narrative and to demonstrate that the gap between solo AI work and lab AI work is much smaller than the compute capex numbers suggest.
