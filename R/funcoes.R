# R/funcoes.R

# 1. FUNÇÃO DE LEITURA
# Lê os dados de cadastro e anuais garantindo codificação UTF-8, tratamento de
# ausentes e conversão preventiva da chave para texto (character).
ler_dados_projeto <- function(arq_cad, arq_2023, arq_2024, arq_2025) {
  
  # Leitura do cadastro
  cadastro <- readr::read_csv2(
    arq_cad,
    locale = readr::locale(encoding = "UTF-8"),
    na = c("", "NA", "-", " "),
    show_col_types = FALSE
  )
  
  # Leitura dos três anos
  d2023 <- readr::read_csv2(arq_2023, locale = readr::locale(encoding = "UTF-8"), na = c("", "NA", "-", " "), show_col_types = FALSE) |> dplyr::mutate(ano = 2023)
  d2024 <- readr::read_csv2(arq_2024, locale = readr::locale(encoding = "UTF-8"), na = c("", "NA", "-", " "), show_col_types = FALSE) |> dplyr::mutate(ano = 2024)
  d2025 <- readr::read_csv2(arq_2025, locale = readr::locale(encoding = "UTF-8"), na = c("", "NA", "-", " "), show_col_types = FALSE) |> dplyr::mutate(ano = 2025)
  
  list(cadastro = cadastro, d2023 = d2023, d2024 = d2024, d2025 = d2025)
}

# 2. FUNÇÃO DE ARRUMAÇÃO E JUNÇÃO
# Empilha os anos, ajusta tipos de chave para evitar conflito no join,
# converte para formato longo (meses) e calcula a medida relativa.
processar_tabela_arrumada <- function(lista_dados) {
  
  dados_empilhados <- dplyr::bind_rows(lista_dados$d2023, lista_dados$d2024, lista_dados$d2025)
  
  # Identificação dinâmica da chave primaria (codigo ou id_unidade)
  col_id <- intersect(c("codigo", "id_unidade", "id"), names(lista_dados$cadastro))[1]
  
  # Padronização da chave para character em ambas as pontas
  cadastro_limpo <- lista_dados$cadastro |>
    dplyr::mutate(dplyr::across(dplyr::all_of(col_id), as.character))
  
  dados_empilhados_limpos <- dados_empilhados |>
    dplyr::mutate(dplyr::across(dplyr::all_of(col_id), as.character))
  
  # Identificação dinâmica do porte (primeira coluna numérica do cadastro)
  col_porte <- cadastro_limpo |>
    dplyr::select(where(is.numeric)) |>
    names() |>
    _[1]
  
  # Identificação dinâmica da categoria
  col_categoria <- setdiff(names(cadastro_limpo), c(col_id, "nome", col_porte))[1]
  
  # Pivotagem das colunas de meses para formato longo
  meses_ref <- c("jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez")
  meses_presentes <- intersect(meses_ref, names(dados_empilhados_limpos))
  
  tabela_longa <- dados_empilhados_limpos |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(meses_presentes),
      names_to = "mes",
      values_to = "medicao"
    ) |>
    dplyr::mutate(
      medicao = as.numeric(medicao),
      mes = factor(mes, levels = meses_ref, ordered = TRUE)
    )
  
  # Junção muitos-para-um e cálculo da medida relativa
  tabela_arrumada <- tabela_longa |>
    dplyr::left_join(cadastro_limpo, by = col_id, relationship = "many-to-one") |>
    dplyr::mutate(
      medida_relativa = medicao / .data[[col_porte]],
      categoria = .data[[col_categoria]],
      id_chave = .data[[col_id]]
    )
  
  return(tabela_arrumada)
}

# 3. FUNÇÃO DE CONFERÊNCIA
# Gera a tabela de resumo do LEIA-ME.txt
conferir_dados <- function(tabela_arrumada) {
  tabela_arrumada |>
    dplyr::group_by(ano) |>
    dplyr::summarise(
      n_linhas = dplyr::n(),
      soma_medida = sum(medida_relativa, na.rm = TRUE),
      meses_ausentes = sum(is.na(medida_relativa)),
      .groups = "drop"
    )
}

# 4. FUNÇÕES DE RESUMO ESTATÍSTICO
gerar_resumo_unidade <- function(tabela) {
  tabela |>
    dplyr::group_by(id_chave) |>
    dplyr::summarise(
      media_relativa = mean(medida_relativa, na.rm = TRUE),
      total_acumulado = sum(medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}

gerar_resumo_categoria <- function(tabela) {
  tabela |>
    dplyr::group_by(categoria) |>
    dplyr::summarise(
      media_relativa = mean(medida_relativa, na.rm = TRUE),
      mediana_relativa = median(medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}

gerar_resumo_categoria_ano <- function(tabela) {
  tabela |>
    dplyr::group_by(categoria, ano) |>
    dplyr::summarise(
      media_relativa = mean(medida_relativa, na.rm = TRUE),
      .groups = "drop"
    )
}
