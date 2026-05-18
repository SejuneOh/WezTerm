-- GitHub Actions, k8s, docker-compose, Azure Pipelines 등 스키마 자동 적용
return {
  settings = {
    yaml = {
      schemaStore = {
        enable = false, -- schemastore.nvim이 제공하므로 내장 카탈로그는 비활성화
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
      validate = true,
      hover = true,
      completion = true,
    },
  },
}
