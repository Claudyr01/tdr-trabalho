# Trabalho Intermediário — Tecnologia de Dados Reproduzíveis (TDR)

**Aluno (Login):** `claudyr01`  
**Tema:** Faturamento das lojas de uma rede de varejo (em milhares de reais)

## Descrição e Decisões Metodológicas

- **Meses sem registro:** Desconsiderados no cálculo das estatísticas (`na.rm = TRUE`).
- **Lojas sem medição:** A loja `LJ01` (Mercadinho Central) consta apenas no cadastro, sem faturamento registrado.
- **Modelo opcional:** Não foi incluído nesta entrega.

## Estrutura do Repositório

- `dados/`: Arquivos originais (`LEIA-ME.txt`, `cadastro.csv`, `faturamento_2023.csv`, `faturamento_2024.csv`, `faturamento_2025.csv`).
- `R/funcoes.R`: Funções modulares de leitura (`latin1` e `col_types`), validação, união, cálculos e gráficos.
- `_targets.R`: Pipeline reprodutível gerenciado pelo pacote `{targets}`.
- `relatorio.qmd`: Relatório final em Quarto alimentado exclusivamente pelos alvos do `{targets}`.
- `renv.lock` e `.lintr`: Controle determinístico de pacotes e regras de estilo do projeto.

## Como Reproduzir

1. Clone o repositório e abra o R na pasta raiz do projeto.
2. Execute `renv::restore()` para restaurar os pacotes registrados.
3. Execute `targets::tar_make()` para rodar o pipeline completo e gerar `relatorio.html`.

## Declaração de Uso de LLM

Foi utilizada ferramenta de modelo de linguagem (Gemini) como apoio para diagnóstico de erros, organização modular no `{targets}`, revisão de sintaxe Quarto e adequação às regras do `{lintr}`. Todo o código, as decisões analíticas e os resultados foram executados e validados pelo autor.
