# Neovim Keymaps Reference

A consolidated keymap cheatsheet for the Neovim plugin stack in this repo.
Leader key is `\` (backslash).

## Table of Contents

- [LSP (roslyn + lspconfig)](#lsp-roslyn--lspconfig)
- [Motion (flash.nvim)](#motion-flashnvim)
- [Harpoon (pinned files)](#harpoon-pinned-files)
- [Outline (aerial.nvim)](#outline-aerialnvim)
- [Debug (nvim-dap)](#debug-nvim-dap)
- [.NET (easy-dotnet)](#net-easy-dotnet)
- [Test (neotest)](#test-neotest)
- [Messages & Notifications (noice + nvim-notify)](#messages--notifications-noice--nvim-notify)
- [Substitute (gs prefix)](#substitute-gs-prefix)
- [File Explorer (nvim-tree)](#file-explorer-nvim-tree)
- [Telescope](#telescope)
- [Splits & Windows](#splits--windows)
- [Git (gitsigns + lazygit)](#git-gitsigns--lazygit)
- [Trouble (diagnostics list)](#trouble-diagnostics-list)
- [Leader Group Prefixes](#leader-group-prefixes)

---

## LSP (roslyn + lspconfig)

Keymaps are registered on `LspAttach` only when the server supports the corresponding method.

| Key | Action |
|---|---|
| `gd` | Go to definition (Telescope) |
| `gD` | Go to declaration |
| `gR` | Find references (Telescope) |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>rs` | Restart LSP |
| `<leader>d` | Show diagnostic on current line |
| `<leader>D` | Buffer diagnostics list (Telescope) |
| `[d` / `]d` | Previous / next diagnostic |

**Commands**
- `:LspInfo` — show attached clients
- `:LspRestart` — restart LSP
- `:Roslyn target` — pick `.sln` when multiple solutions exist
- `:Roslyn restart` — restart Roslyn server

---

## Motion (flash.nvim)

2-keystroke screen jumps with labels.

| Key | Mode | Action |
|---|---|---|
| `s` + 2 chars | normal/visual/operator | Jump to any matching pair on screen |
| `S` | normal/visual/operator | Treesitter node jump |
| `r` | operator | Remote motion (act on a region without moving cursor) |
| `R` | operator/visual | Treesitter search |
| `<C-s>` | command | Toggle Flash in search |

---

## Harpoon (pinned files)

| Key | Action |
|---|---|
| `<leader>ha` | Add current file to a slot |
| `<leader>hh` | Toggle quick menu |
| `<leader>1`–`<leader>4` | Jump to slot 1–4 |
| `<leader>hp` / `<leader>hn` | Previous / next slot |

Inside the quick menu, `dd` removes a slot and `:w` saves the order.

---

## Outline (aerial.nvim)

LSP-backed symbol outline shown on the right edge.

| Key | Action |
|---|---|
| `<leader>o` | Toggle outline |
| `<leader>O` | Toggle navigation mode |
| `{` / `}` (inside outline) | Previous / next symbol |

---

## Debug (nvim-dap)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Set conditional breakpoint |
| `<leader>dc` | Start / continue |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>de` | Evaluate expression (visual supported) |
| `<leader>du` | Toggle DAP UI |
| `<leader>dl` | Run last session |
| `<leader>dt` | Terminate |
| `<leader>dL` | Reload `.vscode/launch.json` |

C# launch configurations:
1. `Launch (.csproj auto-detect)` — picks the first DLL under `bin/Debug/**/`
2. `Launch (manual DLL path)` — prompts for DLL path
3. `Attach to process` — pick a running process

If `.vscode/launch.json` exists in the workspace root, its `coreclr` entries are auto-loaded.

---

## .NET (easy-dotnet)

| Key | Action |
|---|---|
| `<leader>nr` | Run with launchSettings profile picker |
| `<leader>nb` | `dotnet build` |
| `<leader>nt` | Test runner (split UI) |
| `<leader>nR` | `dotnet restore` |
| `<leader>nc` | `dotnet clean` |
| `<leader>nn` | New project |
| `<leader>ns` | User-secrets |

**Commands**
- `:Dotnet build|run|test|restore|clean|new|secrets|testrunner`
- `:DotnetRunProfile` — same as `<leader>nr`, profile picker from `Properties/launchSettings.json`

---

## Test (neotest)

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run all tests in current file |
| `<leader>ta` | Run all tests (CWD) |
| `<leader>tl` | Re-run last test |
| `<leader>td` | Run nearest test under DAP (debug breakpoints) |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output (auto-close) |
| `<leader>tO` | Toggle output panel |
| `<leader>tx` | Stop |

---

## Messages & Notifications (noice + nvim-notify)

| Key | Action |
|---|---|
| `<leader>un` | Dismiss all notifications |
| `<leader>snl` | Last message |
| `<leader>snh` | Message history |
| `<leader>sna` | All messages |
| `<leader>snd` | Dismiss Noice |

Notification render: top-right, `compact`, `static` (no animation), 3-second timeout. Tunable in `nvim/lua/plugins/noice.lua`.

---

## Substitute (gs prefix)

Moved from `s`/`S` to `gs` prefix to free those keys for Flash.

| Key | Action |
|---|---|
| `gs` + motion | Substitute operator (e.g. `gsiw` = swap word with register) |
| `gss` | Substitute line |
| `gS` | Substitute to end of line |
| `gs` (visual) | Substitute selection |

---

## File Explorer (nvim-tree)

| Key | Action |
|---|---|
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Reveal current file in tree |
| `<leader>ec` | Collapse all folders |
| `<leader>er` | Refresh tree |

Tree width is 60 columns with `preserve_window_proportions = true` so opening splits does not shrink the tree.

---

## Telescope

Defaults from `nvim/lua/plugins/telescope.lua`. Common operations:

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (ripgrep) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |

Inside the picker: `<C-j>` / `<C-k>` to move, `<CR>` to select, `<C-x>` horizontal split, `<C-v>` vertical split, `<C-t>` new tab.

---

## Splits & Windows

| Key | Action |
|---|---|
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>se` | Equalize split sizes |
| `<leader>sx` | Close current split |
| `<C-h/j/k/l>` | Navigate splits (smart-splits, also crosses WezTerm panes) |

---

## Git (gitsigns + lazygit)

`gitsigns` provides inline hunk operations. Lazygit opens in a floating window via `<leader>gg` (default lazygit.nvim binding).

| Key | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `<leader>gh` | Hunk operations group (preview, stage, reset) |
| `<leader>gg` | Open Lazygit |

---

## Trouble (diagnostics list)

| Key | Action |
|---|---|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

---

## Leader Group Prefixes

Registered in `nvim/lua/plugins/which-key.lua` so the prefix popup shows group names.

| Prefix | Group |
|---|---|
| `<leader>b` | buffer |
| `<leader>c` | code |
| `<leader>d` | diagnostic / database / debug |
| `<leader>e` | explorer |
| `<leader>f` | find (Telescope) |
| `<leader>g` | git |
| `<leader>h` | harpoon |
| `<leader>m` | misc (format) |
| `<leader>n` | .NET (dotnet) |
| `<leader>o` | outline (aerial) |
| `<leader>r` | refactor / rename |
| `<leader>s` | split / search |
| `<leader>sn` | noice messages |
| `<leader>t` | test (neotest) |
| `<leader>u` | ui toggles |
| `<leader>w` | window / session |
| `<leader>x` | trouble |

---

## Discoverability

Press `<leader>` and wait — `which-key` shows every available next key with descriptions. This is the fastest way to recall a mapping you forgot.
