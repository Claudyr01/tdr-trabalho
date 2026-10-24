library(targets)
library(tarchetypes)

tar_source()

tar_option_set(
  packages = c("readr", "dplyr", "tidyr", "purrr", "ggplot2", "quarto", "knitr")
)

list(
  tar_target(arq_cad, "dados/cadastro.csv", format = "file"),
  tar_target(arq_2023, "dados/faturamento_2023.csv", format = "file"),
  tar_target(arq_2024, "dados/faturamento_2024.csv", format = "file"),
  tar_target(arq_2025, "dados/faturamento_2025.csv", format = "file"),

  tar_target(dados_brutos, ler_dados_projeto(arq_cad, arq_2023, arq_2024, arq_2025)),
  tar_target(tabela_arrumada, processar_tabela_arrumada(dados_brutos)),
  tar_target(conferencia, conferir_dados(tabela_arrumada)),
  tar_target(resumo_unidade, gerar_resumo_unidade(tabela_arrumada)),
  tar_target(resumo_categoria, gerar_resumo_categoria(tabela_arrumada)),
  tar_target(resumo_categoria_ano, gerar_resumo_categoria_ano(tabela_arrumada)),
  
  tar_target(modelo_log, ajustar_modelo_log(tabela_arrumada)),
  
  tar_quarto(relatorio, "relatorio.qmd")
)
