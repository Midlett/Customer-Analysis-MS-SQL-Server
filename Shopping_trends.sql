-- Loading first dataset

SELECT *
FROM ShoppingTrends..Shopping_Trends_c
ORDER BY customer_id;

-- Loading second dataset

SELECT * 
FROM ShoppingTrends..Shopping_Trends_p
ORDER BY customer_id;

-- Merging two datasets in order to make one table with all informations (without second customer_id)

CREATE VIEW MergeTables AS
SELECT 
	c.customer_id,
	c.age,
	c.gender,
	c.item_purchased,
	c.category,
	c.purchase_amount_usd,
	c.location,
	c.size,
	c.color,
	c.season,
	c.review_rating,
	p.subscription_status,
	p.shipping_type,
	p.discount_applied,
	p.promo_code_used,
	p.previous_purchases,
	p.payment_method,
	p.frequency_of_purchases
FROM ShoppingTrends..Shopping_Trends_c AS c
LEFT JOIN ShoppingTrends..Shopping_Trends_p AS p
	ON c.customer_id = p.customer_id;

SELECT *
FROM MergeTables

-- Finding min and max customers age

SELECT
	MAX(age) AS max_age,
	MIN(age) AS min_age
FROM ShoppingTrends..Shopping_Trends_c;

-- Grouping customers based on their age
WITH c_age AS 
(
	SELECT
		customer_id,
		COUNT(*) OVER() AS total_customers,
		CASE WHEN age <= 31 THEN '18 - 31'
		WHEN age BETWEEN 32 AND 44 THEN '32 - 44'
		WHEN age BETWEEN 45 AND 57 THEN '45 - 57'
		WHEN age BETWEEN 58 AND 70 THEN '50 - 70'
		END AS age_cat
	FROM ShoppingTrends..Shopping_Trends_c
)
SELECT 
	age_cat,
	COUNT(*) AS customers,
	ROUND((COUNT(*) * 100.0 / total_customers), 2) AS total_customers_percentage
FROM c_age
GROUP BY age_cat, total_customers;

-- Finding average age of customers

SELECT
	ROUND(AVG(age),0) AS avg_age
FROM ShoppingTrends..Shopping_Trends_c;

-- Finding total purchase amount for each product category

SELECT 
	category,
	SUM(purchase_amount_usd) as purchase_amount
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY category
ORDER BY purchase_amount DESC;


-- Finding total orders amount for each age group and product category

WITH c_age AS 
(
	SELECT
		customer_id,
		category,
		COUNT(*) OVER() AS total_orders,
		CASE WHEN age <= 31 THEN '18 - 31'
		WHEN age BETWEEN 32 AND 44 THEN '32 - 44'
		WHEN age BETWEEN 45 AND 57 THEN '45 - 57'
		WHEN age BETWEEN 58 AND 70 THEN '50 - 70'
		END AS age_cat
	FROM ShoppingTrends..Shopping_Trends_c
)
SELECT 
	age_cat,
	category,
	COUNT(*) as orders,
	ROUND((COUNT(*) * 100.0 / total_orders), 2) AS total_orders_percentage
FROM c_age
GROUP BY age_cat, category, total_orders
ORDER BY category, age_cat, orders DESC;

-- Finding average review rating for male and female customers separately

SELECT 
	gender,
	ROUND(AVG(review_rating),2) as avg_review
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY gender;

-- Finding the most common payment method used by customers
 
SELECT 
	Top 1 payment_method, 
	COUNT(payment_method) AS transactions
FROM ShoppingTrends..Shopping_Trends_p
GROUP BY payment_method
ORDER BY transactions DESC;

-- Quick look at all payment methods

SELECT 
	payment_method, 
	COUNT(payment_method) AS transactions
FROM ShoppingTrends..Shopping_Trends_p
GROUP BY payment_method
ORDER BY transactions DESC;

-- How many customers have opted for the Subscription ?

SELECT 
	subscription_status,
	COUNT(*) AS customers
FROM ShoppingTrends..Shopping_Trends_p
GROUP BY subscription_status;

-- What is the average purchase amount for customers with a subscription status?

SELECT 
	p.subscription_status,
	ROUND(AVG(c.purchase_amount_usd),2) AS avg_purchase_amount
FROM ShoppingTrends..Shopping_Trends_c AS c
LEFT JOIN ShoppingTrends..Shopping_Trends_p AS p
	ON c.customer_id = p.customer_id
GROUP BY p.subscription_status;

