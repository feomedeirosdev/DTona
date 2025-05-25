WITH tb_data_seller AS (

   SELECT
      strftime('%Y-%m', t1.order_approved_at) || '-01' AS dt_sell,
      t2.seller_id,
      max(1) AS sell

   FROM tb_orders AS t1

   LEFT JOIN tb_order_items AS t2 
      ON t1.order_id = t2.order_id


   WHERE t1.order_approved_at IS NOT NULL
      AND t2.seller_id IS NOT NULL
      AND t1.order_status = 'delivered'

   GROUP BY 
      strftime('%Y-%m', t1.order_approved_at) || '-01', 
      t2.seller_id

   ORDER BY 
      t2.seller_id,
      strftime('%Y-%m', t1.order_approved_at) || '-01'

), tb_cruza_books AS (

   SELECT
      t1.dt_ref,
      t2.seller_id,
      max(coalesce(t2.sell, 0)) AS flag_sell

   FROM tb_book_sellers AS t1

   LEFT JOIN tb_data_seller AS t2
      ON t1.seller_id = t2.seller_id
      AND t2.dt_sell BETWEEN t1.dt_ref
      AND date(t1.dt_ref, '+2 months')

   GROUP BY 
      t1.dt_ref,
      t1.seller_id

   ORDER BY t1.dt_ref

)

SELECT
   t1.flag_sell,
   t2.*

FROM tb_cruza_books AS t1

LEFT JOIN tb_book_sellers AS t2
ON t1.seller_id = t2.seller_id
AND t1.dt_ref = t2.dt_ref