-- appsettings.json, package.json, tsconfig.json, csproj 등 스키마 자동 적용
return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
