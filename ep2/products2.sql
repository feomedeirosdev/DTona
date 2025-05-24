SELECT
   t2.product_category_name AS 'Product Category Name'
   -- count(t2.product_category_name) AS 'Products (qt)'

FROM tb_order_items AS t1

LEFT JOIN tb_products AS t2
ON t1.product_id = t2.product_id

GROUP BY t2.product_category_name

ORDER BY count(t2.product_category_name) DESC

-- sum(CASE WHEN product_category_name = 'cama_mesa_banho' THEN 1 ELSE 0 END) AS cama_mesa_banho_qt,
-- sum(CASE WHEN product_category_name = 'beleza_saude' THEN 1 ELSE 0 END) AS beleza_saude_qt,
-- sum(CASE WHEN product_category_name = 'esporte_lazer' THEN 1 ELSE 0 END) AS esporte_lazer_qt,
-- sum(CASE WHEN product_category_name = 'moveis_decoracao' THEN 1 ELSE 0 END) AS moveis_decoracao_qt,
-- sum(CASE WHEN product_category_name = 'informatica_acessorios' THEN 1 ELSE 0 END) AS informatica_acessorios_qt,
-- sum(CASE WHEN product_category_name = 'utilidades_domesticas' THEN 1 ELSE 0 END) AS utilidades_domesticas_qt,
-- sum(CASE WHEN product_category_name = 'relogios_presentes' THEN 1 ELSE 0 END) AS relogios_presentes_qt,
-- sum(CASE WHEN product_category_name = 'telefonia' THEN 1 ELSE 0 END) AS telefonia_qt,
-- sum(CASE WHEN product_category_name = 'ferramentas_jardim' THEN 1 ELSE 0 END) AS ferramentas_jardim_qt,
-- sum(CASE WHEN product_category_name = 'automotivo' THEN 1 ELSE 0 END) AS automotivo_qt,
-- sum(CASE WHEN product_category_name = 'brinquedos' THEN 1 ELSE 0 END) AS brinquedos_qt,
-- sum(CASE WHEN product_category_name = 'cool_stuff' THEN 1 ELSE 0 END) AS cool_stuff_qt,
-- sum(CASE WHEN product_category_name = 'perfumaria' THEN 1 ELSE 0 END) AS perfumaria_qt,
-- sum(CASE WHEN product_category_name = 'bebes' THEN 1 ELSE 0 END) AS bebes_qt,
-- sum(CASE WHEN product_category_name = 'eletronicos' THEN 1 ELSE 0 END) AS eletronicos_qt,
-- sum(CASE WHEN product_category_name = 'papelaria' THEN 1 ELSE 0 END) AS papelaria_qt,
-- sum(CASE WHEN product_category_name = 'fashion_bolsas_e_acessorios' THEN 1 ELSE 0 END) AS fashion_bolsas_e_acessorios_qt,
-- sum(CASE WHEN product_category_name = 'pet_shop' THEN 1 ELSE 0 END) AS pet_shop_qt,
-- sum(CASE WHEN product_category_name = 'moveis_escritorio' THEN 1 ELSE 0 END) AS moveis_escritorio_qt,
-- sum(CASE WHEN product_category_name = 'consoles_games' THEN 1 ELSE 0 END) AS consoles_games_qt,
-- sum(CASE WHEN product_category_name = 'malas_acessorios' THEN 1 ELSE 0 END) AS malas_acessorios_qt,
-- sum(CASE WHEN product_category_name = 'construcao_ferramentas_construcao' THEN 1 ELSE 0 END) AS construcao_ferramentas_construcao_qt,
-- sum(CASE WHEN product_category_name = 'eletrodomesticos' THEN 1 ELSE 0 END) AS eletrodomesticos_qt,
-- sum(CASE WHEN product_category_name = 'instrumentos_musicais' THEN 1 ELSE 0 END) AS instrumentos_musicais_qt,
-- sum(CASE WHEN product_category_name = 'eletroportateis' THEN 1 ELSE 0 END) AS eletroportateis_qt,
-- sum(CASE WHEN product_category_name = 'casa_construcao' THEN 1 ELSE 0 END) AS casa_construcao_qt,
-- sum(CASE WHEN product_category_name = 'livros_interesse_geral' THEN 1 ELSE 0 END) AS livros_interesse_geral_qt,
-- sum(CASE WHEN product_category_name = 'alimentos' THEN 1 ELSE 0 END) AS alimentos_qt,
-- sum(CASE WHEN product_category_name = 'moveis_sala' THEN 1 ELSE 0 END) AS moveis_sala_qt,
-- sum(CASE WHEN product_category_name = 'casa_conforto' THEN 1 ELSE 0 END) AS casa_conforto_qt,
-- sum(CASE WHEN product_category_name = 'bebidas' THEN 1 ELSE 0 END) AS bebidas_qt,
-- sum(CASE WHEN product_category_name = 'audio' THEN 1 ELSE 0 END) AS audio_qt,
-- sum(CASE WHEN product_category_name = 'market_place' THEN 1 ELSE 0 END) AS market_place_qt,
-- sum(CASE WHEN product_category_name = 'construcao_ferramentas_iluminacao' THEN 1 ELSE 0 END) AS construcao_ferramentas_iluminacao_qt,
-- sum(CASE WHEN product_category_name = 'climatizacao' THEN 1 ELSE 0 END) AS climatizacao_qt,
-- sum(CASE WHEN product_category_name = 'moveis_cozinha_area_de_servico_jantar_e_jardim' THEN 1 ELSE 0 END) AS moveis_cozinha_area_de_servico_jantar_e_jardim_qt,
-- sum(CASE WHEN product_category_name = 'alimentos_bebidas' THEN 1 ELSE 0 END) AS alimentos_bebidas_qt,
-- sum(CASE WHEN product_category_name = 'industria_comercio_e_negocios' THEN 1 ELSE 0 END) AS industria_comercio_e_negocios_qt,
-- sum(CASE WHEN product_category_name = 'livros_tecnicos' THEN 1 ELSE 0 END) AS livros_tecnicos_qt,
-- sum(CASE WHEN product_category_name = 'telefonia_fixa' THEN 1 ELSE 0 END) AS telefonia_fixa_qt,
-- sum(CASE WHEN product_category_name = 'fashion_calcados' THEN 1 ELSE 0 END) AS fashion_calcados_qt,
-- sum(CASE WHEN product_category_name = 'eletrodomesticos_2' THEN 1 ELSE 0 END) AS eletrodomesticos_2_qt,
-- sum(CASE WHEN product_category_name = 'construcao_ferramentas_jardim' THEN 1 ELSE 0 END) AS construcao_ferramentas_jardim_qt,
-- sum(CASE WHEN product_category_name = 'agro_industria_e_comercio' THEN 1 ELSE 0 END) AS agro_industria_e_comercio_qt,
-- sum(CASE WHEN product_category_name = 'artes' THEN 1 ELSE 0 END) AS artes_qt,
-- sum(CASE WHEN product_category_name = 'pcs' THEN 1 ELSE 0 END) AS pcs_qt,
-- sum(CASE WHEN product_category_name = 'sinalizacao_e_seguranca' THEN 1 ELSE 0 END) AS sinalizacao_e_seguranca_qt,
-- sum(CASE WHEN product_category_name = 'construcao_ferramentas_seguranca' THEN 1 ELSE 0 END) AS construcao_ferramentas_seguranca_qt,
-- sum(CASE WHEN product_category_name = 'artigos_de_natal' THEN 1 ELSE 0 END) AS artigos_de_natal_qt,
-- sum(CASE WHEN product_category_name = 'fashion_roupa_masculina' THEN 1 ELSE 0 END) AS fashion_roupa_masculina_qt,