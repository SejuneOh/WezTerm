# Database Integration

Query PostgreSQL and MSSQL directly from Neovim using the `vim-dadbod` stack.

## Plugins Installed

- [`vim-dadbod`](https://github.com/tpope/vim-dadbod) — connection and query engine
- [`vim-dadbod-ui`](https://github.com/kristijanhusak/vim-dadbod-ui) — sidebar UI (connections, tables, queries)
- [`vim-dadbod-completion`](https://github.com/kristijanhusak/vim-dadbod-completion) — table/column autocomplete via nvim-cmp

## External CLI Prerequisites

Each DB backend requires its own command-line client:

### PostgreSQL

```bash
sudo apt install postgresql-client
```

Verify: `psql --version`

### MSSQL (sqlcmd)

Installing Microsoft's SQL Server tools on Ubuntu / WSL2:

```bash
# Import Microsoft's signing key
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# Add the Microsoft Ubuntu package repo (adjust for your Ubuntu version)
curl https://packages.microsoft.com/config/ubuntu/24.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

sudo apt update
sudo ACCEPT_EULA=Y apt install -y mssql-tools18 unixodbc-dev

# Add sqlcmd to PATH
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.zshrc
source ~/.zshrc
```

Verify: `sqlcmd -?`

## Adding Connections

Inside Neovim:

1. Press `<leader>da` — `DBUIAddConnection` prompt opens.
2. Paste a connection URL:
   - PostgreSQL: `postgresql://user:password@localhost:5432/dbname`
   - MSSQL: `sqlserver://user:password@localhost:1433?database=dbname`
3. Give the connection a name (e.g., `pg_local`, `mssql_dev`).

Connections are stored at `~/.local/share/nvim/db_ui/connections.json`.

**Tip:** Do not commit credentials. Use an env var in your shell instead:

```bash
export DATABASE_URL="postgresql://user:pass@localhost:5432/dbname"
```

`dadbod-ui` automatically picks up `$DATABASE_URL`.

## Keymaps

| Keys | Action |
|------|--------|
| `<leader>du` | Toggle DB sidebar |
| `<leader>df` | Find DB query buffer |
| `<leader>da` | Add new connection |
| `<leader>db` (cursor on query) | Execute query under cursor |
| `<CR>` (in sidebar, on connection) | Connect / expand |
| `<CR>` (in sidebar, on table) | Open table preview |

## Running a Query

1. `<leader>du` opens the sidebar.
2. Expand a connection → `New query` creates a temporary `.sql` buffer.
3. Write SQL and press `<leader>db` with cursor on the statement.
4. Results appear in a split below.

Autocomplete (table names, column names) works automatically in `.sql` buffers thanks to `vim-dadbod-completion`.
