CREATE OR REPLACE VIEW periods AS

WITH temp1 AS (
	SELECT
		Customer_ID,
		Group_ID,
		MIN(transaction_date) AS First_Group_Purchase_Date
	FROM
		Purchase_history
	GROUP BY
		Customer_ID,
		Group_ID

),
temp2 AS (
	SELECT
		temp1.Customer_ID,
		temp1.Group_ID,
		First_Group_Purchase_Date,
		MAX(transaction_date) AS Last_Group_Purchase_Date
	FROM
		temp1
	JOIN
		Purchase_history ON Purchase_history.Customer_ID = temp1.Customer_ID
		AND Purchase_history.Group_ID = temp1.Group_ID
	GROUP BY
		temp1.Customer_ID,
		temp1.Group_ID,
		First_Group_Purchase_Date

),
temp3 AS (
	SELECT
		temp2.Customer_ID,
		temp2.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date,
		COUNT(Transaction_ID) AS Group_Purchase
	FROM
		temp2
	JOIN
		Purchase_history ON Purchase_history.Customer_ID = temp2.Customer_ID
		AND Purchase_history.Group_ID = temp2.Group_ID
	GROUP BY
		temp2.Customer_ID,
		temp2.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date
),
temp4 AS (
	SELECT
		temp3.Customer_ID,
		temp3.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date,
		Group_Purchase,
		CASE
        	WHEN COUNT(purchase_history.transaction_id) = 1 THEN 1
        	ELSE (EXTRACT(EPOCH FROM (MAX(transaction_date) - MIN(transaction_date)))/ 86400.0 + 1) / (COUNT(purchase_history.transaction_id))
    	END AS Group_Frequency
	FROM
		temp3
	JOIN
		Purchase_history ON Purchase_history.Customer_ID = temp3.Customer_ID
		AND Purchase_history.Group_ID = temp3.Group_ID
	GROUP BY
		temp3.Customer_ID,
		temp3.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date,
		Group_Purchase
),
discount AS (
SELECT
	PersonalInformation.customer_id,
	group_id,
	sku_discount * 1.0/sku_sum as Group_Discount
FROM
	PersonalInformation
JOIN
	Cards ON Cards.Customer_ID = PersonalInformation.Customer_ID
JOIN
	Transactions ON Transactions.Customer_Card_ID = Cards.Customer_Card_ID
JOIN
	Checks ON Checks.transaction_id = Transactions.transaction_id
JOIN
	Product ON Product.SKU_ID = Checks.SKU_ID
GROUP BY
	PersonalInformation.customer_id,
	group_id,
	Group_Discount
ORDER BY
	customer_id,
	group_id
),


temp5 AS (
	SELECT
		temp4.Customer_ID,
		temp4.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date,
		Group_Purchase,
		Group_Frequency,
		CASE
			WHEN max(Group_Discount) = 0 THEN 0
			ELSE (min(Group_Discount) FILTER ( WHERE Group_Discount > 0 ))
		END AS Group_min_Discount
	FROM
		temp4
	JOIN
		discount ON discount.Customer_ID = temp4.Customer_ID
		AND discount.Group_ID = temp4.Group_ID
	GROUP BY
		temp4.Customer_ID,
		temp4.Group_ID,
		First_Group_Purchase_Date,
		Last_Group_Purchase_Date,
		Group_Purchase,
		Group_Frequency

)
SELECT *
FROM temp5;