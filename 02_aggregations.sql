-- ============================================================
-- SCM NCR SQL Project
-- File: 02_aggregations.sql
-- Category: COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING
-- Queries: 21 to 40
-- ============================================================


-- Q21: Total number of suppliers
SELECT COUNT(*) AS total_suppliers FROM suppliers;

-- Q22: Total number of products
SELECT COUNT(*) AS total_products FROM products;

-- Q23: Total number of NCR records
SELECT COUNT(*) AS total_ncr FROM ncr_tracking;

-- Q24: Total quantity rejected across all NCRs
SELECT SUM(ncr_qty) AS total_qty_rejected FROM ncr_tracking;

-- Q25: Average unit price of all products
SELECT ROUND(AVG(unit_price), 2) AS avg_unit_price FROM products;

-- Q26: Most expensive product price
SELECT MAX(unit_price) AS max_price FROM products;

-- Q27: Cheapest product price
SELECT MIN(unit_price) AS min_price FROM products;

-- Q28: Count of NCR records per project
SELECT project, COUNT(*) AS ncr_count
FROM ncr_tracking
GROUP BY project
ORDER BY ncr_count DESC;

-- Q29: Total NCR quantity rejected per project
SELECT project, SUM(ncr_qty) AS total_rejected
FROM ncr_tracking
GROUP BY project
ORDER BY total_rejected DESC;

-- Q30: Count of products per supplier
SELECT s.vendor_name, COUNT(p.product_id) AS product_count
FROM suppliers s
LEFT JOIN products p ON s.id = p.supplier_id
GROUP BY s.vendor_name
ORDER BY product_count DESC;

-- Q31: Count of RTV records by return status
SELECT return_status, COUNT(*) AS count
FROM rtv_tracking
GROUP BY return_status;

-- Q32: Total quantity dispatched via RTV
SELECT SUM(qty_sent) AS total_dispatched FROM rtv_tracking;

-- Q33: Average NCR quantity per car station
SELECT car_station, ROUND(AVG(ncr_qty), 2) AS avg_ncr_qty
FROM ncr_tracking
GROUP BY car_station
ORDER BY avg_ncr_qty DESC;

-- Q34: Suppliers with more than 5 products
SELECT s.vendor_name, COUNT(p.product_id) AS product_count
FROM suppliers s
JOIN products p ON s.id = p.supplier_id
GROUP BY s.vendor_name
HAVING COUNT(p.product_id) > 5;

-- Q35: Monthly NCR count in 2025
SELECT TO_CHAR(date, 'YYYY-MM') AS month, COUNT(*) AS ncr_count
FROM ncr_tracking
WHERE date >= '2025-01-01'
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month;

-- Q36: Total warehouse stock by location
SELECT location, SUM(availble_stock) AS total_stock
FROM warehouse_stock
GROUP BY location
ORDER BY total_stock DESC;

-- Q37: Count of purchase orders by supplier status
SELECT supplier_status, COUNT(*) AS po_count
FROM purchase_orders
GROUP BY supplier_status
ORDER BY po_count DESC;

-- Q38: Total qty sent in purchase orders by disposal type
SELECT disposal, SUM(qty_sent) AS total_qty
FROM purchase_orders
GROUP BY disposal
ORDER BY total_qty DESC;

-- Q39: NCR count per responsibility department
SELECT responsibility, COUNT(*) AS ncr_count
FROM ncr_tracking
GROUP BY responsibility
ORDER BY ncr_count DESC;

-- Q40: Average qty sent in RTV per month
SELECT TO_CHAR(dispatch_date, 'YYYY-MM') AS month,
       ROUND(AVG(qty_sent), 2) AS avg_qty
FROM rtv_tracking
GROUP BY TO_CHAR(dispatch_date, 'YYYY-MM')
ORDER BY month;
