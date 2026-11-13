# 📦 Supply Chain & E-commerce Analytics

![Python](https://shields.io)
![Pandas](https://shields.io)
![SQL](https://shields.io)
![Streamlit](https://shields.io)

## 🎯 Objetivo do Projeto
Simular e monitorar a operação logística de ponta a ponta de um e-commerce, transformando dados transacionais de pedidos, fornecedores e estoque em indicadores estratégicos para tomada de decisão e prevenção de ruptura.

## 📊 Principais Indicadores (KPIs) Monitorados
* **OTIF (*On-Time In-Full*):** Percentual de pedidos entregues dentro do prazo prometido e com a quantidade exata solicitada pelo cliente.
* **Desempenho por Transportadora:** Taxa de pontualidade (*On-Time*) comparativa entre operadores logísticos.
* **Alerta de Ruptura de Estoque:** Identificação automática de SKUs abaixo do estoque mínimo, cruzando com o *lead time* acordado de cada fornecedor.
* **Custo Médio de Frete:** Acompanhamento financeiro das entregas.

## 🛠️ Tecnologias e Estrutura
* **`data/`**: Dicionário de dados e bases sintéticas (`fornecedores.csv`, `produtos.csv`, `pedidos.csv`) simulando 90 dias de operação.
* **`sql/`**: Consultas analíticas estruturadas para extração de métricas de pontualidade e déficit de inventário.
* **`src/`**:
  * `gerar_dados.py`: Script de geração de dados reproduzíveis com regras de negócio logísticas.
  * `app.py`: Aplicação web interativa desenvolvida em **Streamlit** para visualização dos KPIs.

## 🚀 Como Executar Localmente

1. Clone o repositório:
   ```bash
   git clone https://github.com
   ```
2. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
3. Gere a base de dados (opcional, caso queira recriar os CSVs):
   ```bash
   python src/gerar_dados.py
   ```
4. Inicie o painel interativo:
   ```bash
   streamlit run src/app.py
   ```

---
👩‍💻 **Desenvolvido por Maristela Aparecida Costa**  
🎓 Graduada em Sistemas de Informação | Pós-graduanda em BI, Big Data & Data Science | Especializanda em Cibersegurança  
🔗 [LinkedIn](https://linkedin.com)
