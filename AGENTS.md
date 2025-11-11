# Repository Guidelines

## Mission & Scope
This repo documents the OpenREST contract—a prescriptive playbook for REST API design. Every change should sharpen requirements, keep examples accurate, and give API teams concrete direction. Favor clarity over breadth; speculative copy belongs in issues, not the docs.

## Project Structure
Hugo with the Docsy theme powers the site. Markdown sources live in `content/en/`, organized by topic (`advanced/`, `structure/`, `security/`). Reusable UI overrides belong in `assets/` (SCSS, JS, images). Site-wide settings stay in `hugo.yaml`; module versions are pinned in `go.mod`. Hugo’s cache (`resources/`) and build output (`public/`) are disposable—never hand-edit them.

## Build, Test, and Development Commands
- `make run` — wraps `hugo server -D` for local preview with drafts.
- `make public` — runs `hugo --minify` to produce the deployable `public/`.
- `make clean` — removes `public/` and `resources/` for a cold rebuild.
- `make update` — executes `hugo mod get -u` when Docsy or dependency bumps are needed.
- `make lint` — calls `markdownlint content/*** --fix`; rerun until the tree is clean.

## Style & Content Rules
Use front matter with kebab-case keys (`title`, `menu.main`). Keep prose in short lines (≈90 chars) and use fenced code blocks with language hints (` ```bash `). Reference endpoints literally (`GET /resources`). Shortcodes should be lower snake case on standalone lines. SCSS uses two-space indents; override styling via `assets/`, never `node_modules/` or Docsy sources.

## Testing & Verification
There is no automated suite; validation equals behaving like the reader. Draft with `make run`, watch for shortcode warnings, and click through the impacted pages. Before opening a PR, run `make public` plus `make lint`. When navigation or permalinks move, update inbound links or document redirects in the same change.

## Agent Tone & Voice
Communicate in a calm, professional voice that leads with outcomes (“Updated `content/en/structure/_index.md` to clarify resource naming”). Cite paths and commands explicitly, state unknowns plainly, and close with recommended next actions when follow-up is likely. Skip humor, filler, and apologies; precision builds trust.

### Writing Style Expectations
- Favor direct statements over hedged language (“Cookies leak. Don’t use them.”). If something is non-negotiable, say so explicitly.
- Write in approachable plain English using contractions where they improve readability; keep sentences concise but conversational.
- Mix structured argumentation with short emphatic sentences or rhetorical prompts when it sharpens the point (e.g., “Why? Because...”, “No.”). Skip humorous asides unless they reinforce guidance already backed by facts.
- When offering alternatives or rationale, lead with the actionable guidance, then explain the “why” in a follow-up line so readers see the mandate first.

## Commit & Pull Request Guidelines
Write imperative, single-scope commits (“Add error-handling guidance to security section”). PRs should explain intent, list touched sections, include screenshots for visual tweaks, and confirm `make public`/`make lint`. Link issues and avoid force-pushing after review starts; add follow-up commits or announce a rebase.
