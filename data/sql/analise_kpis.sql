-- ==========================================================
-- 0. ESTRUTURA DAS TABELAS (DDL)
-- ==========================================================
CREATE TABLE fornecedores (
    id_fornecedor VARCHAR(10) PRIMARY KEY,
    nome_fornecedor VARCHAR(100) NOT NULL,
    estado CHAR(2),
    lead_time_acordado_dias INT
);

CREATE TABLE produtos (
    id_produto VARCHAR(10) PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    id_fornecedor VARCHAR(10),
    custo_unitario DECIMAL(10, 2),
    estoque_atual INT,
    estoque_minimo INT,
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor)
);

CREATE TABLE pedidos (
    id_pedido VARCHAR(15) PRIMARY KEY,
    data_pedido DATE,
    id_produto VARCHAR(10),
    qtd_solicitada INT,
    qtd_entregue INT,
    data_prevista_entrega DATE,
    data_entrega_real DATE,
    transportadora VARCHAR(50),
    regiao_destino VARCHAR(30),
    valor_frete DECIMAL(10, 2),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- ==========================================================
-- 1. CÁLCULO DE ENTREGAS NO PRAZO (ON-TIME) POR TRANSPORTADORA
-- ==========================================================
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

-- ==========================================================
-- 2. ALERTA DE RUPTURA DE ESTOQUE (PRODUTOS ABAIXO DO MÍNIMO)
-- ==========================================================
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
