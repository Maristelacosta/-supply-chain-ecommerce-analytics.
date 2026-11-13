# 📦 Análise de Supply Chain & E-commerce (End-to-End)

> Pipeline completo de dados voltado à otimização da cadeia de suprimentos, monitoramento de indicadores logísticos críticos (**OTIF**, **Lead Time**) e predição/alerta de **ruptura de estoque (Stockout)**, integrando Python, SQL e Power BI.

---

## 🎯 1. Visão Geral do Projeto
No cenário de e-commerce atual, a eficiência logística é um diferencial competitivo direto. Este projeto simula um ambiente corporativo real onde dados brutos de pedidos, entregas e estoque foram tratados, armazenados e transformados em inteligência de negócio acionável.

O fluxo do projeto abrange:
1. **Engenharia e Limpeza de Dados (Python):** Tratamento de valores nulos, padronização de formatos e simulação/enriquecimento de dados.
2. **Armazenamento e Consultas Analíticas (SQL):** Criação de visões estruturadas para cálculo de indicadores de desempenho logístico.
3. **Data Storytelling & Business Intelligence (Power BI):** Desenvolvimento de um dashboard interativo para monitoramento executivo.

---

## 🛠️ 2. Arquitetura e Tecnologias Utilizadas

O projeto utiliza o ecossistema padrão de engenharia e análise de dados:

* **Linguagem:** Python 3.x (`Pandas`, `NumPy`) — Limpeza e pré-processamento.
* **Banco de Dados / Consultas:** SQL (PostgreSQL / SQLite) — Modelagem relacional e queries analíticas.
* **Ferramenta de BI:** Power BI Desktop — Modelagem final (*Star Schema*), DAX e Dashboard Interativo.
* **Controle de Versão:** Git & GitHub.

---

## 📊 3. Principais Indicadores de Negócio (KPIs)

O painel e as consultas SQL foram desenhados para monitorar as seguintes métricas:

* **OTIF (On-Time In-Full):** Percentual de pedidos entregues no prazo acordado e com a quantidade/itens corretos.
* **Lead Time Médio:** Tempo total (em dias) desde a aprovação do pedido até a entrega final na ponta.
* **Taxa de Ruptura de Estoque (Stockout Rate):** Identificação de itens que ficaram indisponíveis no momento da compra, medindo a perda potencial de receita.
* **Custo Médio de Frete:** Relação entre o volume/peso transportado e o custo operacional logístico por rota.

---

## 🐍 4. Etapa 1: Engenharia de Dados com Python
Os dados brutos passaram por um processo de higienização via script Python. As principais etapas incluíram:
* Remoção de duplicatas e tratamento de *missing values* em colunas críticas de data.
* Engenharia de atributos (*Feature Engineering*), como o cálculo do tempo de ciclo de entrega direto no *DataFrame*.
* Exportação dos dados limpos para carga no banco de dados relacional.

*(O código completo está disponível na pasta `/scripts` deste repositório).*

---

## 🗄️ 5. Etapa 2: Consultas Analíticas com SQL
No banco de dados, foram estruturadas queries para extração dos KPIs principais. Exemplo de consulta utilizada para calcular o Lead Time médio por região:

```sql
SELECT 
    regiao_destino,
    COUNT(id_pedido) AS total_pedidos,
    ROUND(AVG(julianday(data_entrega) - julianday(data_pedido)), 2) AS lead_time_medio_dias
FROM f_pedidos
WHERE status_entrega = 'Entregue'
GROUP BY regiao_destino
ORDER BY lead_time_medio_dias DESC;
