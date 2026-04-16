# WezTerm + Neovim Dotfiles

A complete terminal development environment using **WezTerm** and **Neovim**, tuned for a clean, minimal, and productive workflow.

> Works on **WSL2 (Ubuntu)**, macOS, and Linux.

---

## Preview

- Terminal: **WezTerm** with Catppuccin Mocha theme, transparent background, and a tabline plugin
- Editor: **Neovim 0.10+** with LSP-ready plugin stack (file explorer, fuzzy finder, treesitter, etc.)
- Seamless pane navigation between WezTerm and Neovim via `smart-splits`

---

## Table of Contents

- [Requirements](#requirements)
- [Quick Install](#quick-install)
- [Manual Install](#manual-install)
- [WezTerm Setup](#wezterm-setup)
- [Neovim Setup](#neovim-setup)
- [Keybindings Reference](#keybindings-reference)
- [Directory Structure](#directory-structure)
- [For AI Assistants](#for-ai-assistants)

---

## Requirements

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| WezTerm | latest | Terminal emulator |
| Neovim | 0.10+ | Editor |
| Git | any | Plugin installation |
| Node.js | 18+ | LSP servers |
| ripgrep | any | Telescope live grep |
| A Nerd Font | any | Icons (e.g., D2CodingLigature Nerd Font) |

---

## Quick Install

```bash
git clone git@github.com:SejuneOh/WezTerm.git ~/dev/project/WezTerm
cd ~/dev/project/WezTerm
bash scripts/install.sh
```

The install script will:
1. Verify prerequisites
2. Symlink `wezterm/.wezterm.lua` → `~/.wezterm.lua`
3. Symlink `nvim/` → `~/.config/nvim/`
4. Bootstrap Neovim plugins via `lazy.nvim`

---

## Manual Install

### 1. Install prerequisites

**Ubuntu / WSL2:**

```bash
# ripgrep, curl, git
sudo apt update && sudo apt install -y ripgrep curl git

# Node.js (via nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts

# Neovim 0.10+ (manual install — Ubuntu's apt ships older version)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
mkdir -p ~/.local
tar xzf nvim-linux-x86_64.tar.gz -C ~/.local/
mkdir -p ~/.local/bin
ln -sf ~/.local/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
# Make sure ~/.local/bin is in your PATH
```

**macOS:**

```bash
brew install neovim ripgrep node wezterm
```

### 2. Clone this repo

```bash
git clone git@github.com:SejuneOh/WezTerm.git ~/dev/project/WezTerm
```

### 3. Symlink configs

```bash
ln -sf ~/dev/project/WezTerm/wezterm/.wezterm.lua ~/.wezterm.lua
ln -sf ~/dev/project/WezTerm/nvim ~/.config/nvim
```

### 4. Launch Neovim

```bash
nvim
```

`lazy.nvim` will automatically install all plugins on first launch.

---

## WezTerm Setup

### Features

- **Font:** D2CodingLigature Nerd Font (size 10)
- **Theme:** Catppuccin Mocha
- **Background opacity:** 0.92
- **Tabline plugin** for a cleaner tab bar
- **Workspace switcher** (zoxide-backed, fuzzy finder)
- **Smart splits** — one keybinding set navigates both WezTerm panes and Neovim splits

### Plugins

| Plugin | Role |
|--------|------|
| [`tabline.wez`](https://github.com/michaelbrusegard/tabline.wez) | Custom tab bar with icons and themes |
| [`smart_workspace_switcher.wezterm`](https://github.com/MLFlexer/smart_workspace_switcher.wezterm) | zoxide-based workspace jumper |
| [`smart-splits.nvim`](https://github.com/mrjones2014/smart-splits.nvim) | Unified pane/split navigation (WezTerm + Neovim) |

---

## Neovim Setup

Plugin manager: **lazy.nvim** (bootstrapped in `init.lua`).
All plugin specs live in `nvim/lua/plugins/` — one file per plugin.

### Installed Plugins (by category)

#### UI & Navigation
- `catppuccin/nvim` — color scheme (matches WezTerm)
- `nvim-tree.lua` — file explorer
- `telescope.nvim` + `telescope-fzf-native` — fuzzy finder
- `which-key.nvim` — keybinding discovery popup
- `alpha-nvim` — startup dashboard
- `bufferline.nvim` — top tab bar
- `lualine.nvim` — statusline
- `dressing.nvim` — improved input/select UI

#### Session & Window Management
- `auto-session` — per-directory session save/restore
- `vim-maximizer` — toggle split maximize

#### Syntax & Editing Helpers
- `nvim-treesitter` — syntax highlighting & indentation
- `indent-blankline.nvim` — indent guides
- `nvim-autopairs` — auto-close brackets/quotes
- `Comment.nvim` — toggle comments (`gcc`)
- `todo-comments.nvim` — highlight TODO/FIXME/NOTE
- `nvim-surround` — surround text with brackets/quotes
- `substitute.nvim` — register-based substitution

#### Autocomplete & Snippets
- `nvim-cmp` — completion engine
- `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip` — sources
- `LuaSnip`, `friendly-snippets` — snippet engine + collection
- `lspkind.nvim` — completion menu icons

#### LSP
- `mason.nvim`, `mason-lspconfig`, `mason-tool-installer` — installers
- `nvim-lspconfig` — LSP client config
- Servers auto-installed: `lua_ls`, `ts_ls`, `pyright`, `html`, `cssls`, `jsonls`, `omnisharp` (C#)

#### Diagnostics / Formatting / Linting
- `trouble.nvim` — unified diagnostic panel
- `conform.nvim` — stylua / prettier / black+isort / csharpier, with format-on-save
- `nvim-lint` — eslint_d / pylint

#### Git
- `gitsigns.nvim` — inline git signs and hunk actions
- `lazygit.nvim` — launch lazygit CLI in Neovim (`<leader>gg`)

#### Database
- `vim-dadbod` + `vim-dadbod-ui` + `vim-dadbod-completion` — PostgreSQL & MSSQL client
- See [`docs/DATABASE.md`](./docs/DATABASE.md) for connection setup

---

## Keybindings Reference

> Leader key is `\` (default Neovim leader).

### WezTerm

| Keys | Action |
|------|--------|
| `Ctrl+Shift+d` | Split pane horizontally (left/right) |
| `Ctrl+Shift+D` | Split pane vertically (top/bottom) |
| `Ctrl+Shift+w` | Close current pane (with confirmation) |
| `Ctrl+Shift+z` | Toggle pane zoom |
| `Ctrl+c` | Copy (when text is selected; otherwise SIGINT) |
| `Ctrl+v` | Paste |
| `Alt+s` | Workspace switcher (fuzzy finder) |
| `Alt+n` | Switch to previous workspace |
| `Ctrl+h/j/k/l` | Move between panes (and into Neovim splits) |

### Neovim — Navigation

| Keys | Action |
|------|--------|
| `\ee` | Toggle file explorer |
| `\ef` | Open explorer at current file |
| `\ff` | Find files (Telescope) |
| `\fr` | Recent files |
| `\fs` | Live grep (search project) |
| `\fb` | Open buffers |
| `\fh` | Neovim help search |
| `\ft` | List TODO/FIXME comments |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |

### Neovim — Buffers

| Keys | Action |
|------|--------|
| `Tab` / `Shift+Tab` | Next / previous buffer |
| `\1`..`\9` | Go to buffer by ordinal number |
| `\bp` | Pick buffer by letter |
| `\bd` | Close buffer |

### Neovim — Windows & Sessions

| Keys | Action |
|------|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Alt+h/j/k/l` | Resize split |
| `\sm` | Toggle split maximize |
| `\ws` | Save session |
| `\wr` | Restore session |

### Neovim — Editing

| Keys | Action |
|------|--------|
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle selection comment |
| `ysiw"` | Surround word with `"` |
| `cs"'` | Change surrounding `"` → `'` |
| `ds"` | Delete surrounding `"` |
| `s` + motion | Substitute with register |
| `]t` / `[t` | Next / previous TODO comment |

---

## Directory Structure

```
.
├── README.md                  — human-facing docs (this file)
├── SETUP.json                 — machine-readable manifest (for AI assistants)
├── wezterm/
│   └── .wezterm.lua           — WezTerm config
├── nvim/
│   ├── init.lua               — Neovim entry point (bootstraps lazy.nvim)
│   └── lua/plugins/           — one file per plugin spec
├── scripts/
│   └── install.sh             — one-shot installer
└── docs/
    └── ROADMAP.md             — remaining work & installation order
```

---

## For AI Assistants

A machine-readable manifest is provided at [`SETUP.json`](./SETUP.json).
It describes:

- Workflow order (installation phases)
- Each installed component, its role, and verification steps
- Pending items and their dependencies

Use this file to:
- Reproduce the setup on another machine
- Resume installation from where it left off
- Understand the architectural decisions without reading every Lua file

---

## License

MIT
