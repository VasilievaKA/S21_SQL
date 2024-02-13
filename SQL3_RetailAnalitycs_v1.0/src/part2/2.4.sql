CREATE OR REPLACE FUNCTION fnc_count_margin(Cust_ID bigint, Gr_ID bigint,count_type integer DEFAULT 1, param integer DEFAULT NULL) RETURNS numeric AS
$$
DECLARE
	limit_date TIMESTAMP;
	BEGIN
		IF count_type = 1 THEN
			IF param IS NULL THEN
				param := 1e+6;
			END IF;
			limit_date := CURRENT_TIMESTAMP - param * INTERVAL '1 day';
			RETURN (
			SELECT
				SUM(Group_Summ_Paid-group_cost)::NUMERIC AS Group_Margin
			FROM purchase_history
			WHERE purchase_history.Customer_ID = Cust_ID
			AND purchase_history.Group_ID = Gr_ID
			AND transaction_date > limit_date
			GROUP BY 
					customer_id, 
					group_id
				   );
		
		ELSIF count_type = 2 THEN
			IF param IS NULL THEN
				param := (SELECT COUNT(Transaction_ID)FROM purchase_history) ;
			END IF;
			RETURN (
			SELECT
				SUM(Group_Summ_Paid-group_cost)::NUMERIC AS Group_Margin
			FROM (SELECT * 
				  FROM 
				  	purchase_history
				  WHERE purchase_history.Customer_ID = Cust_ID
				  AND purchase_history.Group_ID = Gr_ID
				  ORDER BY transaction_date DESC
				  LIMIT param) AS list);
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP VIEW IF EXISTS GroupsView;
CREATE VIEW GroupsView AS

WITH Groups_list_for_every_customer AS (
	SELECT
		Customer_ID,
		Group_ID
	FROM 
		Transactions
	JOIN
		Cards ON Cards.Customer_Card_ID = Transactions.Customer_Card_ID
	JOIN
		Checks ON Checks.transaction_id = Transactions.Transaction_ID
	JOIN
		Product ON Product.SKU_ID = Checks.SKU_ID
	GROUP BY 
		Customer_ID, Group_ID/*Дедубликация путем группировки*/
	ORDER BY 
		Customer_ID, Group_ID
),

Calculation_of_demand AS (
	SELECT
		Groups_list_for_every_customer.Customer_ID,
		Groups_list_for_every_customer.Group_ID,
		(Group_Purchase * 1.0/COUNT(purchase_history.Transaction_ID)) AS Group_Affinity_Index
	FROM
		Groups_list_for_every_customer
	JOIN
		purchase_history ON Groups_list_for_every_customer.Customer_ID = purchase_history.Customer_ID
	JOIN
		periods ON Groups_list_for_every_customer.Customer_ID = periods.Customer_ID
		AND periods.Group_ID = Groups_list_for_every_customer.Group_ID
	WHERE
		transaction_date BETWEEN periods.First_Group_Purchase_Date AND periods.Last_Group_Purchase_Date
	GROUP BY
		Groups_list_for_every_customer.Customer_ID, Groups_list_for_every_customer.Group_ID, Group_Purchase
		
),

Count_Churn_Index AS (
	SELECT
		Calculation_of_demand.Customer_ID,
		Calculation_of_demand.Group_ID,
		Group_Affinity_Index,
		EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - MAX(purchase_history.transaction_date)))/periods.Group_Frequency / 86400.0 AS Group_Churn_Rate
	FROM
		Calculation_of_demand
	JOIN
		purchase_history ON purchase_history.Customer_ID = Calculation_of_demand.Customer_ID 
		AND purchase_history.Group_ID = Calculation_of_demand.Group_ID
	JOIN
		periods ON periods.Customer_ID = Calculation_of_demand.Customer_ID 
		AND periods.Group_ID = Calculation_of_demand.Group_ID
	GROUP BY
		Calculation_of_demand.Customer_ID, Calculation_of_demand.Group_ID, Group_Affinity_Index, Group_Frequency
),

Count_Group_Consumption_Stability_1 AS (
	SELECT 
		Count_Churn_Index.Customer_ID,
		Count_Churn_Index.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		EXTRACT(EPOCH FROM (transaction_date - LAG(transaction_date) OVER (PARTITION BY 
																				   	Count_Churn_Index.Customer_ID,
																				  	Count_Churn_Index.Group_ID	
																				   	ORDER BY 
																				   	transaction_date))) / 86400.0 AS result_
	FROM 
		Count_Churn_Index
	JOIN
		purchase_history ON purchase_history.Customer_ID = Count_Churn_Index.Customer_ID 
		AND purchase_history.Group_ID = Count_Churn_Index.Group_ID
	ORDER BY
		Count_Churn_Index.Customer_ID, Count_Churn_Index.Group_ID, transaction_date
),

