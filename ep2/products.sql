SELECT
   DISTINCT t1.product_category_name AS "Category Name"

FROM tb_products AS t1

GROUP BY
   t1.product_category_name

ORDER BY 
   t1.product_category_name 


