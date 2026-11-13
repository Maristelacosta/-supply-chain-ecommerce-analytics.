-- ============================================================================
-- PROJETO: Análise de Supply Chain e Alerta de Ruptura de Estoque (E-commerce)
-- BANCO DE DADOS: SQLite
-- DESCRIÇÃO: Cálculo de OTIF (On-Time e In-Full), Lead Time médio de entrega,
--            cobertura de estoque, diagnóstico de risco e sugestão de compra.
-- ============================================================================

WITH metricas_pedidos AS (
    SELECT 
        p.sku,
        -- Tempo total entre a compra e a entrega ao cliente
        JULIANDAY(p.data_entrega) - JULIANDAY(p.data_pedido) AS lead_time_dias,
        
        -- Indicador On-Time (Entregue dentro ou antes do prazo prometido)
        CASE 
            WHEN p.data_entrega <= p.data_prometida THEN 1.0 
            ELSE 0.0 
        END AS status_on_time,
        
        -- Indicador In-Full (Entregue na quantidade exata solicitada)
        CASE 
            WHEN p.quantidade_entregue = p.quantidade_pedida THEN 1.0 
            ELSE 0.0 
        END AS status_in_full,
        
        -- Indicador OTIF Completo (On-Time E In-Full simultaneamente)
        CASE 
            WHEN p.data_entrega <= p.data_prometida 
                 AND p.quantidade_entregue = p.quantidade_pedida THEN 1.0 
            ELSE 0.0 
        END AS status_otif
    FROM tabela_pedidos p
    WHERE p.status = 'Entregue'
      AND p.data_pedido >= DATE('now', '-30 days')
),

vendas_diarias AS (
    SELECT 
        sku,
        SUM(quantidade_pedida) AS total_vendido_30d,
        SUM(quantidade_pedida) / 30.0 AS media_venda_diaria
    FROM tabela_pedidos
    WHERE data_pedido >= DATE('now', '-30 days')
    GROUP BY sku
),

indicadores_consolidados AS (
    SELECT 
        e.sku,
        e.nome_produto,
        e.saldo_atual,
        e.estoque_seguranca,
        e.lead_time_fornecedor,
        COALESCE(v.total_vendido_30d, 0) AS total_vendido_30d,
        ROUND(COALESCE(v.media_venda_diaria, 0), 2) AS demanda_diaria,
        CASE 
            WHEN COALESCE(v.media_venda_diaria, 0) > 0 
            THEN ROUND(e.saldo_atual / v.media_venda_diaria, 1)
            ELSE 999.0 
        END AS dias_cobertura,
        ROUND(AVG(m.lead_time_dias), 2) AS lead_time_entrega_medio,
        ROUND(AVG(m.status_on_time) * 100, 2) AS taxa_on_time_pct,
        ROUND(AVG(m.status_in_full) * 100, 2) AS taxa_in_full_pct,
        ROUND(AVG(m.status_otif) * 100, 2) AS taxa_otif_pct
    FROM tabela_estoque e
    LEFT JOIN vendas_diarias v ON e.sku = v.sku
    LEFT JOIN metricas_pedidos m ON e.sku = m.sku
    GROUP BY 
        e.sku, 
        e.nome_produto, 
        e.saldo_atual, 
        e.estoque_seguranca, 
        e.lead_time_fornecedor, 
        v.total_vendido_30d,
        v.media_venda_diaria
)

SELECT 
    sku,
    nome_produto,
    saldo_atual,
    estoque_seguranca,
    lead_time_fornecedor,
    total_vendido_30d,
    demanda_diaria,
    dias_cobertura,
    lead_time_entrega_medio,
    taxa_on_time_pct,
    taxa_in_full_pct,
    taxa_otif_pct,
    
    -- Classificação de Risco diretamente no SQL (espelhando a regra de negócio)
    CASE 
        WHEN saldo_atual <= estoque_seguranca AND dias_cobertura <= lead_time_fornecedor 
            THEN 'Saldo <= Estoque Segurança | Cobertura <= Lead Time Fornecedor'
        WHEN saldo_atual <= estoque_seguranca 
            THEN 'Saldo <= Estoque Segurança'
        WHEN dias_cobertura <= lead_time_fornecedor 
            THEN 'Cobertura <= Lead Time Fornecedor'
        ELSE 'Operacional'
    END AS status_alerta,
    
    -- Flag booleana (1 = Risco, 0 = Normal) para facilitar filtros em BI/Dashboards
    CASE 
        WHEN saldo_atual <= estoque_seguranca OR dias_cobertura <= lead_time_fornecedor 
            THEN 1 
        ELSE 0 
    END AS flag_risco_ruptura,
    
    -- Sugestão de reposição para cobrir o Lead Time do Fornecedor + Estoque de Segurança
    CASE 
        WHEN saldo_atual <= estoque_seguranca OR dias_cobertura <= lead_time_fornecedor 
            THEN MAX(0, ROUND((demanda_diaria * lead_time_fornecedor) + estoque_seguranca - saldo_atual, 0))
        ELSE 0 
    END AS sugestao_compra_unidades

FROM indicadores_consolidados
ORDER BY flag_risco_ruptura DESC, dias_cobertura ASC;
