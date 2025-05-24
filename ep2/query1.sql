WITH tb_base_age AS (
  
  -- Calcula a idade base (em dias) dos vendedores na platafoma
  -- desde 01/04/2017
  SELECT t2.seller_id,
    
    max(
      julianday('2017-04-01') - julianday(t1.order_approved_at)
      ) AS BaseAge_days

  FROM tb_orders AS t1

  LEFT JOIN 
    tb_order_items AS t2
    ON 
    t1.order_id = t2.order_id

  WHERE 
    t1.order_approved_at < '2017-04-01' 
    AND 
    t1.order_status = 'delivered'

  GROUP BY t2.seller_id

) 

SELECT t2.seller_id AS "Seller ID",

  CAST(
    t3.BaseAge_days AS INT
    ) AS "Base Age (days)",

  (CAST
    (t3.BaseAge_days / 30 AS INT) + 1
    ) AS "Base Age (months)",

  CAST(
    julianday('2017-04-01') - julianday(max(t1.order_approved_at)) As INT
    )  AS "Time Since Last Sale (days)",

  count(
    DISTINCT strftime('%m', t1.order_approved_at)
    ) AS "Activated Months (qt)",
  
  printf('%.2f', 
    (CAST(count(DISTINCT strftime('%m', t1.order_approved_at)) AS FLOAT) / min((CAST(t3.BaseAge_days / 30 AS INT) + 1), 6)) * 100
    ) AS "Activated Months (%)",

  printf('%.2f', 
    sum(t2.price)) 
    AS "Revenue (R$)",

  count(
    DISTINCT t2.order_id
    ) AS "Sales (qt)",

  count(
    t2.product_id
    ) AS "Products (qt)",

  count(
    DISTINCT t2.product_id
    ) AS "Distinct Products (qt)",

  printf('%.2f', 
    sum(t2.price) / count(DISTINCT t2.order_id)
    ) AS "Avg Sales Value per Order (R$)",

  printf('%.2f', 
    sum(t2.price) / min(1 + CAST(t3.BaseAge_days / 30 AS INT), 6)
    ) AS "Avg Sales Value per Month (R$)",

  printf('%.2f',
    sum(t2.price) / count(DISTINCT strftime('%m', t1.order_approved_at))
    ) AS "Avg Sales Salue per Activade Month (R$)",

  printf('%.4f', 
    CAST(count(t2.product_id) AS FLOAT) / count(DISTINCT t2.order_id)
    ) AS "Avg Nun Products per Sale",

  sum(
    CASE WHEN t4.product_category_name = 'automotivo' THEN 1 ELSE 0 END
    ) AS "automotivo Category (qt)",

  sum(
    CASE WHEN t4.product_category_name = 'automotivo' THEN t2.price ELSE 0 END
    ) AS '"automotivo" Category Partial Ravenue (R$)',

  sum(CASE WHEN product_category_name = 'cama_mesa_banho' THEN 1 ELSE 0 END) AS "Cama Mesa Banho Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'beleza_saude' THEN 1 ELSE 0 END) AS "Beleza Saude Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'esporte_lazer' THEN 1 ELSE 0 END) AS "Esporte Lazer Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'moveis_decoracao' THEN 1 ELSE 0 END) AS "Moveis Decoracao Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'informatica_acessorios' THEN 1 ELSE 0 END) AS "Informatica Acessorios Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'utilidades_domesticas' THEN 1 ELSE 0 END) AS "Utilidades Domesticas Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'relogios_presentes' THEN 1 ELSE 0 END) AS "Relogios Presentes Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'telefonia' THEN 1 ELSE 0 END) AS "Telefonia Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'ferramentas_jardim' THEN 1 ELSE 0 END) AS "Ferramentas Jardim Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'automotivo' THEN 1 ELSE 0 END) AS "Automotivo Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'brinquedos' THEN 1 ELSE 0 END) AS "Brinquedos Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'cool_stuff' THEN 1 ELSE 0 END) AS "Cool Stuff Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'perfumaria' THEN 1 ELSE 0 END) AS "Perfumaria Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'bebes' THEN 1 ELSE 0 END) AS "Bebes Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'eletronicos' THEN 1 ELSE 0 END) AS "Eletronicos Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'papelaria' THEN 1 ELSE 0 END) AS "Papelaria Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'fashion_bolsas_e_acessorios' THEN 1 ELSE 0 END) AS "Fashion Bolsas e Acessorios Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'pet_shop' THEN 1 ELSE 0 END) AS "Pet Shop Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'moveis_escritorio' THEN 1 ELSE 0 END) AS "Moveis Escritorio Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'consoles_games' THEN 1 ELSE 0 END) AS "Consoles Games Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'malas_acessorios' THEN 1 ELSE 0 END) AS "Malas Acessorios Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'construcao_ferramentas_construcao' THEN 1 ELSE 0 END) AS "Construcao Ferramentas Construcao Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'eletrodomesticos' THEN 1 ELSE 0 END) AS "Eletrodomesticos Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'instrumentos_musicais' THEN 1 ELSE 0 END) AS "Instrumentos Musicais Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'eletroportateis' THEN 1 ELSE 0 END) AS "Eletroportateis Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'casa_construcao' THEN 1 ELSE 0 END) AS "Casa Construcao Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'livros_interesse_geral' THEN 1 ELSE 0 END) AS "Livros Interesse Geral Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'alimentos' THEN 1 ELSE 0 END) AS "Alimentos Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'moveis_sala' THEN 1 ELSE 0 END) AS "Moveis Sala Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'casa_conforto' THEN 1 ELSE 0 END) AS "Casa Conforto Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'bebidas' THEN 1 ELSE 0 END) AS "Bebidas Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'audio' THEN 1 ELSE 0 END) AS "Audio Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'market_place' THEN 1 ELSE 0 END) AS "Market Place Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'construcao_ferramentas_iluminacao' THEN 1 ELSE 0 END) AS "Construcao Ferramentas Iluminacao Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'climatizacao' THEN 1 ELSE 0 END) AS "Climatizacao Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'moveis_cozinha_area_de_servico_jantar_e_jardim' THEN 1 ELSE 0 END) AS "Moveis Cozinha Area de Servico Jantar e Jardim Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'alimentos_bebidas' THEN 1 ELSE 0 END) AS "Alimentos Bebidas Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'industria_comercio_e_negocios' THEN 1 ELSE 0 END) AS "Industria Comercio e Negocios Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'livros_tecnicos' THEN 1 ELSE 0 END) AS "Livros Tecnicos Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'telefonia_fixa' THEN 1 ELSE 0 END) AS "Telefonia Fixa Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'fashion_calcados' THEN 1 ELSE 0 END) AS "Fashion Calcados Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'eletrodomesticos_2' THEN 1 ELSE 0 END) AS "Eletrodomesticos 2 Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'construcao_ferramentas_jardim' THEN 1 ELSE 0 END) AS "Construcao Ferramentas Jardim Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'agro_industria_e_comercio' THEN 1 ELSE 0 END) AS "Agro Industria e Comercio Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'artes' THEN 1 ELSE 0 END) AS "Artes Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'pcs' THEN 1 ELSE 0 END) AS "PCs Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'sinalizacao_e_seguranca' THEN 1 ELSE 0 END) AS "Sinalizacao e Seguranca Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'construcao_ferramentas_seguranca' THEN 1 ELSE 0 END) AS "Construcao Ferramentas Seguranca Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'artigos_de_natal' THEN 1 ELSE 0 END) AS "Artigos de Natal Category Sales (qt)",
  sum(CASE WHEN product_category_name = 'fashion_roupa_masculina' THEN 1 ELSE 0 END) AS "Fashion Roupa Masculina Category Sales (qt)"

FROM tb_orders AS t1

LEFT JOIN 
  tb_order_items AS t2 
  ON
  t1.order_id = t2.order_id

LEFT JOIN 
  tb_base_age AS t3
  ON
  t2.seller_id = t3.seller_id

LEFT JOIN
  tb_products AS t4
  ON
  t2.product_id = t4.product_id

WHERE
  t1.order_approved_at >= '2016-10-01'
  AND
  t1.order_approved_at < '2017-04-01'
  AND
  t1.order_status = 'delivered'

GROUP BY t2.seller_id

LIMIT 3

