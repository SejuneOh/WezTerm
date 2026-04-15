# Roadmap

Installation phases, in recommended order. Mirrors `SETUP.json`.

## Completed

- [x] **initial_installs** — WezTerm, Neovim 0.10+, git, ripgrep, node, Nerd Font
- [x] **config_file_structure** — `~/.config/nvim/` with `init.lua` + `lua/plugins/`
- [x] **plugin_manager** — `lazy.nvim` bootstrapped in `init.lua`
- [x] **ui_and_navigation** — tokyonight, nvim-tree, telescope, which-key, alpha, bufferline, lualine, dressing
- [x] **session_and_window_management** — auto-session, vim-maximizer
- [x] **syntax_and_editing_helpers** — treesitter, indent-blankline, autopairs, Comment, todo-comments, surround, substitute
- [x] **autocomplete_and_snippets** — nvim-cmp + cmp-{nvim-lsp,buffer,path,luasnip}, LuaSnip, friendly-snippets, lspkind
- [x] **lsp_setup** — mason, mason-lspconfig, mason-tool-installer, nvim-lspconfig
      - Installed LSP: lua_ls, ts_ls, pyright, html, cssls, jsonls, omnisharp (C#)
- [x] **formatting** — conform.nvim
      - Formatters per filetype: stylua (lua), prettier (web), black+isort (python), csharpier (c#)
      - Format on save enabled (LSP fallback)
- [x] **diagnostics** — trouble.nvim
      - Unified panel for diagnostics, symbols, LSP refs/defs, TODO, quickfix
      - Keymap namespace: `<leader>x`

## Pending

- [ ] **basic_options** — line numbers, tab width, clipboard, search, splits (not a plugin; set in `init.lua` or `lua/config/options.lua`)
- [ ] **basic_keymaps** — leader mappings, save/quit shortcuts

### Note: C# LSP (omnisharp)

`omnisharp` requires the .NET SDK (installed and verified: dotnet 8.0.125).
On a fresh machine, install the SDK first:

```bash
# Ubuntu / WSL2
sudo apt install dotnet-sdk-8.0

# Then re-run Mason install inside Neovim
:MasonInstall omnisharp csharpier
```
- [ ] **lsp_setup** — mason, mason-lspconfig, nvim-lspconfig
      - For C#: `omnisharp` or `csharp_ls`
      - For Lua: `lua_ls`
      - For TypeScript: `ts_ls`
      - For Python: `pyright`
- [ ] **diagnostics** — trouble.nvim
- [ ] **formatting** — conform.nvim
      - For C#: `csharpier`
      - For JS/TS: `prettier`
      - For Lua: `stylua`
      - For Python: `black`, `isort`
- [ ] **linting** — nvim-lint
      - For JS/TS: `eslint_d`
      - For Python: `pylint`
- [ ] **git_integration** — gitsigns.nvim, lazygit.nvim

## Deviations from Reference Tutorial

| Tutorial plugin | Replacement | Reason |
|-----------------|-------------|--------|
| `vim-tmux-navigator` | `smart-splits.nvim` | User runs WezTerm (not tmux). smart-splits unifies WezTerm panes with Neovim splits under one keymap. |

## Design Decisions

- **One plugin per file** — `lua/plugins/*.lua` each returns a `lazy.nvim` spec. Adding a plugin = creating a new file.
- **Global leader namespaces** — registered in `which-key.lua`:
  - `b` — buffer
  - `e` — explorer
  - `f` — find
  - `g` — git
  - `s` — split
  - `w` — window / session
- **Transparent background** — both WezTerm (`window_background_opacity = 0.92`) and tokyonight (`transparent = true`) so a single change affects the whole stack.
- **Primary language: C#** — when choosing LSP/formatter/linter for future work, include C# by default.
