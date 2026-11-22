# 1. LEITURA DOS DADOS BRUTOS
ler_dados_projeto <- function(arq_cad, arq_2023, arq_2024, arq_2025) {
  tipos_cadastro <- readr::cols(
    codigo = readr::col_character(),
    nome = readr::col_character(),
    formato = readr::col_character(),
    area_m2 = readr::col_double()
  )
  
  tipos_faturamento <- readr::cols(
    codigo = readr::col_character(),
    jan = readr::col_double(),
    fev = readr::col_double(),
    mar = readr::col_double(),
    abr = readr::col_double(),
    mai = readr::col_double(),
    jun = readr::col_double(),
    jul = readr::col_double(),
    ago = readr::col_double(),
    set = readr::col_double(),
    out = readr::col_double(),
    nov = readr::col_double(),
    dez = readr::col_double()
  )
  
  cadastro <- readr::read_csv2(
    arq_cad,
    col_types = tipos_cadastro,
    locale = readr::locale(encoding = "latin1"),
    na = c("", "NA", "-", " ")
  )
  
  d2023 <- readr::read_csv2(
    arq_2023,
    col_types = tipos_faturamento,
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA", "-", " ")
  ) |>
    dplyr::mutate(ano = 2023L)
  
  d2024 <- readr::read_csv2(
    arq_2024,
    col_types = tipos_faturamento,
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA", "-", " ")
  ) |>
    dplyr::mutate(ano = 2024L)
  
  d2025 <- readr::read_csv2(
    arq_2025,
    col_types = tipos_faturamento,
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA", "-", " ")
  ) |>
    dplyr::mutate(ano = 2025L)
  
  list(cadastro = cadastro, d2023 = d2023, d2024 = d2024, d2025 = d2025)
}

