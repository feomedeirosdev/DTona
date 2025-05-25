WITH tb_base_age AS (
    SELECT 
        t2.seller_id,
        MAX(julianday('{date}') - julianday(t1.order_approved_at)) AS base_age_days
    FROM tb_orders AS t1
    LEFT JOIN tb_order_items AS t2 
        ON t1.order_id = t2.order_id
    WHERE 
        t1.order_approved_at < '{date}'
        AND t1.order_status = 'delivered'
    GROUP BY t2.seller_id
),

tb_sellers_semi_complete AS (
    SELECT 
        t2.seller_id,
        AVG(t5.review_score) AS avg_review_score,

        CAST(t3.base_age_days AS INT) AS base_age_days,
        (CAST(t3.base_age_days / 30 AS INT) + 1) AS base_age_months,
        CAST(julianday('{date}') - julianday(MAX(t1.order_approved_at)) AS INT) AS time_since_last_sale_days,
        COUNT(DISTINCT strftime('%m', t1.order_approved_at)) AS activated_months_qt,

        CAST(COUNT(DISTINCT strftime('%m', t1.order_approved_at)) AS FLOAT) / 
        MIN((CAST(t3.base_age_days / 30 AS INT) + 1), 6) * 100 AS activated_months_pct,

        SUM(t2.price) AS revenue_R$,
        COUNT(DISTINCT t2.order_id) AS sales_qt,
        COUNT(t2.product_id) AS products_qt,
        COUNT(DISTINCT t2.product_id) AS distinct_products_qt,

        SUM(t2.price) / COUNT(DISTINCT t2.order_id) AS avg_sales_value_per_order_R$,
        SUM(t2.price) / MIN(1 + CAST(t3.base_age_days / 30 AS INT), 6) AS avg_sales_value_per_month_R$,
        SUM(t2.price) / COUNT(DISTINCT strftime('%m', t1.order_approved_at)) AS avg_sales_value_per_activated_month_R$,
        CAST(COUNT(t2.product_id) AS FLOAT) / COUNT(DISTINCT t2.order_id) AS avg_num_products_per_sale,

        (SUM(CASE WHEN julianday(order_delivered_customer_date) > julianday(order_estimated_delivery_date) THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT t2.order_id)) * 100 AS delay_pct,

        CAST(AVG(julianday(t1.order_estimated_delivery_date) - julianday(t1.order_purchase_timestamp)) AS INT) AS avg_delivery_time_days,

        SUM(CASE WHEN product_category_name = 'cama_mesa_banho' THEN 1 ELSE 0 END) AS cat_cama_mesa_banho_qt,
        SUM(CASE WHEN product_category_name = 'beleza_saude' THEN 1 ELSE 0 END) AS cat_beleza_saude_qt,
        SUM(CASE WHEN product_category_name = 'esporte_lazer' THEN 1 ELSE 0 END) AS cat_esporte_lazer_qt,
        SUM(CASE WHEN product_category_name = 'moveis_decoracao' THEN 1 ELSE 0 END) AS cat_moveis_decoracao_qt,
        SUM(CASE WHEN product_category_name = 'informatica_acessorios' THEN 1 ELSE 0 END) AS cat_informatica_acessorios_qt,
        SUM(CASE WHEN product_category_name = 'utilidades_domesticas' THEN 1 ELSE 0 END) AS cat_utilidades_domesticas_qt,
        SUM(CASE WHEN product_category_name = 'relogios_presentes' THEN 1 ELSE 0 END) AS cat_relogios_presentes_qt,
        SUM(CASE WHEN product_category_name = 'telefonia' THEN 1 ELSE 0 END) AS cat_telefonia_qt,
        SUM(CASE WHEN product_category_name = 'ferramentas_jardim' THEN 1 ELSE 0 END) AS cat_ferramentas_jardim_qt,
        SUM(CASE WHEN product_category_name = 'automotivo' THEN 1 ELSE 0 END) AS cat_automotivo_qt,
        SUM(CASE WHEN product_category_name = 'brinquedos' THEN 1 ELSE 0 END) AS cat_brinquedos_qt,
        SUM(CASE WHEN product_category_name = 'cool_stuff' THEN 1 ELSE 0 END) AS cat_cool_stuff_qt,
        SUM(CASE WHEN product_category_name = 'perfumaria' THEN 1 ELSE 0 END) AS cat_perfumaria_qt,
        SUM(CASE WHEN product_category_name = 'bebes' THEN 1 ELSE 0 END) AS cat_bebes_qt,
        SUM(CASE WHEN product_category_name = 'eletronicos' THEN 1 ELSE 0 END) AS cat_eletronicos_qt,
        SUM(CASE WHEN product_category_name = 'papelaria' THEN 1 ELSE 0 END) AS cat_papelaria_qt,
        SUM(CASE WHEN product_category_name = 'fashion_bolsas_e_acessorios' THEN 1 ELSE 0 END) AS cat_fashion_bolsas_e_acessorios_qt,
        SUM(CASE WHEN product_category_name = 'pet_shop' THEN 1 ELSE 0 END) AS cat_pet_shop_qt,
        SUM(CASE WHEN product_category_name = 'moveis_escritorio' THEN 1 ELSE 0 END) AS cat_moveis_escritorio_qt,
        SUM(CASE WHEN product_category_name = 'consoles_games' THEN 1 ELSE 0 END) AS cat_consoles_games_qt,
        SUM(CASE WHEN product_category_name = 'malas_acessorios' THEN 1 ELSE 0 END) AS cat_malas_acessorios_qt,
        SUM(CASE WHEN product_category_name = 'construcao_ferramentas_construcao' THEN 1 ELSE 0 END) AS cat_construcao_ferramentas_construcao_qt,
        SUM(CASE WHEN product_category_name = 'eletrodomesticos' THEN 1 ELSE 0 END) AS cat_eletrodomesticos_qt,
        SUM(CASE WHEN product_category_name = 'instrumentos_musicais' THEN 1 ELSE 0 END) AS cat_instrumentos_musicais_qt,
        SUM(CASE WHEN product_category_name = 'eletroportateis' THEN 1 ELSE 0 END) AS cat_eletroportateis_qt,
        SUM(CASE WHEN product_category_name = 'casa_construcao' THEN 1 ELSE 0 END) AS cat_casa_construcao_qt,
        SUM(CASE WHEN product_category_name = 'livros_interesse_geral' THEN 1 ELSE 0 END) AS cat_livros_interesse_geral_qt,
        SUM(CASE WHEN product_category_name = 'alimentos' THEN 1 ELSE 0 END) AS cat_alimentos_qt,
        SUM(CASE WHEN product_category_name = 'moveis_sala' THEN 1 ELSE 0 END) AS cat_moveis_sala_qt,
        SUM(CASE WHEN product_category_name = 'casa_conforto' THEN 1 ELSE 0 END) AS cat_casa_conforto_qt,
        SUM(CASE WHEN product_category_name = 'bebidas' THEN 1 ELSE 0 END) AS cat_bebidas_qt,
        SUM(CASE WHEN product_category_name = 'audio' THEN 1 ELSE 0 END) AS cat_audio_qt,
        SUM(CASE WHEN product_category_name = 'market_place' THEN 1 ELSE 0 END) AS cat_market_place_qt,
        SUM(CASE WHEN product_category_name = 'construcao_ferramentas_iluminacao' THEN 1 ELSE 0 END) AS cat_construcao_ferramentas_iluminacao_qt,
        SUM(CASE WHEN product_category_name = 'climatizacao' THEN 1 ELSE 0 END) AS cat_climatizacao_qt,
        SUM(CASE WHEN product_category_name = 'moveis_cozinha_area_de_servico_jantar_e_jardim' THEN 1 ELSE 0 END) AS cat_moveis_cozinha_area_de_servico_jantar_e_jardim_qt,
        SUM(CASE WHEN product_category_name = 'alimentos_bebidas' THEN 1 ELSE 0 END) AS cat_alimentos_bebidas_qt,
        SUM(CASE WHEN product_category_name = 'industria_comercio_e_negocios' THEN 1 ELSE 0 END) AS cat_industria_comercio_e_negocios_qt,
        SUM(CASE WHEN product_category_name = 'livros_tecnicos' THEN 1 ELSE 0 END) AS cat_livros_tecnicos_qt,
        SUM(CASE WHEN product_category_name = 'telefonia_fixa' THEN 1 ELSE 0 END) AS cat_telefonia_fixa_qt,
        SUM(CASE WHEN product_category_name = 'fashion_calcados' THEN 1 ELSE 0 END) AS cat_fashion_calcados_qt,
        SUM(CASE WHEN product_category_name = 'eletrodomesticos_2' THEN 1 ELSE 0 END) AS cat_eletrodomesticos_2_qt,
        SUM(CASE WHEN product_category_name = 'construcao_ferramentas_jardim' THEN 1 ELSE 0 END) AS cat_construcao_ferramentas_jardim_qt,
        SUM(CASE WHEN product_category_name = 'agro_industria_e_comercio' THEN 1 ELSE 0 END) AS cat_agro_industria_e_comercio_qt,
        SUM(CASE WHEN product_category_name = 'artes' THEN 1 ELSE 0 END) AS cat_artes_qt,
        SUM(CASE WHEN product_category_name = 'pcs' THEN 1 ELSE 0 END) AS cat_pcs_qt,
        SUM(CASE WHEN product_category_name = 'sinalizacao_e_seguranca' THEN 1 ELSE 0 END) AS cat_sinalizacao_e_seguranca_qt,
        SUM(CASE WHEN product_category_name = 'construcao_ferramentas_seguranca' THEN 1 ELSE 0 END) AS cat_construcao_ferramentas_seguranca_qt,
        SUM(CASE WHEN product_category_name = 'artigos_de_natal' THEN 1 ELSE 0 END) AS cat_artigos_de_natal_qt,
        SUM(CASE WHEN product_category_name = 'fashion_roupa_masculina' THEN 1 ELSE 0 END) AS cat_fashion_roupa_masculina_qt

    FROM tb_orders AS t1

    LEFT JOIN tb_order_items AS t2 
        ON t1.order_id = t2.order_id

    LEFT JOIN tb_base_age AS t3 
        ON t2.seller_id = t3.seller_id

    LEFT JOIN tb_products AS t4 
        ON t2.product_id = t4.product_id
    
    LEFT JOIN tb_order_reviews AS t5 
        ON t5.order_id = t1.order_id

    WHERE 
        t1.order_approved_at >= date('{date}', '-6 months')
        AND t1.order_approved_at < '{date}'
        AND t1.order_status = 'delivered'

    GROUP BY t2.seller_id
)

SELECT 
    '{date}' AS dt_ref,
    t2.seller_state,
    t2.seller_city,
    t1.*

FROM tb_sellers_semi_complete AS t1

LEFT JOIN tb_sellers AS t2 
    ON t1.seller_id = t2.seller_id;
