-- DROP VIEW IF EXISTS CustomersView;
-- надо проверить с учетом импорта данных
CREATE VIEW CustomersView AS 
WITH temp1 AS (
  SELECT PersonalInformation.Customer_ID,
         SUM(Transaction_Sum)/COUNT(Transactions.Transaction_ID) AS Customer_Average_Check,
    	 NTILE(100) OVER (ORDER BY SUM(Transaction_Sum)/COUNT(Transactions.Transaction_ID) DESC) AS Customer_Average_Check_Segment,
-- NTILE - разбиваем на сегменты
		EXTRACT(EPOCH FROM ( MAX(transaction_date) - MIN(transaction_date)) / 86400.0 )/ COUNT(Transactions.Transaction_ID) AS Customer_Frequency,
-- расчет в секундах между транзакциями
		NTILE(100) OVER (ORDER BY EXTRACT(EPOCH FROM ( MAX(transaction_date) - MIN(transaction_date)) / 86400.0 )/ COUNT(Transactions.Transaction_ID)) AS Customer_Frequency_Segment,
--  	вот здесь надо бы добавить наше значение из импорта, которого пока нет, пишу то значение которое увидел
		EXTRACT(EPOCH FROM '2022.08.21 12:14:59'::TIMESTAMP - MAX(transaction_date)) / 86400.0  AS Customer_Inactive_Period
		FROM PersonalInformation
		JOIN Cards ON Cards.Customer_ID = PersonalInformation.Customer_ID
		JOIN Transactions ON Transactions.Customer_Card_ID = Cards.Customer_Card_ID
		GROUP BY PersonalInformation.Customer_ID
),
temp2  AS (
SELECT 
    Customer_ID,
    Customer_Average_Check,
-- 	начинаем разбивать на сегменты по границам
    CASE
      WHEN Customer_Average_Check_Segment <= 0.1 * (SELECT COUNT(*) FROM temp1) THEN 'High'
      WHEN Customer_Average_Check_Segment <= 0.35 * (SELECT COUNT(*) FROM temp1) THEN 'Medium'
      ELSE 'Low'
    END AS Customer_Average_Check_Segment,
	Customer_Frequency,
	CASE
      WHEN Customer_Frequency_Segment <= 0.1 * (SELECT COUNT(*) FROM temp1) THEN 'Often'
      WHEN Customer_Frequency_Segment <= 0.35 * (SELECT COUNT(*) FROM temp1) THEN 'Occasionally'
      ELSE 'Rarely'
    END AS Customer_Frequency_Segment,
	Customer_Inactive_Period,
	Customer_Inactive_Period / Customer_Frequency AS Customer_Churn_Rate,
	CASE
      WHEN Customer_Inactive_Period / Customer_Frequency <= 2  THEN 'Low'
      WHEN Customer_Inactive_Period / Customer_Frequency <= 5  THEN 'Medium'
      ELSE 'High'
    END AS Customer_Churn_Segment
	
FROM temp1
ORDER BY Customer_ID),
Customer_Primary_Store_Set AS (
	SELECT
	  Customer_ID,
	  Transaction_Store_ID,
	  ((TransactionCount * 100.0) / TotalTransactionCount) AS TransactionPercentage,
		(SELECT MAX(transaction_date) 
		 FROM Transactions 
		 JOIN Cards ON Cards.Customer_Card_ID = Transactions.Customer_Card_ID
		 WHERE list.Transaction_Store_ID = Transactions.Transaction_Store_ID
		AND Cards.Customer_ID = list.Customer_ID) AS last_transaction
	FROM (	  
		SELECT
			Customer_ID,
			Transaction_Store_ID,
			COUNT(Transaction_ID) AS TransactionCount,
			SUM(COUNT(Transaction_ID)) OVER (PARTITION BY Customer_ID) AS TotalTransactionCount
		  FROM Transactions
		  JOIN Cards ON Cards.Customer_Card_ID = Transactions.Customer_Card_ID
			GROUP BY Customer_ID, transaction_store_id
		 ) AS list
	ORDER BY Customer_ID, Transaction_Store_ID),
loyal_customers AS (
	SELECT Customer_ID
	FROM (
		SELECT
		  Customer_ID,
		  Transaction_Store_ID
		FROM (
			SELECT
				Customer_ID,
				Transaction_Store_ID,
				transaction_date,
				ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY transaction_date DESC) AS rn
		  FROM Transactions
		  JOIN Cards ON Cards.Customer_Card_ID = Transactions.Customer_Card_ID) AS list
	WHERE rn <= 3) list
	GROUP BY Customer_ID
	HAVING COUNT(DISTINCT Transaction_Store_ID) = 1
	
)
	SELECT 
		temp2.Customer_ID,
		Customer_Average_Check,
		Customer_Average_Check_Segment,
		Customer_Frequency,
		Customer_Frequency_Segment,
		Customer_Inactive_Period,
		Customer_Churn_Rate,
		Customer_Churn_Segment,
