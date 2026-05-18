---
name: project-launcher
description: Dispatch a background Claude Code session targeting one of the registered project paths. New sessions appear in `claude agents` view.
tools: Read, Bash, AskUserQuestion
---

# Project Launcher

Dispatches background Claude Code sessions (`claude --bg`) targeting one of the projects registered in `projects.json`. Each dispatched session runs in its own working directory with an optional bootstrap command (`on_start`), and appears as a row in `claude agents`.

## Argument Parsing

First argument controls the action. Arguments use `--` prefix for flags.

- `/project-launcher` → no args, interactive: show list and ask user to pick
- `/project-launcher --list` → just list registered projects, no dispatch
- `/project-launcher --help` → show usage
- `/project-launcher <name>` → dispatch session for `<name>` using its `on_start` as the first prompt
- `/project-launcher <name> <task...>` → dispatch session for `<name>` with `<task>` as the first prompt (ignores `on_start`)

## Constants

```
REGISTRY="$HOME/.claude/skills/project-launcher/projects.json"
```

## Actions by TYPE

### help

Print the following and exit:

```
Project Launcher

Usage: /project-launcher [--list | --help | <name> [task]]

Examples:
  /project-launcher                   # 대화형: 목록에서 선택
  /project-launcher --list            # 등록된 프로젝트 목록만 표시
  /project-launcher api               # api를 on_start로 dispatch
  /project-launcher api "테스트 돌려"   # api를 직접 작업으로 dispatch
```

### list

1. Read `${REGISTRY}` with the `Read` tool and parse JSON.
2. Print as a table (in Korean labels):

```
등록된 프로젝트:
  name              path                                                                       on_start
  ──────────────    ──────────────────────────────────────────────────────────────────────    ──────────────────
  api               /home/me/dev/myorg/api                                                       /obsidian --project
  web               /home/me/dev/myorg/web                                                       /obsidian --project
  ...
```

3. If `description` is set, show it under each row indented.

### no-args (interactive)

1. Read `${REGISTRY}`.
2. Use `AskUserQuestion` to ask which project to launch.
   - If projects count ≤ 4: pass them as options (label = `name`, description = `description + " — " + path`).
   - If projects count > 4: print the numbered list as a plain message and ask the user to type the name. Skip `AskUserQuestion`.
3. After name is chosen, ask whether to use `on_start` or a custom task — only if both options are meaningful:
   - If the project has `on_start`: use `AskUserQuestion` with options `["on_start 사용 (<on_start value>)", "직접 작업 입력"]`.
   - If no `on_start`: skip; ask the user to type the task in a plain follow-up message.
4. If "직접 작업 입력" chosen, ask the user via plain message for the task text and wait for their reply.
5. Proceed to the dispatch flow with the resolved `<name>` and `<prompt>`.

### dispatch <name> [task]

1. Read `${REGISTRY}` and find the project whose `name` equals `<name>`.
2. If not found:
   - Print `알 수 없는 프로젝트: <name>`.
   - List available `name` values from the registry.
   - Exit.
3. Resolve the dispatch prompt:
   - If `<task>` is provided (non-empty): `PROMPT="<task>"`.
   - Else if project has `on_start`: `PROMPT="<on_start>"`.
   - Else: ask the user via plain message and wait for their reply.
4. Verify the project path exists:
   ```bash
   test -d "<path>" && echo "ok" || echo "missing"
   ```
   If missing, print `경로가 존재하지 않습니다: <path>` and exit.
5. Dispatch the background session. Use a subshell so the current working directory is not polluted:
   ```bash
   (cd "<path>" && claude --bg --name "<name>" "<PROMPT>")
   ```
   - Use double quotes around `<PROMPT>` to keep Korean characters and slashes intact.
   - If `<PROMPT>` contains a literal `"`, escape it as `\"` before substitution.
6. Capture the command's stdout. Parse the short session ID from the line matching `^backgrounded · <id>`.
7. Print result in Korean:

```
Dispatched: <name>
  경로:       <path>
  첫 프롬프트: <PROMPT>
  세션 ID:    <id>

다음 명령으로 확인할 수 있습니다:
  claude agents             # 전체 세션 보기
  claude attach <id>        # 이 세션에 attach
  claude logs <id>          # 출력 확인
  claude stop <id>          # 세션 중지
```

8. If the ID could not be parsed, still print the full stdout so the user can read it themselves.

## Common Rules

- **Read registry** with the `Read` tool. Do not call `jq`; parse JSON in your head from the file contents.
- **Path validation**: always `test -d` before dispatching. Never dispatch to a missing path.
- **Shell quoting**: paths and prompts may contain spaces or Korean — always wrap them in double quotes. The `<name>` value is always a safe identifier so quoting is optional, but use it for consistency.
- **Output language**: print results in Korean.
- **Single dispatch per invocation**: v1 supports one session per call. To launch many, the user calls this skill multiple times.
- **Project registry edits**: if the user asks to add/remove/edit a project, edit `projects.json` directly with the `Edit` tool. Validate JSON syntax after the edit by re-reading the file. Do not silently rename existing entries.
