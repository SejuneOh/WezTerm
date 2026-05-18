---
name: obsidian
description: Manage notes in the Obsidian vault — create, update, and query by type and title.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Obsidian Note Manager

Manages notes in the Obsidian vault at `$CLAUDE_OBSIDIAN_VAULT` (set per machine, e.g. `/mnt/c/dev/note/Obsidian` on WSL).

## Argument Parsing

First argument → `TYPE`, remaining → `TITLE`. Arguments use `--` prefix.

- `/obsidian --help` → TYPE=help
- `/obsidian --inbox title` → TYPE=inbox, TITLE=title
- `/obsidian --project` → TYPE=project (title derived from branch)
- `/obsidian --decision title` → TYPE=decision, TITLE=title
- `/obsidian --knowledge title` → TYPE=knowledge, TITLE=title
- `/obsidian --reference title` → TYPE=reference, TITLE=title
- `/obsidian --status` → TYPE=status
- `/obsidian --archive` → TYPE=archive (current branch)
- `/obsidian --archive slug` → TYPE=archive, TARGET=slug
- `/obsidian --archive --list` → TYPE=archive-list

No arguments defaults to `help`. Arguments without `--` are treated the same (backward compat).

## Constants

```
VAULT="${CLAUDE_OBSIDIAN_VAULT:?CLAUDE_OBSIDIAN_VAULT not set}"
TODAY=$(date +%Y-%m-%d)
```

## Actions by TYPE

### help

Print the following and exit:

```
Obsidian Note Manager

Usage: /obsidian --<type> [title]

Types:
  --help                 Show this help
  --inbox <title>        Create a quick note in inbox/
  --project              Create/update project note from current branch
  --decision <title>     Create a decision record in decisions/
  --knowledge <title>    Create a knowledge note in knowledge/
  --reference <title>    Create a reference note in references/
  --status               Show current branch project note and recent inbox
  --archive [slug]       Archive a project note (current branch if no slug)
  --archive --list       List archivable project notes

Examples:
  /obsidian --inbox meeting notes
  /obsidian --project
  /obsidian --decision API versioning strategy
  /obsidian --knowledge EF Core migration patterns
  /obsidian --reference Azure Search official docs
  /obsidian --status
  /obsidian --archive
  /obsidian --archive myrepo-main
  /obsidian --archive --list
```

### inbox

1. Filename: `{VAULT}/inbox/{TODAY}-{title-slug}.md` (kebab-case, keep Korean chars as-is)
2. If file exists, append. Otherwise create.
3. New file frontmatter:

```markdown
---
tags:
  - type/inbox
created: {TODAY}
---

# {TITLE}

{Content from conversation context or current context summary}
```

4. Print file path after create/update.

### project

1. Extract repo name, branch and issue number:

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
BRANCH=$(git branch --show-current)
ISSUE=$(echo "$BRANCH" | grep -oE '[0-9]{4,}' | head -1)
SLUG="${REPO}-$(echo "$BRANCH" | tr '/' '-')"
```

2. Filename: `{VAULT}/projects/{SLUG}.md` (e.g. `myrepo-main.md`, `myrepo-feature-123-foo.md`)
3. If file exists:
   - Update `## Current State` with current status
   - Update `## Key Files` with recently changed files
   - Set `updated` frontmatter to today
4. If file does not exist, create with template:

```markdown
---
tags:
  - status/active
  - project/{SLUG}
branch: {BRANCH}
issue: {ISSUE}
created: {TODAY}
updated: {TODAY}
description: 
---

# {BRANCH}

## Context
<!-- Derived from GitHub issue #{ISSUE} -->

## Current State
<!-- Current progress based on git diff/log -->

## Key Files
<!-- Recently changed key files -->

## Open Questions

## Related
```

5. If issue number exists, fetch issue title from GitHub and populate Context.
6. Print file path and summary after create/update.

### decision

1. Filename: `{VAULT}/decisions/{TODAY}-{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/decision
  - project/
  - topic/
created: {TODAY}
status: proposed
description: {TITLE}
---

# {TITLE}

## Problem

## Options Considered

### Option A
- **Pros**: 
- **Cons**: 

### Option B
- **Pros**: 
- **Cons**: 

## Decision

## Consequences

## Related
```

4. Fill sections from conversation context if available.
5. Print file path after create.

### knowledge

