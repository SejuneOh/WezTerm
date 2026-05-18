# PR Draft Generator

Analyzes the current git branch (commits, diff, linked issue) and writes an **English** PR body draft to a markdown file. The skill is drafting-only — it never pushes, never calls `gh pr create`, never commits the generated file.

## Argument Parsing

First-pass flag → `TYPE`, remaining tokens → options. All flags use `--` prefix.

- `/pr-draft` → generate draft from current branch using auto-detected base
- `/pr-draft --help` → show usage and exit
- `/pr-draft --base <branch>` → override base branch for diff
- `/pr-draft --template <path>` → override PR template file
- `/pr-draft --out <path>` → override output file path
- `/pr-draft --no-issue` → skip GitHub issue fetch
- `/pr-draft --refresh` → overwrite existing draft for the same branch (otherwise fail-fast when a draft already exists)

Flags may combine, e.g. `/pr-draft --base main --refresh`.

## Constants

```
DEFAULT_TEMPLATE_PATH="${CLAUDE_PR_TEMPLATE_PATH:-}"
DEFAULT_OUTPUT_DIR="${CLAUDE_PR_OUTPUT_DIR:-}"
```

## Template Contract (authoritative)

The resolved PR template (see step 3) is the **single source of truth** for the draft's structure. The skill must **not** invent, reorder, rename, drop, or merge sections.

Preservation rules:

- **Section headings**: every `## ...` / `### ...` heading from the template must appear in the output in the same order, with the exact heading text. If the template uses `## Description`, the draft uses `## Description` — not `## Overview`, not `## Summary`.
- **Checkbox wording**: each `- [ ] ...` item is copied verbatim. The skill only toggles `- [ ]` → `- [x]` when the diff clearly satisfies the item; the trailing text is never rewritten.
- **HTML comment guidance**: `<!-- ... -->` blocks in the template (often Korean usage hints) are **kept as-is** in the output so future regenerations remain self-explanatory.
- **Placeholder bullets**: if the template has empty bullet stubs (e.g. `-\n-\n-` under "What is the new behavior?"), fill them with one bullet per logical change; do not delete the structure before filling.
- **Extra content**: new subsections may only be added *inside* an existing template section (e.g. add a benchmark table under "Other information") — never as a new top-level heading outside the template.
- **Blank template section**: when there is nothing to say for a section, keep the heading and write a one-line English placeholder (e.g. `_None._` or `_Not applicable for this change._`) instead of removing it.

Workflow implication: before writing the draft, parse the template into an ordered list of `(heading, comment-hints, checkbox-items)` tuples and fill each tuple in place. If the logic below (step 6) and the template disagree, **the template wins**.

## Help Output

Print the following for `--help` and exit:

```
PR Draft Generator

Usage: /pr-draft [flags]

Flags:
  --help                 Show this help
  --base <branch>        Base branch to diff against (auto-detected otherwise)
  --template <path>      Override PR template file path
  --out <path>           Override output file path
  --no-issue             Skip GitHub issue fetch even if branch has a number
  --refresh              Overwrite existing draft for the same branch

Behavior:
  - Never pushes, never creates a PR on GitHub, never commits the draft.
  - Output defaults to $CLAUDE_PR_OUTPUT_DIR/PR_<branch-slug>.md
  - Body is always written in English, regardless of conversation language.

Examples:
  /pr-draft
  /pr-draft --base main
  /pr-draft --refresh
  /pr-draft --template .github/PULL_REQUEST_TEMPLATE.md
```

## Main Flow

Execute these steps in order. Stop with a clear error if any required input is missing.

### 1. Resolve git context

```bash
BRANCH=$(git branch --show-current)
BRANCH_SLUG=$(echo "$BRANCH" | tr '/' '-' | tr -cd 'a-zA-Z0-9-_.')
REPO=$(basename "$(git rev-parse --show-toplevel)")
ISSUE=$(echo "$BRANCH" | grep -oE '[0-9]{4,}' | head -1)
```

- `BRANCH_SLUG` is filesystem-safe: slashes become hyphens, non `[a-zA-Z0-9-_.]` chars are stripped.
- `ISSUE` is empty if no 4+ digit number is found in the branch name.

