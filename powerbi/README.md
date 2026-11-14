# Projeto Power BI — Supply Chain & E-commerce

Este projeto prepara o repositório para criar no Power BI Desktop um painel de **OTIF, entregas, frete e risco de ruptura**. Os scripts usam os CSVs já esperados pelo projeto (`data/fornecedores.csv`, `data/produtos.csv` e `data/pedidos.csv`).

> O arquivo `.pbix` é criado e salvo pelo Power BI Desktop; este repositório contém as consultas Power Query, medidas DAX, tema e instruções para montar o relatório.

## Como começar

1. Gere ou coloque os três arquivos CSV na pasta `data/` do projeto. Consulte o README principal sobre a geração dos dados.
2. Abra o Power BI Desktop e escolha **Obter dados → Consulta nula → Editor avançado**.
3. Crie uma consulta para cada arquivo `.m` desta pasta. Em cada consulta, ajuste `CaminhoDados` no início do script para o caminho local da pasta `data` (ex.: `C:\Projetos\Supply-chain-ecommerce-analytics.\data`). Renomeie as consultas para `Fornecedores`, `Produtos` e `Pedidos`.
4. Confira os tipos de dados e selecione **Fechar e aplicar**.
5. No modelo, crie os relacionamentos:
   - `Fornecedores[id_fornecedor]` 1 → * `Produtos[id_fornecedor]`.
   - `Produtos[id_produto]` 1 → * `Pedidos[id_produto]`, **se esse campo existir no CSV de pedidos**. Se não existir, não crie esse relacionamento: as métricas de pedidos continuarão funcionando, mas não poderão ser detalhadas por produto.
   - `Calendario[Data]` 1 → * `Pedidos[data_entrega_real]`.
6. Crie a tabela calendário e as medidas usando `Medidas.dax` (cada bloco `MEASURE` deve ser criado como uma medida; `Calendario` é uma tabela calculada).
7. Importe `tema.json` em **Exibir → Temas → Procurar temas**.

## Páginas sugeridas

- **Visão executiva:** Pedidos, OTIF, On-Time, In-Full e frete médio; tendência mensal de OTIF e entregas no prazo.
- **Entregas:** OTIF e atraso por transportadora, evolução por mês e tabela de pedidos para investigação.
- **Estoque:** produtos abaixo do mínimo, estoque atual versus mínimo e fornecedores/lead time.

## Campos utilizados

Os nomes abaixo são os referenciados pelo código existente no repositório: fornecedores (`id_fornecedor`, `nome_fornecedor`, `lead_time_acordado_dias`); produtos (`id_produto`, `nome_produto`, `estoque_atual`, `estoque_minimo`, `id_fornecedor`); pedidos (`data_entrega_real`, `data_prevista_entrega`, `qtd_entregue`, `qtd_solicitada`, `valor_frete`, `transportadora`). A consulta de pedidos preserva campos adicionais, inclusive IDs, para permitir relacionamentos quando disponíveis.

A classificação de ruptura abaixo segue a regra documentada no projeto: estoque atual menor que o mínimo. Se a regra operacional for incluir igualdade, altere `<` para `<=` na coluna `Risco de Ruptura` da consulta `Produtos.m`.

## Limitações

Os scripts assumem CSV separado por ponto e vírgula e codificado em UTF-8, conforme padrão brasileiro. Se os arquivos usarem vírgula, altere `Delimiter=";"` para `Delimiter=","`. A interpretação de datas usa `pt-BR`. Verifique os cabeçalhos reais dos CSVs antes de publicar e ajuste os tipos caso necessário.
