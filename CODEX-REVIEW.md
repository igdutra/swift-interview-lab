# Codex Review: Wiki Refactor

Date: 2026-07-06

This is an honest review of the `wiki/` refactor as it exists in the repo now.

## Bottom line

The refactor is directionally good.

It solves real drift problems:
- hand-maintained page registry
- hand-written TOCs
- manual hub updates
- inconsistent page wiring

The new system is stricter, but the strictness is mostly productive. For a 71-page static wiki, a small build/check toolchain is justified.

My judgment is:
- Architecture: good
- Maintainability: improved
- Overhead: acceptable, but no longer trivial
- State of completion: mostly done, not fully cleaned up

## What I would do differently

I would keep the architecture, but I would tighten the cleanup path.

The best next move is not another structural refactor. It is a small sequence of finishing work:

1. Add `wiki/README.md`.
2. Fix or disable `reference` page scaffolding.
3. Teach `check.ts` to reject deleted-standard references.
4. Remove migration-era leftovers after the checks make that safe.

Why this is better than reorganizing `_shared/` or pre-rendering navigation now:
- the current architecture already works
- the repo's real drift is semantic, not structural
- documentation plus targeted validation prevents repeat drift
- bigger layout changes would create churn before they remove a current pain

So my answer is: I would be more aggressive about finishing the refactor, but less aggressive about redesigning it.

## What is clearly better now

### 1. Disk-as-truth metadata is the right move

Putting page metadata inside each page and deriving the manifest from disk is a strong choice.

Why it works:
- authors update one file instead of a page plus a registry
- missing nav entries become harder to create
- category / section / role are derived instead of manually duplicated

Relevant files:
- `wiki/tools/build.ts`
- `wiki/tools/lib/manifest.ts`
- `wiki/tools/lib/derive.ts`

### 2. The validator is doing real work

`wiki/tools/check.ts` is not ceremonial. It catches structural drift that a human would miss:
- wrong `_shared/` depth
- stale manifest
- broken fragments
- missing files
- hand-written TOCs
- inline styles
- invalid metadata

This is the core reason the refactor is worth keeping.

### 3. `wiki/tools/` vs `wiki/_shared/` mostly makes sense

This split is reasonable:
- `wiki/tools/` = authoring, generation, validation
- `wiki/_shared/` = runtime assets loaded by pages

That means `wiki/_shared/manifest.js` belongs in `_shared/`, not `tools/`, because pages consume it directly in the browser.

So the existence of both folders is not duplication. They serve different layers.

## Real bugs and weaknesses

### 1. `new-page.ts` scaffolds `reference` pages with theory sections

This is a real bug.

In `wiki/tools/new-page.ts`, the section skeleton is selected with:

- walkthroughs => `WALKTHROUGH_SECTIONS`
- everything else => `THEORY_SECTIONS`

That means `reference` pages currently get the theory masterfile structure, which is wrong for that category.

Impact:
- new reference pages will start from the wrong shape
- authors will either fight the scaffold or ship malformed pages

Recommendation:
- prefer a small reference template now
- if that cannot be done immediately, explicitly refuse to scaffold reference pages until a real template exists

Why A is better than B:
- a reference template keeps the public `new-page.ts reference <filename>` command honest
- refusing is still better than silently creating the wrong page shape
- the current fallback is the worst option because it looks supported while producing misleading output

### 2. The validator does not catch stale references to deleted standards docs

This already happened in the repo.

Examples:
- many footers still mention `wiki/_standards/THEORY_MASTERFILE_STANDARD.md`
- many walkthrough footers still mention `wiki/_standards/WALKTHROUGH_MASTERFILE_STANDARD.md`
- `wiki/_shared/wiki.css` still references the deleted style research doc in its header comment

These are not runtime breakages, but they are still drift. The repo says `_standards/` is gone, while many files still talk as if it exists.

Impact:
- confusing for future maintainers
- makes the refactor look half-finished
- weakens trust in the validator because obvious leftovers pass green

Recommendation:
- add a validator rule forbidding `wiki/_standards/` references anywhere under `wiki/`

Why this belongs in `check.ts`, not only a future `doctor.ts`:
- the deleted standards path is not subjective editorial quality
- it is an architecture invariant after the standards were moved out
- letting it pass green makes the validator less trustworthy