1. Filename: `{VAULT}/knowledge/{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/knowledge
  - topic/
created: {TODAY}
updated: {TODAY}
description: {TITLE}
---

# {TITLE}

## Summary

## Details

## Examples

## Gotchas

## Related
```

4. Fill sections from conversation context if available.
5. Print file path after create/update.

### reference

1. Filename: `{VAULT}/references/{title-slug}.md`
2. If file exists, update. Otherwise create.
3. Template:

```markdown
---
tags:
  - type/reference
  - topic/
created: {TODAY}
url: 
description: {TITLE}
---

# {TITLE}

## Source

## Key Points

## Related
```

4. Print file path after create/update.

### archive

Archives a project note when its branch is merged or deprecated.

#### Argument handling

- No argument → derive slug from current repo+branch (same as `--project`)
- `--list` → jump to **archive-list** flow
- Otherwise → treat argument as target slug

#### archive flow

1. Resolve target file:

```bash
# If no argument:
REPO=$(basename "$(git rev-parse --show-toplevel)")
SLUG="${REPO}-$(git branch --show-current | tr '/' '-')"
# If argument provided:
SLUG="{argument}"
```

2. Check file exists:

```bash
test -f "{VAULT}/projects/${SLUG}.md" && echo "exists" || echo "not found"
```

3. If not found → print error and list available project notes, then exit.

4. Read the file. Update frontmatter:
   - Change `status/active` → `status/archived`
   - Add `archived: {TODAY}`
   - Add `resolution: merged` (or `deprecated`/`abandoned` — infer from context, default `merged`)

5. Append archive summary section at the end:

```markdown
## Archive Summary

- **Archived:** {TODAY}
- **Resolution:** {resolution}
- **Final state:** {brief summary of Current State section}
```

6. Ensure archive directory exists, then move file:

```bash
mkdir -p "{VAULT}/projects/archive"
mv "{VAULT}/projects/${SLUG}.md" "{VAULT}/projects/archive/${SLUG}.md"
```

7. Print result: file path and summary in Korean.

#### archive-list flow

1. List all project notes:

```bash
ls "{VAULT}/projects/"*.md 2>/dev/null
```

2. For each note, extract the slug and check if the branch still exists:

```bash
git branch -a --list "*{branch-from-frontmatter}*"
```

3. Print table:

```
Project Notes:
  [active]  myrepo-main              — branch exists (remote/local)
  [stale]   myrepo-fix-...           — branch not found
  [stale]   myrepo-old-feature       — branch not found
```

4. Notes marked `[stale]` are candidates for archiving. Suggest: `"/obsidian --archive {slug}"` for each.

### status

Shows vault overview at a glance.

#### 1. Project Note

1. Extract slug from current repo and git branch.
2. **Use `Bash` `test -f` to check file existence**, then `Read` to read.
   ```bash
   REPO=$(basename "$(git rev-parse --show-toplevel)")
   SLUG="${REPO}-$(git branch --show-current | tr '/' '-')"
   test -f "${VAULT}/projects/${SLUG}.md" && echo "exists" || echo "not found"
   ```
3. If not found: "No project note for current branch. Create one with `/obsidian --project`."
4. If found, summarize: branch, issue, status, Current State, Open Questions.

#### 2. Recent Inbox

1. List recent inbox notes (max 5) using `ls -t`.
   ```bash
   ls -t "${VAULT}/inbox/" 2>/dev/null | head -5
   ```
2. If empty: "Inbox is empty."
3. If notes exist, list filename and first `#` heading.

#### 3. Output Format

```
Project: {BRANCH}
  - Status: {status tag}
  - Issue: #{ISSUE}
  - Current State summary
  - Open Questions

Inbox (recent 5):
  - {filename} - {title}
  - ...
```

## Common Rules

- **File existence check**: On WSL, `Glob` may fail to find files on `/mnt/c/...` paths. **Always use `Bash` `test -f`** for existence checks. Use `Read` to read files.
  ```bash
  test -f "{VAULT}/projects/{SLUG}.md" && echo "exists" || echo "not found"
  ```
- **Directory listing**: Use `Bash` `ls` instead of `Glob`.
- **Filename slug**: Spaces → `-`, remove special chars, lowercase. Keep Korean chars as-is.
- **Wikilinks**: Link related notes as `[[note-name]]`.
- **Tags**: Use `status/`, `project/`, `type/`, `topic/` prefixes.
- **Output**: Print file path and brief summary in Korean after every action.
- **Protect existing content**: Never overwrite. On update, preserve existing content and modify only changed sections.