-- What is the most common season for purchases?

SELECT 
	TOP 1 season,
	COUNT(*) AS purchases
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY season
ORDER BY purchases DESC;

SELECT 
	TOP 1 season,
	COUNT(*) AS purchases
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY season
ORDER BY purchases DESC;

-- Quick glance at all seasons

SELECT 
	season,
	COUNT(*) AS purchases
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY season
ORDER BY purchases DESC;

-- What is the total purchase amount for each gender?

SELECT 
	gender,
	SUM(purchase_amount_usd) AS sum_purchase_amount_usd
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY gender
ORDER BY sum_purchase_amount_usd DESC;

-- How many customers used a promo code for their purchase?

SELECT 
	discount_applied,
	COUNT(*) AS customers
FROM ShoppingTrends..Shopping_Trends_p
GROUP BY discount_applied;

-- What is the maximum and minimum review rating in the dataset?

SELECT 
	ROUND(MIN(review_rating), 4) AS min_rating,
	ROUND(MAX(review_rating), 4) AS max_rating
FROM ShoppingTrends..Shopping_Trends_c;

-- What is the most common shipping type for customers with a review rating above 4?

SELECT 
	ROUND(MIN(review_rating), 4) AS min_rating,
	ROUND(MAX(review_rating), 4) AS max_rating
FROM ShoppingTrends..Shopping_Trends_c;

-- What is the total purchase amount for customers in each location?

SELECT 
	location,
	SUM(purchase_amount_usd) AS purchase_amount_usd
FROM ShoppingTrends..Shopping_Trends_c
GROUP BY location
ORDER BY location, purchase_amount_usd DESC;

-- What is the frequency distribution of the 'Frequency of Purchases' column?

SELECT 
	frequency_of_purchases,
	COUNT(*) AS count_of_frequency_of_purchases
FROM ShoppingTrends..Shopping_Trends_p
GROUP BY frequency_of_purchases
ORDER BY count_of_frequency_of_purchases DESC;

-- What is the average purchase amount for each color of items ?

SELECT 
	color,
	AVG(purchase_amount_usd) AS purchase_amount_usd
FROM ShoppingTrends..Shopping_Trends_c 
GROUP BY color
ORDER BY purchase_amount_usd DESC;

-- Ranking of 10 most profitable items in shop

WITH avg_item_costs AS (
	SELECT
		item_purchased,
		ROUND(AVG(purchase_amount_usd),2) AS purchase_amount_usd
	FROM ShoppingTrends..Shopping_Trends_c 
	GROUP BY item_purchased
)
SELECT 
	TOP 10 item_purchased,
	DENSE_RANK() OVER(ORDER BY purchase_amount_usd DESC) AS avg_item_cost_ranking,
	purchase_amount_usd
FROM avg_item_costs
GROUP BY item_purchased, purchase_amount_usd
ORDER BY purchase_amount_usd DESC;

-- What is the average age of customers who purchased accessories with a discount applied?

SELECT 
	ROUND(AVG(c.age),2) AS avg_age
FROM ShoppingTrends..Shopping_Trends_c AS c
LEFT JOIN ShoppingTrends..Shopping_Trends_p AS p
	ON c.customer_id = p.customer_id
WHERE c.category = 'Accessories' 
	AND p.discount_applied = 'Yes';

--- What are the 5 most common locations for customers who purchased socks with a discount applied?

SELECT 
	TOP 5 location AS common_location_socks_discount,
	COUNT(*) AS sold_socks
FROM ShoppingTrends..Shopping_Trends_c AS c
LEFT JOIN ShoppingTrends..Shopping_Trends_p AS p
	ON c.customer_id = p.customer_id
WHERE c.item_purchased = 'Socks' 
	AND p.discount_applied = 'Yes'
group by location
ORDER BY COUNT(*) DESC;

-- What is the average purchase amount among customers aged 18 to 35, who have a subscription, used payment method ending with "Pal", and applied a promo code?
	
SELECT 
	ROUND(AVG(purchase_amount_usd), 2) AS avg_purchase_amount_usd
FROM ShoppingTrends..Shopping_Trends_c AS c
LEFT JOIN ShoppingTrends..Shopping_Trends_p AS p
	ON c.customer_id = p.customer_id
WHERE c.age BETWEEN 18 AND 35
	AND p.discount_applied = 'Yes'
	AND payment_method LIKE '%Pal'
	AND p.subscription_status = 'Yes';
