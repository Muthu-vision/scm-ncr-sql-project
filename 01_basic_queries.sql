-- ============================================================
-- SCM NCR SQL Project
-- File: 01_basic_queries.sql
-- Category: Basic SELECT, WHERE, ORDER BY, LIMIT, LIKE
-- Queries: 1 to 20
-- ============================================================


-- Q1: List all suppliers
SELECT * FROM suppliers;

-- Q2: List all products
SELECT * FROM products;

-- Q3: List all NCR records
SELECT * FROM ncr_tracking;

-- Q4: List all purchase orders
SELECT * FROM purchase_orders;

-- Q5: List all RTV records
SELECT * FROM rtv_tracking;

-- Q6: List all warehouse stock
SELECT * FROM warehouse_stock;

-- Q7: Get all suppliers from Mumbai
SELECT * FROM suppliers
WHERE city = 'Mumbai';

-- Q8: Get all products with unit price greater than 100000
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > 100000;

-- Q9: Get all NCR records raised in January 2025
SELECT * FROM ncr_tracking
WHERE date BETWEEN '2025-01-01' AND '2025-01-31';

-- Q10: Get all RTV records with status 'Pending'
SELECT * FROM rtv_tracking
WHERE return_status = 'Pending';

-- Q11: Get all RTV records with status 'Received'
SELECT * FROM rtv_tracking
WHERE return_status = 'Received';

-- Q12: Get top 10 most expensive products
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- Q13: Get cheapest 5 products
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price ASC
LIMIT 5;

-- Q14: Get all products belonging to project CMR1
SELECT * FROM products
WHERE project_name = 'CMR1';

-- Q15: Get all NCR records where disposal is 'RTV'
SELECT * FROM ncr_tracking
WHERE disposal = 'RTV';

-- Q16: Get supplier details for supplier id = 1
SELECT * FROM suppliers
WHERE id = 1;

-- Q17: Get all products whose part number starts with 'BP'
SELECT * FROM products
WHERE part_number LIKE 'BP%';

-- Q18: Get all NCR records ordered by date descending
SELECT * FROM ncr_tracking
ORDER BY date DESC;

-- Q19: Get warehouse stock where available stock is less than 10
SELECT * FROM warehouse_stock
WHERE availble_stock < 10;

-- Q20: Get distinct project names from products table
SELECT DISTINCT project_name FROM products;
