------------------------------  ANALYSIS ON PYTHON  --------------------------------

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--Annual Sales Trend
------------------------------------------------------------------------------------

SELECT
	DATE_TRUNC('month', shipped_date)::DATE AS date,
	SUM(od.unit_price * quantity) AS total_price,
	COUNT(o.order_id) total_order
FROM orders AS o
	
	JOIN order_details AS od 
		ON o.order_id = od.order_id
	
	JOIN products AS P 
	ON od.product_id = p.product_id
WHERE NOT shipped_date IS NULL
GROUP BY 1
ORDER BY 1

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- **Category Based**
SELECT * from categories
select * from products
select * from suppliers
select * from customers
select * from order_details

------------------------------------------------------------------------------------
----Number of categories and sales
------------------------------------------------------------------------------------
	
SELECT
	c.category_name,
	COUNT(o.order_id)
FROM
	categories AS c
	
	JOIN PRODUCTS AS p 
		ON p.category_id = c.category_id
	
	JOIN order_details AS od 
		ON od.product_id = p.product_id
	
	JOIN orders AS o 
		ON o.order_id = od.order_id
	
	JOIN customers AS cs 
		ON cs.customer_id = o.customer_id
	
GROUP BY 1
ORDER BY 2 DESC
	
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----Number of product
------------------------------------------------------------------------------------
	
WITH top_10_product AS (
    SELECT 
        p.product_name,
        c.category_name,
        COUNT(o.order_id) AS total_order
    FROM categories AS c
	
    	JOIN products AS p
        	ON p.category_id = c.category_id
	
    	JOIN order_details AS od
        	ON od.product_id = p.product_id
	
    	JOIN orders AS o
       		ON o.order_id = od.order_id
	
   		JOIN customers AS cs
       		ON cs.customer_id = o.customer_id
	
    GROUP BY 1, 2
    ORDER BY 3 DESC
    LIMIT 10
)
SELECT 
    CONCAT(product_name, ' (', category_name, ')') AS product_with_category,
    total_order
FROM top_10_product;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----Categorical sales and total units
------------------------------------------------------------------------------------

SELECT
	c.category_name,
	DATE_TRUNC('month', shipped_date)::DATE AS date,
	round((SUM((od.unit_price - od.unit_price*discount) * quantity))::int,2) AS total_price,
	COUNT(o.order_id) total_order
FROM categories AS c
	
    JOIN products AS p
        ON p.category_id = c.category_id
	
    JOIN order_details AS od
        ON od.product_id = p.product_id
	
    JOIN orders AS o
        ON o.order_id = od.order_id
	
    JOIN customers AS cs
        ON cs.customer_id = o.customer_id
	
WHERE NOT shipped_date IS NULL
GROUP BY 1,2
ORDER BY 1,2

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
	
SELECT
	c.category_name,
	COUNT(p.product_name)
FROM
	categories AS c
	
	JOIN products AS p 
		ON p.category_id = c.category_id
	
GROUP BY 1
ORDER BY 1

-----------------------------  ANALYSIS ON POWER BI  -------------------------------
	
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Customer Analysis(Segmented)
------------------------------------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.company_name,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::INT, 2) AS total_revenue
    FROM customers AS c
    
		JOIN orders AS o 
			ON c.customer_id = o.customer_id
    	
		JOIN order_details AS od 
			ON o.order_id = od.order_id
    	
	WHERE NOT o.shipped_date IS NULL
	GROUP BY 1, 2
),
segmented_customers AS (
    SELECT
        customer_id,
        company_name,
        total_revenue,
        CASE 
            WHEN total_revenue <= 5000 THEN 'Low Revenue'
            WHEN total_revenue > 5000 AND total_revenue <= 20000 THEN 'Medium Revenue'
            ELSE 'High Revenue'
        END AS revenue_category
    FROM 
        customer_revenue
)
SELECT
    c.company_name,
    c.city,
    p.product_name AS product,
    cs.category_name AS category,
    ROUND((od.unit_price * od.quantity * (1 - od.discount))::INT, 2) AS price,
    sc.revenue_category
FROM customers AS c
    
	JOIN orders AS o 
		ON c.customer_id = o.customer_id
    
	JOIN order_details AS od 
		ON o.order_id = od.order_id
    
	JOIN products AS p 
		ON od.product_id = p.product_id
    
	JOIN categories AS cs 
		ON p.category_id = cs.category_id
    
	JOIN segmented_customers AS sc 
		ON c.customer_id = sc.customer_id
	