Fail fast if `BRANCH` is empty (detached HEAD).

### 2. Resolve base branch

Priority order (first match wins):

1. `--base <branch>` argument
2. Project file `.claude/rules/dev-workflow.md` → line matching `## git.main_branch` followed by branch name
3. `.github/PULL_REQUEST_TEMPLATE.md` frontmatter if it declares a base (rare)
4. `main` if `origin/main` exists, else `master`, else `dev`

Use `origin/<base>` for diff operations when the remote ref exists:

```bash
BASE_REF="origin/${BASE_BRANCH}"
git rev-parse --verify "$BASE_REF" >/dev/null 2>&1 || BASE_REF="$BASE_BRANCH"
```

### 3. Locate PR template (required)

Priority order (first existing file wins):

1. `--template <path>` argument
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `.github/pull_request_template.md`
4. `docs/PR_template.md`
5. `DEFAULT_TEMPLATE_PATH`

Verify existence with `Bash` `test -f` (WSL safe) before reading. Load the chosen file with `Read` and parse it per the **Template Contract** above.

If **no template** is found at any of the five locations, **abort** with:

```
No PR template found. Searched:
  --template (if provided)
  .github/PULL_REQUEST_TEMPLATE.md
  .github/pull_request_template.md
  docs/PR_template.md
  $CLAUDE_PR_TEMPLATE_PATH

Pass --template <path> or create one of the above before retrying.
```

Do not synthesize an ad-hoc template. The draft must be structurally identical to a real template.

### 4. Resolve output path

```bash
OUTPUT_PATH="${OUT_ARG:-${DEFAULT_OUTPUT_DIR}/PR_${BRANCH_SLUG}.md}"
```

If the file already exists and `--refresh` was not supplied, stop and print:

```
Draft already exists at <path>. Use /pr-draft --refresh to overwrite.
```

### 5. Gather change context

Run all commands against `BASE_REF`:

```bash
git log "${BASE_REF}..HEAD" --format="%h%x09%s%n%b%n---COMMIT-END---"
git diff --stat "${BASE_REF}...HEAD"
git diff "${BASE_REF}...HEAD" | head -800   # Cap to avoid context overflow; full diff available on demand
```

If `ISSUE` is set and `--no-issue` was not supplied:

```bash
gh issue view "$ISSUE" --json number,title,body,labels,state 2>/dev/null
```

Silently skip the issue fetch if `gh` is unauthenticated or the issue cannot be accessed.

### 6. Synthesize the English draft

Fill the template parsed in step 3, obeying the **Template Contract** above. The rules below tell you *what content to put inside each template section* — they never override the template's structure. If the template lacks a section listed below, **do not add it**; if the template has a section not covered here, leave it populated with a sensible English placeholder rather than dropping it.

**Brevity mandate** (applies to every section):

- Prefer the shortest form that still conveys the change. Reviewers skim PRs; a 120-line body is a failure mode.
- One line per bullet. No sub-bullets, no parenthetical rationale, no "because..." clauses. If a bullet needs explaining, split it into a separate bullet.
- No restating the issue body, the stack trace, or the diff. Reviewers can open the linked issue and the Files tab themselves.
- If a subsection has nothing genuinely non-obvious to say, omit it (or write `_None._`). Do not pad.
- Never add content outside the template structure (e.g. a standalone "Title suggestion" heading). The title is delivered in the Step 8 report, not in the file body.

Content guidance per section (applied only when the template actually contains that heading):

- **Title** (delivered in Step 8 report, not written into the file body): one-line English. Prefer the imperative form of the most significant commit subject, or the issue title if commits are trivial. Include the issue number as `#NNN` at the end.
- **Description**: 1–2 sentences. What changed and why, in one breath. No enumeration of sub-features.
- **Checklist**:
  - Check items visibly satisfied by the diff (code style, self-review, issue mentioned, docs touched).
  - Leave the build item unchecked if there is no evidence of a local build; mention this explicitly in the `To reviewers` section.
  - Keep optional test items commented out if the project template does so.