Count_Group_Consumption_Stability_2 AS (
	SELECT 
		Count_Group_Consumption_Stability_1.Customer_ID,
		Count_Group_Consumption_Stability_1.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		ABS(result_ - periods.Group_Frequency) AS result_
	FROM 
		Count_Group_Consumption_Stability_1
	JOIN
		periods ON periods.Customer_ID = Count_Group_Consumption_Stability_1.Customer_ID 
		AND periods.Group_ID = Count_Group_Consumption_Stability_1.Group_ID
	ORDER BY
		Customer_ID, Group_ID
),

Count_Group_Consumption_Stability_3 AS (
	SELECT 
		Count_Group_Consumption_Stability_2.Customer_ID,
		Count_Group_Consumption_Stability_2.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		result_ / Group_Frequency  AS result_
	FROM 
		Count_Group_Consumption_Stability_2
	JOIN
		periods ON periods.Customer_ID = Count_Group_Consumption_Stability_2.Customer_ID 
		AND periods.Group_ID = Count_Group_Consumption_Stability_2.Group_ID
	ORDER BY
		Customer_ID, Group_ID
),

Count_Group_Consumption_Stability_4 AS (
	SELECT 
		Customer_ID,
		Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		AVG(result_) AS Group_Stability_Index
	FROM 
		Count_Group_Consumption_Stability_3
	GROUP BY
		Customer_ID,
		Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate
	ORDER BY
		Customer_ID, 
		Group_ID
),

count_margin AS (
	SELECT 
		Customer_ID,
		Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		fnc_count_margin(Customer_ID,Group_ID) AS Group_Margin
	FROM 
		Count_Group_Consumption_Stability_4
	GROUP BY
		Customer_ID,
		Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index
	ORDER BY
		Customer_ID, 
		Group_ID
),


count_transactions_with_discount AS (
	SELECT 
		count_margin.Customer_ID,
		count_margin.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		COUNT(Checks.transaction_id) FILTER(WHERE SKU_Discount > 0) AS transactions_with_discount
	FROM 
		count_margin
	JOIN
		Cards ON Cards.Customer_ID = count_margin.Customer_ID
	JOIN
		Transactions ON Transactions.Customer_Card_ID = Cards.Customer_Card_ID
	JOIN
		Checks ON Checks.transaction_id = Transactions.transaction_id
	JOIN
		Product ON Product.Group_ID = count_margin.Group_ID
		AND Product.SKU_ID = Checks.SKU_ID
	GROUP BY
		count_margin.Customer_ID,
		count_margin.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin
	ORDER BY
		Customer_ID, 
		Group_ID
),

Group_Discount_Share AS (
	SELECT 
		count_transactions_with_discount.Customer_ID,
		count_transactions_with_discount.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		transactions_with_discount * 1.0/ Group_Purchase AS Group_Discount_Share
	FROM 
		count_transactions_with_discount
	JOIN
		periods ON count_transactions_with_discount.Customer_ID = periods.Customer_ID 
		AND count_transactions_with_discount.Group_ID = periods.Group_ID
	GROUP BY
		count_transactions_with_discount.Customer_ID,
		count_transactions_with_discount.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		Group_Discount_Share
	ORDER BY
		Customer_ID, 
		Group_ID
),

Group_Minimum_Discount AS (
	SELECT 
		Group_Discount_Share.Customer_ID,
		Group_Discount_Share.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		Group_Discount_Share,
		MIN(Group_Min_Discount) FILTER (WHERE group_min_discount > 0) AS Group_Minimum_Discount
	FROM 
		Group_Discount_Share
	JOIN
		periods ON Group_Discount_Share.Customer_ID = periods.Customer_ID 
		AND Group_Discount_Share.Group_ID = periods.Group_ID
	GROUP BY
		Group_Discount_Share.Customer_ID,
		Group_Discount_Share.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		Group_Discount_Share
	ORDER BY
		Customer_ID, 
		Group_ID
),

Group_avg_Discount AS (
	SELECT 
		Group_Minimum_Discount.Customer_ID,
		Group_Minimum_Discount.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		fnc_count_margin(Group_Minimum_Discount.Customer_ID,Group_Minimum_Discount.Group_ID) AS Group_Margin,/*Задать тип рассчета маржинальности*/
		Group_Discount_Share,
		Group_Minimum_Discount,
		SUM(Group_Summ_Paid)/SUM(Group_Summ) AS Group_Average_Discount
	FROM 
		Group_Minimum_Discount
	JOIN
		purchase_history ON purchase_history.Customer_ID = Group_Minimum_Discount.Customer_ID
		AND purchase_history.Group_ID = Group_Minimum_Discount.Group_ID
		AND Group_Summ_Paid != Group_Summ
	GROUP BY
		Group_Minimum_Discount.Customer_ID,
		Group_Minimum_Discount.Group_ID,
		Group_Affinity_Index,
		Group_Churn_Rate,
		Group_Stability_Index,
		Group_Margin,
		Group_Discount_Share,
		Group_Minimum_Discount
	ORDER BY
		Customer_ID, 
		Group_ID
) SELECT * FROM Group_avg_Discount;

-- SELECT * FROM GroupsView