-- 		в соответствии с таблицей в папке матириалс присваеваем каждому сегменту свой номер
		(CASE
			WHEN Customer_Average_Check_Segment = 'Low' THEN
				CASE
					WHEN Customer_Frequency_Segment = 'Rarely' THEN 
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 1
							WHEN Customer_Churn_Segment = 'Medium' THEN 2
							WHEN Customer_Churn_Segment = 'High' THEN 3
						END
					WHEN Customer_Frequency_Segment = 'Occasionally' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 4
							WHEN Customer_Churn_Segment = 'Medium' THEN 5
							WHEN Customer_Churn_Segment = 'High' THEN 6
						END
					WHEN Customer_Frequency_Segment = 'Often' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 7
							WHEN Customer_Churn_Segment = 'Medium' THEN 8
							WHEN Customer_Churn_Segment = 'High' THEN 9
						END
				END
			WHEN Customer_Average_Check_Segment = 'Medium' THEN
				CASE
					WHEN Customer_Frequency_Segment = 'Rarely' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 10
							WHEN Customer_Churn_Segment = 'Medium' THEN 11
							WHEN Customer_Churn_Segment = 'High' THEN 12
						END
					WHEN Customer_Frequency_Segment = 'Occasionally' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 13
							WHEN Customer_Churn_Segment = 'Medium' THEN 14
							WHEN Customer_Churn_Segment = 'High' THEN 15
						END
					WHEN Customer_Frequency_Segment = 'Often' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 16
							WHEN Customer_Churn_Segment = 'Medium' THEN 17
							WHEN Customer_Churn_Segment = 'High' THEN 18
						END
				END
			WHEN Customer_Average_Check_Segment = 'High' THEN
				CASE
					WHEN Customer_Frequency_Segment = 'Rarely' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 19
							WHEN Customer_Churn_Segment = 'Medium' THEN 20
							WHEN Customer_Churn_Segment = 'High' THEN 21
						END
					WHEN Customer_Frequency_Segment = 'Occasionally' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 22
							WHEN Customer_Churn_Segment = 'Medium' THEN 23
							WHEN Customer_Churn_Segment = 'High' THEN 24
						END
					WHEN Customer_Frequency_Segment = 'Often' THEN
						CASE
							WHEN Customer_Churn_Segment = 'Low' THEN 25
							WHEN Customer_Churn_Segment = 'Medium' THEN 26
							WHEN Customer_Churn_Segment = 'High' THEN 27
						END
				END
		END) AS Customer_Segment,
		(CASE
			WHEN temp2.Customer_ID = (SELECT Customer_ID FROM loyal_customers) THEN 
		 		(SELECT
				  Transaction_Store_ID
				FROM (
					SELECT
						Customer_ID,
						Transaction_Store_ID,
						transaction_date,
						ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY transaction_date DESC) AS rn
				  	FROM Transactions
				  	JOIN Cards ON Cards.Customer_Card_ID = Transactions.Customer_Card_ID) AS list
				WHERE rn = 1 AND list.Customer_ID = temp2.Customer_ID)
-- 		проверка случая когда покупатель не покупал последние разы (3 раза) в одном магазине
		 ELSE
			(
				SELECT Transaction_Store_ID 
				FROM Customer_Primary_Store_Set
				WHERE Customer_Primary_Store_Set.Customer_ID = temp2.Customer_ID
				AND TransactionPercentage = (
					SELECT MAX(TransactionPercentage) AS bigest
					FROM Customer_Primary_Store_Set 
					WHERE Customer_Primary_Store_Set.Customer_ID = temp2.Customer_ID
					)
				AND last_transaction = ( 
					SELECT MAX(last_transaction)
				    FROM Customer_Primary_Store_Set
				    WHERE Customer_Primary_Store_Set.Customer_ID = temp2.Customer_ID
					AND TransactionPercentage = ( 
						SELECT MAX(TransactionPercentage) AS bigest
						FROM Customer_Primary_Store_Set 
					 	WHERE Customer_Primary_Store_Set.Customer_ID = temp2.Customer_ID)))

		END) AS Customer_Primary_Store
	FROM temp2
	FULL JOIN loyal_customers ON loyal_customers.Customer_ID = temp2.Customer_ID;
	
-- SELECT * FROM CustomersView
