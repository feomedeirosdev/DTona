SELECT
   *,
   (CASE WHEN 
      julianday(order_delivered_customer_date) > julianday(order_estimated_delivery_date) THEN 1 ELSE 0 END
      ) AS "Delay"

FROM tb_orders AS t1 


