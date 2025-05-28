SELECT
   seller_id AS "Seller ID",
   printf('%.2f', (score_churn * 100)) AS "Score Churn (%)"

FROM tb_churn_score