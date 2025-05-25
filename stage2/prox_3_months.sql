SELECT
   DISTINCT t2.seller_id

FROM tb_orders AS t1

LEFT JOIN tb_order_items AS t2
ON t1.order_id = t2.order_id

WHERE 
   t1.order_approved_at BETWEEN '2017-04-01' AND '2017-07-01' 
   AND order_status = 'delivered'