- **PR type**: infer from conventional-commit prefixes of the commits ahead of base:
  | Prefix | Type |
  | --- | --- |
  | `feat:` | Feature |
  | `fix:` | Bugfix |
  | `perf:` | Bugfix (if resolving incident) or Other (performance) |
  | `refactor:` | Refactoring |
  | `style:` | Code style update |
  | `docs:` | Documentation content changes |
  | `chore:` / `ci:` / `build:` | Other (describe) |
  Check every type that applies; multiple may be valid.
- **Current behavior**: 1–2 sentences summarizing the user-facing symptom from the issue body. Never paste stack traces, error messages, or multi-layer root-cause breakdowns — link the issue instead. For feature PRs with no prior issue, write `_No prior reported issue._`.
- **New behavior**: bullet list, one bullet per logical change group, each fitting on a single line (≈ ≤ 20 words). Name the user-visible outcome. Skip implementation rationale.
- **Other information** — include only what is genuinely non-obvious. Omit (or write `_None._`) when there is nothing to say:
  - Verification evidence only when a concrete artifact exists (snapshot path under `.work/`, benchmark number, screenshot).
  - Backward-compatibility note only when the PR knowingly preserves legacy surface area that would otherwise look like dead code.
  - Explicitly deferred follow-ups only when they are time-bounded or owner-assigned; drop speculative "nice-to-have" lists.
  - Do **not** include a commit split table or a file-by-file impact table — reviewers have the Commits and Files tabs on GitHub.
- **To reviewers** — maximum 3 bullets, each a single line. Include only when genuinely useful:
  - Unchecked checklist item that needs explanation (e.g. "Build not yet verified locally").
  - Required review order when commits must be read sequentially.
  - Deployment or monitoring signal the reviewer should know about post-merge.
  - Skip etiquette notes ("please review carefully"), implementation autobiography, and anything already visible in the diff.

Draft body must be written **in English**. The user's conversation language does not affect the draft.

### 7. Write the draft file

Prepend this HTML comment block at the very top of the file:

```html
<!--
Draft PR body for branch: <BRANCH>
Base:   <BASE_BRANCH>
Issue:  #<ISSUE>  (or "none" when absent)
Commits:
  - <hash> <subject>
  - ...
Generated: <ISO 8601 timestamp>
Regenerated: true|false
-->
```

Then write the full English draft below. Use `Write` when the file is new or `--refresh` was supplied; otherwise abort earlier at step 4.

### 8. Report

Print a short Korean summary for the user. Always include:

- Full output path
- Branch, base, and issue linked
- Commit count ahead of base
- **Suggested PR title** (the one-line English title computed per the Title rule in Step 6 — delivered here so the user can paste it into `--title`, since the file body no longer carries a Title heading)
- Any next-step suggestions (local build command inferred from project language, push, `gh pr create --draft --title "<title>" --body-file <path>`)

Never execute the suggested next steps automatically.

## Project-awareness rules

- Detect project language by inspecting the solution/package file:
  - `*.sln` or `*.csproj` → .NET; suggested build: `dotnet build <solution>.sln`
  - `package.json` → Node.js; suggested build: `npm run build` (or `pnpm` / `yarn` from lockfile)
  - `Cargo.toml` → Rust; `cargo build`
  - `go.mod` → Go; `go build ./...`
  - `pyproject.toml` / `setup.py` → Python; `python -m build` or leave unchecked
- Detect the base branch per project (see step 2) rather than hardcoding `main`. some repos use `dev`, others `main`.
- Respect existing branch conventions — do not rewrite commit subjects, do not suggest squash/merge strategy.

## Common Rules

- **File existence check**: always use `Bash` `test -f "<path>"` (WSL `/mnt/c/...` paths are unreliable with Glob).
- **Filename slug**: convert spaces and slashes to `-`, strip non-`[a-zA-Z0-9-_.]`, lowercase when possible; preserve an existing hyphenated branch name shape.
- **Never**: run `git push`, `git commit`, `gh pr create`, `gh pr edit` from within this skill.
- **Do**: print absolute paths and the exact `gh pr create --draft` command the user can copy.
- **Re-entrance**: re-running without `--refresh` is a no-op that prints the path and exits. Re-running with `--refresh` overwrites; prior content is discarded — warn in the report.
- **Language**: the draft file content is English. The skill's status messages to the user follow the user's conversation language (Korean for this user).
