# Roadmap

Installation phases, in recommended order. Mirrors `SETUP.json`.

## Completed

- [x] **initial_installs** — WezTerm, Neovim 0.10+, git, ripgrep, node, Nerd Font
- [x] **config_file_structure** — `~/.config/nvim/` with `init.lua` + `lua/plugins/`
- [x] **plugin_manager** — `lazy.nvim` bootstrapped in `init.lua`
- [x] **ui_and_navigation** — catppuccin, nvim-tree, telescope, which-key, alpha, bufferline, lualine, dressing
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
- [x] **linting** — nvim-lint
      - Linters per filetype: eslint_d (js/ts), pylint (python)
      - Runs on BufEnter / BufWritePost / InsertLeave
      - Manual trigger: `<leader>ml`
- [x] **git_integration** — gitsigns.nvim + lazygit.nvim
      - gitsigns: inline change markers, hunk stage/reset/preview, blame
      - lazygit: full terminal git UI via `<leader>gg`
      - External: lazygit binary installed at `~/.local/bin/lazygit`
- [x] **database_client** — vim-dadbod + vim-dadbod-ui + vim-dadbod-completion
      - Supports PostgreSQL (via `psql`) and MSSQL (via `sqlcmd`)
      - Sidebar for connection/table browsing + query execution + autocomplete
      - Setup details in `docs/DATABASE.md`

- [x] **basic_options** — `lua/config/options.lua`
      - Line numbers (absolute + relative), 2-space indent, clipboard sharing
      - Smart search (case-insensitive unless capital), cursorline, scrolloff=8
      - splitright / splitbelow, signcolumn always on, undofile for persistent undo
      - termguicolors, mouse enabled, updatetime=250, timeoutlen=500

## Pending

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
- **Transparent background** — both WezTerm (`window_background_opacity = 0.92`) and catppuccin (`transparent_background = true`) so a single change affects the whole stack.
- **Primary language: C#** — when choosing LSP/formatter/linter for future work, include C# by default.