### 3. Generated runtime assets and authored shared assets are mixed together

`wiki/_shared/` currently contains:
- authored CSS: `wiki.css`
- generated manifest: `manifest.js`
- compiled browser assets: `nav.js`, `toc.js`

This is not fatal, but it is muddy.

Problem:
- `_shared/` is simultaneously “source” and “build output”
- the contract is easy to understand only after reading the toolchain

Recommendation:
- keep the current layout for now and document it more bluntly
- only split published/generated assets from authored shared assets later if the wiki keeps growing enough to justify the extra structure

Tradeoff:
- keeping everything browser-consumed under `_shared/` is simpler than inventing another layer today
- splitting it now would add structure faster than it adds value

I would not block on this now. It is a documentation problem before it is an architecture problem.

### 4. Build and check duplicate the same scan/assembly pipeline

`build.ts` and `check.ts` both:
- scan the wiki
- extract each page
- assemble page records

For 71 pages this is fine. If the wiki grows substantially, the duplication becomes maintenance overhead first, performance overhead second.

Impact:
- same logic path exists in multiple entry points
- future changes to the assembly pipeline will want a shared orchestration helper

Recommendation:
- do not abstract this yet just for tidiness
- introduce one `loadWiki()` or `scanAndAssemble()` helper only if the two entry points start diverging enough that changes must be made in both places repeatedly

This is not a bug today. It is a maintainability hotspot.

Why waiting is better than abstracting now:
- the duplication is visible and bounded
- the shared abstraction would be guessed from only two callers
- the next real validator/build change will reveal the right boundary

### 5. The validator is strong on structure but weak on semantic cleanup

The validator is good at “will the site work?”
It is weaker at “does the content still match the architecture?”

Missing checks that would have caught real repo drift:
- stale standards references
- stale handoff files
- category-specific footer conventions
- whether `reference` pages accidentally use theory skeleton conventions

This means the toolchain currently protects mechanics better than intent.

I would split this into two levels:
- `check.ts` should own architecture invariants that must never regress
- a future `doctor.ts` should own softer editorial warnings

That split is better than putting every audit into one command because it keeps CI-style validation deterministic while still giving maintainers a place for judgment-heavy cleanup reports.

### 6. The `wiki/` folder is missing a local README

This is not a code bug, but it is a real maintainability gap.

Right now, understanding the wiki architecture requires reading:
- `WIKI_REFACTOR_HANDOFF.md`
- `wiki/tools/`
- code comments
- scattered conventions inside generated pages

Impact:
- the first place a maintainer will look is `wiki/`
- there is no short local explanation of the architecture, commands, or authored-vs-generated split
- the current handoff doc is too session-specific to be the stable entry point

Recommendation:
- add `wiki/README.md` with the minimum durable context
- explain what lives in `wiki/_shared/`
- explain what lives in `wiki/tools/`
- list the core commands (`build`, `check`, browser `tsc`, `serve`, `new-page`)
- document that page metadata lives in each page and `manifest.js` is generated
- document the add-a-page workflow

This is higher value than many deeper refactors because it reduces onboarding cost without changing the architecture.

## Overhead assessment

The refactor adds real overhead:
- every page now has a strict metadata contract
- page edits sometimes require `build.ts`
- browser script edits require `tsc -p wiki/tools/browser`
- contributors need to understand the generated/runtime split

But the overhead is still light compared with a framework or CMS. There is no package manager complexity, no build graph, no dependency tree, and no deploy system hidden behind it.

My read:
- before refactor: lower process overhead, higher content drift
- after refactor: higher process overhead, much lower drift

That is a good trade for this repo.

## What feels unfinished

The architecture is not half-implemented, but the cleanup clearly stopped early.

Evidence:
- `WIKI_REFACTOR_HANDOFF.md` still exists even though it says to delete it
- `_standards/` content was moved into skills, but many page/footer comments still mention the deleted docs
- `wiki/tools/migrate.ts` still exists as a one-time migration script even though the handoff says cleanup should delete it

So the repo is in this state:
- refactor core: done
- migration cleanup: not done

## What I would do next

### 1. Add `wiki/README.md`

This is the cheapest improvement with the best payoff.

