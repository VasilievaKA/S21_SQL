CREATE OR REPLACE VIEW Purchase_history AS 
WITH UniqueCustomerTransactions AS (
SELECT PersonalInformation.customer_id,
       Transactions.transaction_id,
	   Transactions.transaction_date,
	   Transactions.transaction_store_id,
	   checks.sku_id,
	   Product.group_id,
	   Stores.sku_purchase_price,
	   checks.sku_amount,
	   checks.sku_sum,
	   checks.SKU_sum_paid
	   
FROM PersonalInformation
JOIN Cards ON Cards.customer_id = PersonalInformation.customer_id
JOIN Transactions ON Cards.customer_card_id = transactions.customer_card_id
JOIN Checks ON 	Transactions.transaction_id = Checks.transaction_id
JOIN Product ON Product.sku_id = checks.sku_id
JOIN Stores ON Stores.sku_id = checks.sku_id
	              AND Stores.transaction_store_id = transactions.transaction_store_id
)

SELECT customer_id,
       transaction_id,
	   transaction_date,
	   group_id,
	   SUM (sku_purchase_price * SKU_Amount)  AS Group_Cost,
	   SUM(sku_sum) AS Group_Summ,
       SUM(SKU_sum_paid) AS Group_Summ_Paid	   
FROM UniqueCustomerTransactions
GROUP BY 
       customer_id,
       transaction_id,
	   transaction_date,
	   group_id;
