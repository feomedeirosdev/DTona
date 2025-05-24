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
    ) AS "Avg Nun Products per Sale"

FROM tb_orders AS t1

LEFT JOIN 
  tb_order_items AS t2 
  ON
  t1.order_id = t2.order_id

LEFT JOIN 
  tb_base_age AS t3
  ON
  t2.seller_id = t3.seller_id

WHERE
  t1.order_approved_at >= '2016-10-01'
  AND
  t1.order_approved_at < '2017-04-01'
  AND
  t1.order_status = 'delivered'

GROUP BY t2.seller_id

LIMIT 10
