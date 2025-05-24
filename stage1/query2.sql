-- Bloco 1: Cálculo da idade base dos vendedores (em dias) até 01/04/2017
WITH tb_base_age AS (
    SELECT 
        t2.seller_id,
        MAX(julianday('2017-04-01') - julianday(t1.order_approved_at)) AS base_age_days
    FROM tb_orders AS t1
    LEFT JOIN tb_order_items AS t2 
        ON t1.order_id = t2.order_id
    WHERE 
        t1.order_approved_at < '2017-04-01'
        AND t1.order_status = 'delivered'
    GROUP BY t2.seller_id
),

-- Bloco 2: Cálculo das métricas por vendedor entre 01/10/2016 e 31/03/2017
tb_sellers_semi_complete AS (
    SELECT 
        t2.seller_id,

        -- Métricas de idade de atividade
        CAST(t3.base_age_days AS INT) AS base_age_days,
        (CAST(t3.base_age_days / 30 AS INT) + 1) AS base_age_months,
        CAST(julianday('2017-04-01') - julianday(MAX(t1.order_approved_at)) AS INT) AS time_since_last_sale_days,
        COUNT(DISTINCT strftime('%m', t1.order_approved_at)) AS activated_months_qt,

        -- Percentual de meses com venda (ativação)
        printf('%.2f', 
            CAST(COUNT(DISTINCT strftime('%m', t1.order_approved_at)) AS FLOAT) / 
            MIN((CAST(t3.base_age_days / 30 AS INT) + 1), 6) * 100
        ) AS activated_months_pct,

        -- Métricas de receita e volume de vendas
        printf('%.2f', SUM(t2.price)) AS revenue_rs,
        COUNT(DISTINCT t2.order_id) AS sales_qt,
        COUNT(t2.product_id) AS products_qt,
        COUNT(DISTINCT t2.product_id) AS distinct_products_qt,

        -- Métricas médias
        printf('%.2f', SUM(t2.price) / COUNT(DISTINCT t2.order_id)) AS avg_sales_value_per_order_rs,
        printf('%.2f', SUM(t2.price) / MIN(1 + CAST(t3.base_age_days / 30 AS INT), 6)) AS avg_sales_value_per_month_rs,
        printf('%.2f', SUM(t2.price) / COUNT(DISTINCT strftime('%m', t1.order_approved_at))) AS avg_sales_value_per_activated_month_rs,
        printf('%.4f', CAST(COUNT(t2.product_id) AS FLOAT) / COUNT(DISTINCT t2.order_id)) AS avg_num_products_per_sale,

        -- Vendas na categoria "automotivo"
        SUM(CASE WHEN t4.product_category_name = 'automotivo' THEN 1 ELSE 0 END) AS cat_automotivo_qt,
        SUM(CASE WHEN t4.product_category_name = 'automotivo' THEN t2.price ELSE 0 END) AS cat_automotivo_revenue_rs,

        -- Vendas por categoria (exemplos principais)
        SUM(CASE WHEN product_category_name = 'cama_mesa_banho' THEN 1 ELSE 0 END) AS cat_cama_mesa_banho_qt,
        SUM(CASE WHEN product_category_name = 'beleza_saude' THEN 1 ELSE 0 END) AS cat_beleza_saude_qt,
        SUM(CASE WHEN product_category_name = 'esporte_lazer' THEN 1 ELSE 0 END) AS cat_esporte_lazer_qt,
        SUM(CASE WHEN product_category_name = 'moveis_decoracao' THEN 1 ELSE 0 END) AS cat_moveis_decoracao_qt,
        SUM(CASE WHEN product_category_name = 'informatica_acessorios' THEN 1 ELSE 0 END) AS cat_informatica_acessorios_qt,
        SUM(CASE WHEN product_category_name = 'utilidades_domesticas' THEN 1 ELSE 0 END) AS cat_utilidades_domesticas_qt,
        -- (continuação para outras categorias, se necessário)

        -- Percentual de entregas com atraso
        printf('%.2f', (SUM(CASE WHEN julianday(order_delivered_customer_date) > julianday(order_estimated_delivery_date) THEN 1 ELSE 0 END) / COUNT(DISTINCT t2.order_id)) * 100) AS delay_pct,

        CAST(avg(julianday(t1.order_estimated_delivery_date) - julianday(t1.order_purchase_timestamp)) AS INT) AS avg_delivery_time_days

    FROM tb_orders AS t1

    LEFT JOIN tb_order_items AS t2 
        ON t1.order_id = t2.order_id

    LEFT JOIN tb_base_age AS t3 
        ON t2.seller_id = t3.seller_id

    LEFT JOIN tb_products AS t4 
        ON t2.product_id = t4.product_id

    WHERE 
        t1.order_approved_at >= '2016-10-01'
        AND t1.order_approved_at < '2017-04-01'
        AND t1.order_status = 'delivered'

    GROUP BY t2.seller_id
)

-- Bloco 3: Inclusão de localização (estado e cidade) dos vendedores
SELECT 
    t1.*,
    t2.seller_state,
    t2.seller_city

FROM tb_sellers_semi_complete AS t1

LEFT JOIN tb_sellers AS t2 
    ON t1.seller_id = t2.seller_id

LIMIT 1