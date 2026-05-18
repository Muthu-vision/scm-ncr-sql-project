-- ============================================================
-- SCM NCR SQL Project
-- File: 04_subqueries.sql
-- Category: Subqueries, EXISTS, IN, NOT IN, Correlated
-- Queries: 61 to 80
-- ============================================================


-- Q61: Products with unit price above average price
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- Q62: Supplier with the most products
SELECT vendor_name FROM suppliers
WHERE id = (
    SELECT supplier_id FROM products
    GROUP BY supplier_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Q63: NCR records for products supplied by Mumbai suppliers
SELECT * FROM ncr_tracking
WHERE product_id IN (
    SELECT p.product_id FROM products p
    INNER JOIN suppliers s ON p.supplier_id = s.id
    WHERE s.city = 'Mumbai'
);

-- Q64: Products that have never had an NCR
SELECT product_id, product_name FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM ncr_tracking
    WHERE product_id IS NOT NULL
);

-- Q65: RTV records where qty sent is more than average
SELECT * FROM rtv_tracking
WHERE qty_sent > (SELECT AVG(qty_sent) FROM rtv_tracking);

-- Q66: NCR records with the highest qty rejected
SELECT * FROM ncr_tracking
WHERE ncr_qty = (SELECT MAX(ncr_qty) FROM ncr_tracking);

-- Q67: Suppliers who have NCR complaints
SELECT vendor_name FROM suppliers
WHERE id IN (
    SELECT DISTINCT p.supplier_id FROM products p
    INNER JOIN ncr_tracking n ON p.product_id = n.product_id
);

-- Q68: Suppliers with NO NCR complaints (reliable suppliers)
SELECT vendor_name, city FROM suppliers
WHERE id NOT IN (
    SELECT DISTINCT p.supplier_id FROM products p
    INNER JOIN ncr_tracking n ON p.product_id = n.product_id
    WHERE p.supplier_id IS NOT NULL
);

-- Q69: Products with NCR qty greater than average NCR qty
SELECT DISTINCT p.product_name, p.part_number
FROM products p
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
WHERE n.ncr_qty > (SELECT AVG(ncr_qty) FROM ncr_tracking);

-- Q70: NCR records that have a matching RTV record
SELECT * FROM ncr_tracking
WHERE ncr_no IN (
    SELECT DISTINCT ncr_no FROM rtv_tracking
);

-- Q71: NCR records that do NOT have RTV raised yet
SELECT ncr_no, date, product_id, ncr_qty, disposal
FROM ncr_tracking
WHERE ncr_no NOT IN (
    SELECT DISTINCT ncr_no FROM rtv_tracking
    WHERE ncr_no IS NOT NULL
);

-- Q72: Purchase orders for products above average price
SELECT po.po_id, po.purchase_order, p.product_name, p.unit_price
FROM purchase_orders po
INNER JOIN products p ON po.product_id = p.product_id
WHERE p.unit_price > (SELECT AVG(unit_price) FROM products);

-- Q73: Warehouse stock below minimum threshold (below 5)
SELECT w.stock_id, p.product_name, w.availble_stock, s.vendor_name
FROM warehouse_stock w
INNER JOIN products p ON w.product_id = p.product_id
INNER JOIN suppliers s ON w.supplier_id = s.id
WHERE w.availble_stock < 5;

-- Q74: Top 3 suppliers by total NCR qty using subquery
SELECT vendor_name, total_ncr FROM (
    SELECT s.vendor_name, SUM(n.ncr_qty) AS total_ncr
    FROM suppliers s
    INNER JOIN products p ON s.id = p.supplier_id
    INNER JOIN ncr_tracking n ON p.product_id = n.product_id
    GROUP BY s.vendor_name
) ranked
ORDER BY total_ncr DESC
LIMIT 3;

-- Q75: Products ordered in purchase orders but not in warehouse
SELECT DISTINCT p.product_name FROM products p
WHERE p.product_id IN (SELECT product_id FROM purchase_orders)
AND p.product_id NOT IN (SELECT product_id FROM warehouse_stock);

-- Q76: Latest NCR date per product
SELECT product_id,
       (SELECT MAX(date) FROM ncr_tracking n2
        WHERE n2.product_id = n1.product_id) AS latest_ncr_date
FROM ncr_tracking n1
GROUP BY product_id;

-- Q77: Suppliers where all products are above 50000 price
SELECT vendor_name FROM suppliers s
WHERE NOT EXISTS (
    SELECT 1 FROM products p
    WHERE p.supplier_id = s.id
    AND p.unit_price <= 50000
);

-- Q78: NCR records in months with more than 5 NCRs
SELECT * FROM ncr_tracking
WHERE TO_CHAR(date, 'YYYY-MM') IN (
    SELECT TO_CHAR(date, 'YYYY-MM')
    FROM ncr_tracking
    GROUP BY TO_CHAR(date, 'YYYY-MM')
    HAVING COUNT(*) > 5
);

-- Q79: Products with both NCR and warehouse stock records
SELECT p.product_name FROM products p
WHERE EXISTS (SELECT 1 FROM ncr_tracking n WHERE n.product_id = p.product_id)
AND EXISTS (SELECT 1 FROM warehouse_stock w WHERE w.product_id = p.product_id);

-- Q80: RTV pending records older than 30 days from dispatch
SELECT rtv_id, ncr_no, dispatch_date, qty_sent,
       (CURRENT_DATE - dispatch_date) AS days_pending
FROM rtv_tracking
WHERE return_status = 'Pending'
AND (CURRENT_DATE - dispatch_date) > 30
ORDER BY days_pending DESC;
