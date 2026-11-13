# 📦 Análise de Supply Chain e Alerta de Ruptura de Estoque (E-commerce)

Projeto prático de análise de dados logísticos desenvolvido em **Python** e **SQL** para monitoramento de indicadores-chave de desempenho (KPIs), previsão de cobertura e automação de alertas de ruptura de estoque.

---

## 🎯 Objetivos do Projeto
* **OTIF (On-Time In-Full):** Medir o percentual de pedidos entregues dentro do prazo prometido e na quantidade exata solicitada.
* **Lead Time de Entrega:** Calcular o tempo médio decorrido entre a realização do pedido e a entrega final ao cliente.
* **Cobertura de Estoque:** Estimar para quantos dias o saldo atual será suficiente com base na demanda média diária dos últimos 30 dias.
* **Automação de Alertas:** Identificar produtos em estado crítico e exportar relatórios gerenciais prontos para a equipe de compras em **Excel (`.xlsx`)** e **CSV**.

---

## 🛠️ Tecnologias e Bibliotecas Utilizadas
* **SQL (SQLite):** Modelagem relacional, consultas analíticas com CTEs (`WITH`), agregações e cálculo de métricas diretamente no banco de dados.
* **Python (Pandas / cuDF):** Manipulação de DataFrames, aplicação de regras de negócio e aceleração de processamento via GPU.
* **OpenPyXL:** Exportação automatizada de relatórios estruturados em múltiplas abas.
* **Google Colab:** Ambiente de desenvolvimento e execução em nuvem.

---

## 📊 Regras de Negócio Aplicadas

Um produto (SKU) é classificado automaticamente com **Risco de Ruptura** quando atinge pelo menos uma das condições abaixo:

1. **Nível Crítico de Segurança:** O saldo atual em estoque é menor ou igual ao estoque de segurança definido (`Saldo Atual <= Estoque de Segurança`).
2. **Risco de Desabastecimento:** Os dias de cobertura restantes são menores ou iguais ao tempo que o fornecedor leva para entregar uma nova remessa (`Dias de Cobertura <= Lead Time do Fornecedor`).

---

## 📂 Estrutura do Projeto

```text
├── analise_supply_chain_ecommerce.ipynb   # Notebook completo com criação do banco, queries SQL e scripts Python
├── alertas_ruptura_YYYY-MM-DD.csv         # Relatório filtrado apenas com os SKUs críticos (padrão CSV brasileiro)
├── relatorio_supply_chain_YYYY-MM-DD.xlsx # Planilha completa com abas separadas (Indicadores Gerais e Alertas Críticos)
└── README.md                              # Documentação completa do projeto
```

---

## 🚀 Como Executar o Projeto

1. Abra o arquivo `analise_supply_chain_ecommerce.ipynb` no **Google Colab** (ou em um ambiente Jupyter local).
2. Instale a biblioteca de exportação para Excel executando:
   ```bash
   pip install openpyxl
   ```
3. Execute todas as células do notebook. O script irá:
   * Criar o banco de dados relacional em memória (`tabela_estoque` e `tabela_pedidos`).
   * Popular as tabelas com dados simulados de vendas e entregas dos últimos 30 dias.
   * Executar a consulta SQL para consolidar os indicadores.
   * Gerar e salvar os arquivos `.csv` e `.xlsx` com a data atual.

---

## 📈 Próximos Passos (Melhorias Futuras)
* [ ] Criar um painel interativo (Dashboard) utilizando **Streamlit** para visualização gráfica dos indicadores.
* [ ] Implementar disparo automático de alertas via **E-mail** ou **Telegram**.
* [ ] Conectar o script a um banco de dados em produção (**PostgreSQL** ou **BigQuery**).