WHERE NOT o.shipped_date IS NULL
ORDER BY price DESC

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- Employee Analysis
------------------------------------------------------------------------------------
	
select * from employees
select * from employee_territories
select * from territories
select * from region
select * from orders
select * from order_details
	
------------------------------------------------------------------------------------	

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.company_name,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::INT, 2) AS total_revenue
    FROM customers AS c
    
		JOIN orders AS o 
			ON c.customer_id = o.customer_id
    	
		JOIN order_details AS od 
			ON o.order_id = od.order_id
    	
	WHERE NOT o.shipped_date IS NULL
	GROUP BY 1, 2
),
segmented_customers AS (
    SELECT
        customer_id,
        company_name,
        total_revenue,
        CASE 
            WHEN total_revenue <= 5000 THEN 'Low Revenue'
            WHEN total_revenue > 5000 AND total_revenue <= 20000 THEN 'Medium Revenue'
            ELSE 'High Revenue'
        END AS revenue_category
    FROM customer_revenue
)
SELECT
	e.employee_id,
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
	ROUND(((od.unit_price * od.quantity) * (1 - od.discount))::INT,2) AS net_amount,
	od.discount,
	ROUND(((od.unit_price * od.quantity) - ((od.unit_price * od.quantity) * (1 - od.discount)))::INT,2) AS discount_amount,
	ROUND(((od.unit_price * od.quantity))::INT, 2) AS amount_without_disc,
	cs.company_name,
	revenue_category,
	c.category_name,
	p.product_name,
	DATE_TRUNC('MONTH', O.SHIPPED_DATE)::DATE AS date
FROM
	employees AS e
	
	JOIN orders AS o 
		ON o.employee_id = e.employee_id
	
	JOIN customers AS cs 
		ON cs.customer_id = o.customer_id
	
	JOIN order_details AS od 
		ON OD.ORDER_ID = O.ORDER_ID
	
	JOIN products AS p 
		ON p.product_id = od.product_id
	
	JOIN categories AS c 
		ON c.category_id = p.category_id
	
	JOIN segmented_customers AS sc 
		ON cs.customer_id = sc.customer_id

	WHERE NOT shipped_date IS NULL

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------	
----Inventory Analysis
--PS. I treated units_on_order as orders received by Nortwind.
------------------------------------------------------------------------------------
WITH ranked_products AS (
    SELECT
        c.category_name,
        p.product_name,
        SUM(od.quantity) AS total_sold,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::INT, 2) AS total_revenue,
        p.units_in_stock AS current_stock,
        p.units_on_order,
        p.reorder_level,
        CASE
            WHEN (p.units_in_stock + p.units_on_order) < p.reorder_level THEN 'Critical'
            WHEN p.units_in_stock = 0 THEN 'Out of Stock'
            ELSE 'Adequate'
        END AS stock_status,
        NTILE(3) OVER (ORDER BY p.units_in_stock ASC) AS stock_level_rank
    FROM products AS p
	
        JOIN order_details AS od 
			ON p.product_id = od.product_id
        
		JOIN categories AS c 
			ON c.category_id = p.category_id
        
		JOIN orders AS o 
			ON od.order_id = o.order_id
    
	GROUP BY c.category_name, p.product_name, p.units_in_stock, p.units_on_order, p.reorder_level
)
SELECT 
    category_name,
    product_name,
    total_sold,
    total_revenue,
    current_stock,
    units_on_order,
    reorder_level,
    stock_status,
    CASE
        WHEN stock_level_rank = 1 THEN 'Low Level'
        WHEN stock_level_rank = 2 THEN 'Mid Level'
        WHEN stock_level_rank = 3 THEN 'High Level'
    END AS stock_level
FROM ranked_products
ORDER BY total_sold DESC;


----P.S.: You can set the stock area according to the categories and 
----save space accordingly.

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
----Shipper Analysis
------------------------------------------------------------------------------------

 SELECT
	s.company_name AS shipper_name,
	COUNT(o.order_id) AS total_orders,
	ROUND(AVG(o.freight)::INT, 2) AS avg_freight_cost,
	SUM(
		CASE
			WHEN o.shipped_date > o.required_date THEN 1
			ELSE 0
		END
	) AS late_deliveries
FROM
	shippers AS s
	 
	JOIN orders AS o 
		ON s.shipper_id = o.ship_via
	 
WHERE o.shipped_date IS NOT NULL
GROUP BY 1
