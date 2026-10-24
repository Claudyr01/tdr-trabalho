# Trabalho Intermediário — Tecnologia de Dados e Reprodutibilidade (TDR)

## 1. Descrição do Projeto
Este repositório contém a análise reprodutível de faturamento e cadastro simulados referentes aos anos de 2023, 2024 e 2025. O pipeline de dados realiza a limpeza, consolidação e geração automática do relatório de análise em formato HTML utilizando o pacote `{targets}` e o ecossistema Quarto.

## 2. Requisitos Prévios
Para reproduzir este projeto, é necessário ter instalado no ambiente:
- **R** (versão $\ge$ 4.2)
- **Quarto CLI** (versão $\ge$ 1.3)
- Gerenciador de pacotes **`renv`**

## 3. Como Reproduzir o Projeto
A reprodução total do ambiente e do pipeline é realizada em apenas dois comandos no R:

```R
# 1. Restaurar o ambiente isolado de pacotes
renv::restore()

# 2. Executar o pipeline de dados e renderizar o relatório
targets::tar_make()
cat << 'EOF' > README.md
# Trabalho Intermediário — Tecnologia de Dados e Reprodutibilidade (TDR)

## 1. Descrição do Projeto
Este repositório contém a análise reprodutível de faturamento e cadastro simulados referentes aos anos de 2023, 2024 e 2025. O pipeline de dados realiza a limpeza, consolidação e geração automática do relatório de análise em formato HTML utilizando o pacote `{targets}` e o ecossistema Quarto.

## 2. Requisitos Prévios
Para reproduzir este projeto, é necessário ter instalado no ambiente:
- **R** (versão $\ge$ 4.2)
- **Quarto CLI** (versão $\ge$ 1.3)
- Gerenciador de pacotes **`renv`**

## 3. Como Reproduzir o Projeto
A reprodução total do ambiente e do pipeline é realizada em apenas dois comandos no R:

```R
# 1. Restaurar o ambiente isolado de pacotes
renv::restore()

# 2. Executar o pipeline de dados e renderizar o relatório
targets::tar_make()
