-- TOML LSP (pyproject.toml, Cargo.toml 등)
return {
  settings = {
    evenBetterToml = {
      schema = {
        enabled = true,
        catalogs = { "https://www.schemastore.org/api/json/catalog.json" },
      },
    },
  },
}
