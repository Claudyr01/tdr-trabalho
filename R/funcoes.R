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

# 2. ARRUMAÇÃO E JUNÇÃO COM O CADASTRO
processar_tabela_arrumada <- function(lista_dados) {
  meses_ref <- c(
    "jan", "fev", "mar", "abr", "mai", "jun",
    "jul", "ago", "set", "out", "nov", "dez"
  )

  dados_empilhados <- dplyr::bind_rows(
    lista_dados$d2023,
    lista_dados$d2024,
    lista_dados$d2025
  )

  tabela_longa <- dados_empilhados |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(meses_ref),
      names_to = "mes",
      values_to = "faturamento"
    ) |>
    dplyr::mutate(
      mes = factor(.data$mes, levels = meses_ref, ordered = TRUE)
    )

  tabela_arrumada <- tabela_longa |>
    dplyr::left_join(
      lista_dados$cadastro,
      by = "codigo",
      relationship = "many-to-one"
    ) |>
    dplyr::mutate(
      medida_relativa = .data$faturamento / .data$area_m2
    )

  tabela_arrumada
}

# 3. FUNÇÃO DE CONFERÊNCIA (LEIA-ME.txt)
conferir_dados <- function(tabela_arrumada) {
  tabela_arrumada |>
    dplyr::group_by(.data$ano) |>
    dplyr::summarise(
      n_linhas = dplyr::n(),
      meses_ausentes = sum(is.na(.data$faturamento)),
      soma_valores = sum(.data$faturamento, na.rm = TRUE),
      .groups = "drop"
    )
}

# 4. FUNÇÕES DE RESUMO ESTATÍSTICO
gerar_resumo_unidade <- function(tabela) {
  tabela |>
    dplyr::group_by(.data$codigo, .data$nome, .data$formato) |>
    dplyr::summarise(
      meses_registrados = sum(!is.na(.data$faturamento)),
      faturamento_total = sum(.data$faturamento, na.rm = TRUE),
      media_relativa = mean(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}

gerar_resumo_categoria <- function(tabela) {
  tabela |>
    dplyr::group_by(.data$formato) |>
    dplyr::summarise(
      media_relativa = mean(.data$medida_relativa, na.rm = TRUE),
      mediana_relativa = stats::median(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}

gerar_resumo_categoria_ano <- function(tabela) {
  tabela |>
    dplyr::group_by(.data$formato, .data$ano) |>
    dplyr::summarise(
      media_relativa = mean(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}

# 5. MODELO ESTATÍSTICO OPCIONAL
ajustar_modelo_log <- function(tabela_arrumada) {
  tabela_filtrada <- tabela_arrumada |>
    dplyr::filter(!is.na(.data$medida_relativa), .data$medida_relativa > 0)

  stats::lm(log(medida_relativa) ~ ano + mes + formato, data = tabela_filtrada)
}

# 6. RESUMOS AUXILIARES PARA O RELATÓRIO
gerar_resumos_relatorio <- function(tabela_arrumada) {
  total_unidades_cad <- dplyr::n_distinct(tabela_arrumada$codigo)

  unidade_sem_med <- tabela_arrumada |>
    dplyr::group_by(.data$codigo) |>
    dplyr::summarise(
      total_obs = sum(!is.na(.data$faturamento)),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$total_obs == 0) |>
    dplyr::pull(.data$codigo)

  unidades_com_medicao <- total_unidades_cad - length(unidade_sem_med)

  sazonalidade_geral <- tabela_arrumada |>
    dplyr::group_by(.data$mes) |>
    dplyr::summarise(
      media_mensal = mean(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )

  sazonalidade_anual <- tabela_arrumada |>
    dplyr::group_by(.data$ano, .data$mes) |>
    dplyr::summarise(
      media_mensal = mean(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )

  resumo_anual <- tabela_arrumada |>
    dplyr::group_by(.data$ano) |>
    dplyr::summarise(
      media_relativa = mean(.data$medida_relativa, na.rm = TRUE),
      mediana_relativa = stats::median(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )

  mes_maior <- sazonalidade_geral |>
    dplyr::filter(.data$media_mensal == max(.data$media_mensal, na.rm = TRUE)) |>
    dplyr::pull(.data$mes) |>
    as.character()
  val_maior <- max(sazonalidade_geral$media_mensal, na.rm = TRUE)

  mes_menor <- sazonalidade_geral |>
    dplyr::filter(.data$media_mensal == min(.data$media_mensal, na.rm = TRUE)) |>
    dplyr::pull(.data$mes) |>
    as.character()
  val_menor <- min(sazonalidade_geral$media_mensal, na.rm = TRUE)

  media_2023 <- resumo_anual |>
    dplyr::filter(.data$ano == 2023L) |>
    dplyr::pull(.data$media_relativa)
  media_2025 <- resumo_anual |>
    dplyr::filter(.data$ano == 2025L) |>
    dplyr::pull(.data$media_relativa)
  var_pct_23_25 <- ((media_2025 - media_2023) / media_2023) * 100

  cat_resumo <- tabela_arrumada |>
    dplyr::group_by(.data$formato) |>
    dplyr::summarise(
      media_relativa = mean(.data$medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )

  cat_maior <- cat_resumo |>
    dplyr::filter(.data$media_relativa == max(.data$media_relativa, na.rm = TRUE)) |>
    dplyr::pull(.data$formato) |>
    as.character()
  val_cat_maior <- max(cat_resumo$media_relativa, na.rm = TRUE)

  cat_menor <- cat_resumo |>
    dplyr::filter(.data$media_relativa == min(.data$media_relativa, na.rm = TRUE)) |>
    dplyr::pull(.data$formato) |>
    as.character()
  val_cat_menor <- min(cat_resumo$media_relativa, na.rm = TRUE)

  list(
    total_unidades_cad = total_unidades_cad,
    unidade_sem_med = unidade_sem_med,
    unidades_com_medicao = unidades_com_medicao,
    sazonalidade_anual = sazonalidade_anual,
    resumo_anual = resumo_anual,
    mes_maior = mes_maior,
    val_maior = val_maior,
    mes_menor = mes_menor,
    val_menor = val_menor,
    media_2023 = media_2023,
    media_2025 = media_2025,
    var_pct_23_25 = var_pct_23_25,
    cat_maior = cat_maior,
    val_cat_maior = val_cat_maior,
    cat_menor = cat_menor,
    val_cat_menor = val_cat_menor
  )
}
