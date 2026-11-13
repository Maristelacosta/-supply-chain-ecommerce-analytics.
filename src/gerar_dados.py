import streamlit as st
import pandas as pd

st.set_page_config(page_title="Supply Chain Analytics", layout="wide")

st.title("📦 Painel de Monitoramento de Supply Chain & E-commerce")
st.markdown("Acompanhamento de indicadores logísticos (**OTIF**), desempenho de transportadoras e risco de ruptura.")

# Carregamento dos dados
@st.cache_data
def carregar_dados():
    fornecedores = pd.read_csv("data/fornecedores.csv")
    produtos = pd.read_csv("data/produtos.csv")
    pedidos = pd.read_csv("data/pedidos.csv")
    return fornecedores, produtos, pedidos

df_fornecedores, df_produtos, df_pedidos = carregar_dados()

# Cálculo de métricas de entrega
df_pedidos["on_time"] = df_pedidos["data_entrega_real"] <= df_pedidos["data_prevista_entrega"]
df_pedidos["in_full"] = df_pedidos["qtd_entregue"] == df_pedidos["qtd_solicitada"]
df_pedidos["otif"] = df_pedidos["on_time"] & df_pedidos["in_full"]

# KPIs Principais no topo
col1, col2, col3, col4 = st.columns(4)
col1.metric("Total de Pedidos", len(df_pedidos))
col2.metric("OTIF Geral", f"{df_pedidos['otif'].mean() * 100:.1f}%")
col3.metric("Entregas no Prazo (On-Time)", f"{df_pedidos['on_time'].mean() * 100:.1f}%")
col4.metric("Frete Médio", f"R$ {df_pedidos['valor_frete'].mean():.2f}")

st.divider()

# Seção de Alerta de Ruptura
st.subheader("🚨 Alerta de Ruptura de Estoque (Abaixo do Mínimo)")
ruptura = df_produtos[df_produtos["estoque_atual"] < df_produtos["estoque_minimo"]].merge(
    df_fornecedores, on="id_fornecedor"
)
st.dataframe(
    ruptura[["id_produto", "nome_produto", "estoque_atual", "estoque_minimo", "nome_fornecedor", "lead_time_acordado_dias"]],
    use_container_width=True,
    hide_index=True
)

# Gráfico de Desempenho por Transportadora
st.subheader("🚚 Taxa de Entregas no Prazo (On-Time) por Transportadora")
perf_transp = df_pedidos.groupby("transportadora")["on_time"].mean() * 100
st.bar_chart(perf_transp)
