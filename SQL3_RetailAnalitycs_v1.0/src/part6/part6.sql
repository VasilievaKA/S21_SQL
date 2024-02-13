-- Extra function
CREATE OR REPLACE FUNCTION opt_choice(num_of_groups NUMERIC,
                                      max_index NUMERIC,
                                      max_stab NUMERIC)
RETURNS TABLE
    (
        cos_id BIGINT,
        s_name VARCHAR,
        g_id BIGINT,
        dis NUMERIC
    )
AS $$
BEGIN
RETURN QUERY
WITH
res AS (
WITH
tmp AS (
SELECT Personalinformation.customer_id, group_id, Group_Affinity_Index,
row_number() over (partition by Personalinformation.customer_id order by Group_Affinity_Index DESC) as rank
FROM Personalinformation
JOIN groupsview ON Personalinformation.customer_id = groupsview.customer_id
WHERE group_churn_rate < max_index AND group_stability_index < max_stab),
tmp2 AS (
SELECT customer_id,  group_id, MIN(Group_Min_Discount) AS minn
FROM periods
GROUP BY customer_id,  group_id) 
SELECT tmp.customer_id AS c_id, group_name, tmp.group_id AS g_id, (ROUND(minn * 100. / 5. + 0.5) * 5)::NUMERIC AS G_Discount FROM tmp
JOIN tmp2 ON tmp.customer_id = tmp2.customer_id AND tmp.group_id=tmp2.group_id
JOIN sku_group ON sku_group.group_id = tmp.group_id
WHERE rank <= num_of_groups)
SELECT * FROM res;
END;
$$ LANGUAGE plpgsql;

-- Main function

CREATE OR REPLACE FUNCTION cross_sales(number_of_groups NUMERIC,
                                       index NUMERIC,
                                       max_index NUMERIC,
                                       max_part_SKU NUMERIC,
                                       permissible_part_margin NUMERIC)
RETURNS TABLE
    (
        "Customer_ID" BIGINT,
        "SKU_Name" VARCHAR,
        "Offer_Discount_Depth" NUMERIC
    )
AS $$
BEGIN
RETURN QUERY
WITH
res AS (
SELECT * FROM opt_choice(number_of_groups, index, max_index)),
tmp AS (
SELECT CustomersView.customer_id, Customer_Primary_Store, Product.group_id, Checks.sku_id, scu_retail_price,  scu_retail_price - sku_purchase_price AS max_mar
FROM CustomersView
JOIN Cards ON CustomersView.customer_id = Cards.customer_id
JOIN Transactions ON Cards.customer_card_id = Transactions.customer_card_id
JOIN Checks ON Checks.Transaction_id = Transactions.Transaction_id
JOIN Product ON Product.sku_id = Checks.sku_id
JOIN Stores ON Stores.sku_id = Product.sku_id),
ttt AS (
SELECT res.cos_id, res.g_id, sku_id, s_name, dis, scu_retail_price,  max_mar,
row_number() over (partition by res.cos_id, res.g_id order by max_mar DESC) as rank
FROM res
JOIN tmp ON res.cos_id = tmp.customer_id AND res.g_id = tmp.group_id
),
COUN AS (
SELECT Cards.customer_id, Product.group_id, Product.sku_id
FROM Cards
JOIN Transactions ON Cards.customer_card_id = Transactions.customer_card_id
JOIN Checks ON transactions.transaction_id = Checks.transaction_id
JOIN Product ON Product.sku_id = Checks.sku_id
JOIN sku_group ON Sku_group.group_id = Product.group_id),
Share_sku AS (
WITH
tmp AS (SELECT COUN.customer_id, COUN.group_id, COUNT(*) AS t1
FROM COUN
JOIN ttt ON COUN.customer_id = ttt.cos_id AND COUN.group_id = ttt.g_id AND COUN.sku_id = ttt.sku_id
WHERE rank = 1
GROUP BY COUN.customer_id, COUN.group_id
), tmp2 AS (
SELECT COUN.customer_id, COUN.group_id, COUNT(*) AS t2
FROM COUN
GROUP BY  COUN.customer_id, COUN.group_id
)
SELECT  tmp.customer_id, tmp.group_id , t1 / t2::NUMERIC AS sc
FROM tmp
JOIN tmp2 ON tmp.customer_id = tmp2.customer_id AND tmp.group_id = tmp2.group_id
),
Mar AS (
SELECT * FROM Share_sku
WHERE sc <= max_part_SKU
),
ok AS (
SELECT ttt.cos_id, s_name as nam, ttt.g_id, sku_id, dis,  max_mar*permissible_part_margin / scu_retail_price AS ert
FROM ttt
JOIN Mar ON Mar.customer_id = ttt.cos_id AND Mar.group_id = ttt.g_id
WHERE rank = 1)
SELECT cos_id,  nam, dis
FROM ok
WHERE dis < ert;
END;
$$ LANGUAGE plpgsql;


-- Testing

SELECT * FROM cross_sales(1, 100, 100, 1, 40);
SELECT * FROM cross_sales(4, 100, 100, 1, 40) WHERE "Customer_ID" >= 10;