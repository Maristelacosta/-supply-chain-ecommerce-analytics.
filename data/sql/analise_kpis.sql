-- 1. Cálculo de Entregas no Prazo (On-Time) por Transportadora
SELECT 
    transportadora,
    COUNT(id_pedido) AS total_pedidos,
    SUM(CASE WHEN data_entrega_real <= data_prevista_entrega THEN 1 ELSE 0 END) AS entregas_no_prazo,
    ROUND(
        (SUM(CASE WHEN data_entrega_real <= data_prevista_entrega THEN 1.0 ELSE 0 END) / COUNT(id_pedido)) * 100, 
        2
    ) AS percentual_on_time
FROM pedidos
GROUP BY transportadora
ORDER BY percentual_on_time DESC;

-- 2. Alerta de Ruptura de Estoque (Produtos abaixo do mínimo)
SELECT 
    p.id_produto,
    p.nome_produto,
    p.estoque_atual,
    p.estoque_minimo,
    (p.estoque_minimo - p.estoque_atual) AS deficit_unidades,
    f.nome_fornecedor,
    f.lead_time_acordado_dias
FROM produtos p
JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor
WHERE p.estoque_atual < p.estoque_minimo
ORDER BY deficit_unidades DESC;