Why A is better than B:
- a local README is where maintainers will look first
- the handoff file is session-specific and should not be the permanent source of truth
- comments inside generated or scaffolded pages are too scattered to teach the system

Minimum contents:
- what page metadata is and where it lives
- what `wiki/tools/` owns
- what `wiki/_shared/` owns
- which files are generated
- the add-a-page workflow
- the build/check/browser-compile/serve commands

### 2. Fix `reference` scaffolding

Right now `reference` is a first-class category in config, but not in scaffolding philosophy.

I would add a small reference-page template rather than removing the command.

Why A is better than B:
- reference pages already exist as a stable category
- `new-page.ts` already advertises the command
- a template can be minimal and h2-driven, matching the existing reference pages
- deleting support would make the tool less complete without solving much

The fallback option is to make `new-page.ts reference ...` fail loudly until the template exists. That is worse than a template, but better than scaffolding theory sections by accident.

### 3. Add a validator pass for banned legacy strings

Low cost, high value.

Examples of banned strings:
- `wiki/_standards/`
- old `Structure per ..._MASTERFILE_STANDARD.md` footer boilerplate
- migration-era references in stable docs

This would have caught current repo drift immediately.

I would put `wiki/_standards/` in `check.ts` because it is a hard invariant. Softer content smells can wait for `doctor.ts`.

### 4. Remove migration-era leftovers

Once `check.ts` rejects deleted-standard references, clean up the old migration trail:
- remove stale `wiki/_standards/` footer references
- update the `wiki.css` header comment
- delete `wiki/tools/migrate.ts` if no one still needs the one-time migration script
- delete or archive `WIKI_REFACTOR_HANDOFF.md` after its durable content is moved into `wiki/README.md`

Why A is better than B:
- cleaning after adding the check prevents the same drift from returning
- moving durable context into `wiki/README.md` preserves knowledge without keeping a stale handoff file
- deleting `migrate.ts` removes a script whose correct use window has passed

### 5. Add a `doctor` command later

Keep `check.ts` strict and machine-focused, but add a higher-level audit command such as:

`node wiki/tools/doctor.ts`

It could report:
- stale standards references
- orphan pages
- empty `topics`
- suspicious TODO placeholders
- hub pages with weak blurbs
- missing cross-links by convention, not just by literal reciprocity

This would separate structural validation from editorial quality checks.

### 6. Consider pre-rendering nav and hub grids at build time later

Current approach:
- pages load `manifest.js`
- browser JS builds nav and hub grids at runtime

That is fine today. But if the wiki grows a lot, every page pays the runtime cost of loading the full site manifest.

Possible future direction:
- keep TOC client-side
- pre-render nav and hub grids at build time
- reserve manifest usage for places that truly need site-wide data

I would not do this yet. It is only worth considering if the wiki becomes much larger.

Why waiting is better than doing it now:
- the current runtime cost is acceptable for this wiki size
- pre-rendering would make `build.ts` mutate more page files
- the current browser-generated nav keeps page HTML simpler

### 7. Unify source comments with the new architecture

A small but valuable cleanup pass should align comments, footers, and headers with reality.

Examples:
- CSS header comments
- page footer “Structure per ...” strings
- migration-era references in docs

This is not glamorous, but it is the difference between “good refactor” and “finished refactor.”

## Keep / change / revert

Keep:
- per-page JSON metadata
- generated manifest
- generated TOC
- generated nav and hub grids
- strict validator
- single `wiki.config.ts` taxonomy

Change:
- `reference` scaffolding
- validator coverage for semantic leftovers
- `wiki/README.md` as the stable local entry point for the folder
- duplicated scan/assemble orchestration later, only if it starts creating real maintenance drag
- clarity around `_shared/` as both authored and generated output

Do not revert:
- the toolchain
- the manifest-based navigation model
- the page-level metadata model

## Final judgment

This refactor makes sense.

It is not overengineered for the current wiki size, but it is now operating in a zone where cleanup discipline matters. The biggest risk is no longer “bad architecture.” The biggest risk is “strict machinery that still allows semantic drift around the edges.”

If maintained properly, this is a better system than the old one.
If maintained lazily, the tooling will stay green while confusing leftovers accumulate.
