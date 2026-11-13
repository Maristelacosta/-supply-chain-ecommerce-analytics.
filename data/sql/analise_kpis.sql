
import sqlite3
import pandas as pd
import random
from datetime import datetime, timedelta

def criar_banco_e_dados():
    """Cria um banco SQLite em memória, estrutura as tabelas e insere dados simulados."""
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()
    
    # 1. Criação das tabelas
    cursor.execute('''
        CREATE TABLE tabela_estoque (
            sku TEXT PRIMARY KEY,
            nome_produto TEXT,
            saldo_atual INTEGER,
            estoque_seguranca INTEGER,
            lead_time_fornecedor INTEGER
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE tabela_pedidos (
            id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
            sku TEXT,
            quantidade_pedida INTEGER,
            quantidade_entregue INTEGER,
            data_pedido DATE,
            data_prometida DATE,
            data_entrega DATE,
            status TEXT,
            FOREIGN KEY (sku) REFERENCES tabela_estoque(sku)
        )
    ''')
    
    # 2. Inserção de produtos no estoque
    produtos = [
        ('SKU-001', 'Smartphone Pro Max', 15, 20, 7),
        ('SKU-002', 'Fone Bluetooth Noise Cancelling', 120, 30, 5),
        ('SKU-003', 'Notebook Ultrafino 16GB', 8, 10, 10),
        ('SKU-004', 'Monitor Gamer 27 Polegadas', 45, 15, 6),
        ('SKU-005', 'Teclado Mecânico RGB', 5, 15, 4)
    ]
    cursor.executemany('INSERT INTO tabela_estoque VALUES (?, ?, ?, ?, ?)', produtos)
    
    # 3. Geração de 200 pedidos simulados nos últimos 30 dias
    hoje = datetime.now().date()
    pedidos = []
    
    for _ in range(200):
        sku, _, _, _, _ = random.choice(produtos)
        qtd_pedida = random.randint(1, 5)
        
        # Simula 10% de chance de entrega parcial (falha no In-Full)
        qtd_entregue = qtd_pedida if random.random() > 0.10 else qtd_pedida - 1
        
        dias_atras = random.randint(1, 30)
        data_pedido = hoje - timedelta(days=dias_atras)
        data_prometida = data_pedido + timedelta(days=4)
        
        # Simula atrasos na entrega (falha no On-Time)
        atraso = random.choice([0, 0, 0, 1, 2, 3])
        data_entrega = data_prometida + timedelta(days=atraso - 1)
        
        pedidos.append((
            sku, qtd_pedida, qtd_entregue, 
            data_pedido.isoformat(), data_prometida.isoformat(), data_entrega.isoformat(), 
            'Entregue'
        ))
        
    cursor.executemany('''
        INSERT INTO tabela_pedidos 
        (sku, quantidade_pedida, quantidade_entregue, data_pedido, data_prometida, data_entrega, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', pedidos)
    
    conn.commit()
    return conn

def analisar_supply_chain(conn):
    """Executa a query SQL para calcular OTIF, Lead Time e Cobertura, e classifica riscos."""
    query = '''
    WITH metricas_pedidos AS (
        SELECT 
            p.sku,
            JULIANDAY(p.data_entrega) - JULIANDAY(p.data_pedido) AS lead_time_dias,
            CASE 
                WHEN p.data_entrega <= p.data_prometida 
                     AND p.quantidade_entregue = p.quantidade_pedida 
                THEN 1.0 
                ELSE 0.0 
            END AS status_otif
        FROM tabela_pedidos p
        WHERE p.status = 'Entregue'
          AND p.data_pedido >= DATE('now', '-30 days')
    ),
    vendas_diarias AS (
        SELECT 
            sku,
            SUM(quantidade_pedida) / 30.0 AS media_venda_diaria
        FROM tabela_pedidos
        WHERE data_pedido >= DATE('now', '-30 days')
        GROUP BY sku
    )
    SELECT 
        e.sku,
        e.nome_produto,
        e.saldo_atual,
        e.estoque_seguranca,
        e.lead_time_fornecedor,
        ROUND(COALESCE(v.media_venda_diaria, 0), 2) AS demanda_diaria,
        CASE 
            WHEN COALESCE(v.media_venda_diaria, 0) > 0 
            THEN ROUND(e.saldo_atual / v.media_venda_diaria, 1)
            ELSE 999.0 
        END AS dias_cobertura,
        ROUND(AVG(m.lead_time_dias), 2) AS lead_time_entrega_medio,
        ROUND(AVG(m.status_otif) * 100, 2) AS taxa_otif_percentual
    FROM tabela_estoque e
    LEFT JOIN vendas_diarias v ON e.sku = v.sku
    LEFT JOIN metricas_pedidos m ON e.sku = m.sku
    GROUP BY e.sku, e.nome_produto, e.saldo_atual, e.estoque_seguranca, e.lead_time_fornecedor, v.media_venda_diaria;
    '''
    
    df = pd.read_sql_query(query, conn)
    
    # Regra de negócio para diagnóstico de risco
    def diagnosticar_risco(row):
        motivos = []
        if row['saldo_atual'] <= row['estoque_seguranca']:
            motivos.append("Saldo <= Estoque Segurança")
        if row['dias_cobertura'] <= row['lead_time_fornecedor']:
            motivos.append("Cobertura <= Lead Time Fornecedor")
        return " | ".join(motivos) if motivos else "Operacional"
        
    df['status_alerta'] = df.apply(diagnosticar_risco, axis=1)
    df['risco_ruptura'] = df['status_alerta'] != "Operacional"
    
    return df

def exportar_relatorios(df):
    """Exporta os indicadores gerais e os alertas críticos para Excel (.xlsx) e CSV."""
    data_atual = datetime.now().strftime("%Y-%m-%d")
    df_alertas = df[df['risco_ruptura'] == True].sort_values(by='dias_cobertura')
    
    # 1. Exportação para CSV (apenas alertas críticos)
    nome_csv = f"alertas_ruptura_{data_atual}.csv"
    df_alertas.drop(columns=['risco_ruptura']).to_csv(
        nome_csv, 
        index=False, 
        sep=';', 
        decimal=',', 
        encoding='utf-8-sig'
    )
    
    # 2. Exportação para Excel com múltiplas abas
    nome_excel = f"relatorio_supply_chain_{data_atual}.xlsx"
    with pd.ExcelWriter(nome_excel, engine='openpyxl') as writer:
        df.drop(columns=['risco_ruptura']).to_excel(writer, sheet_name='Indicadores_Gerais', index=False)
        df_alertas.drop(columns=['risco_ruptura']).to_excel(writer, sheet_name='Alertas_Criticos', index=False)
        
    print("=" * 60)
    print("PROCESSAMENTO CONCLUÍDO COM SUCESSO!")
    print("=" * 60)
    print(f"-> Arquivo CSV de Alertas gerado: {nome_csv}")
    print(f"-> Arquivo Excel Completo gerado: {nome_excel}")

if __name__ == "__main__":
    conexao = criar_banco_e_dados()
    df_resultados = analisar_supply_chain(conexao)
    exportar_relatorios(df_resultados)
    conexao.close()
