-- ============================================================
-- SCM NCR SQL Project
-- File: 03_joins.sql
-- Category: INNER JOIN, LEFT JOIN, Multi-table JOINs
-- Queries: 41 to 60
-- ============================================================


-- Q41: Get product name with supplier name
SELECT p.product_id, p.product_name, p.part_number, s.vendor_name
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.id;

-- Q42: Get NCR details with product name
SELECT n.ncr_no, n.date, p.product_name, p.part_number, n.ncr_qty, n.disposal
FROM ncr_tracking n
INNER JOIN products p ON n.product_id = p.product_id;

-- Q43: Get NCR details with product and supplier name
SELECT n.ncr_no, n.date, p.product_name, s.vendor_name, n.ncr_qty, n.disposal
FROM ncr_tracking n
INNER JOIN products p ON n.product_id = p.product_id
INNER JOIN suppliers s ON p.supplier_id = s.id;

-- Q44: Get purchase order with product details
SELECT po.po_id, po.purchase_order, po.po_date, p.product_name, po.qty_sent, po.supplier_status
FROM purchase_orders po
INNER JOIN products p ON po.product_id = p.product_id;

-- Q45: Get RTV records with NCR details
SELECT r.rtv_id, r.ncr_no, r.dispatch_date, r.qty_sent, r.return_status, r.return_date
FROM rtv_tracking r
LEFT JOIN ncr_tracking n ON r.ncr_no = n.ncr_no;

-- Q46: Get warehouse stock with product and supplier details
SELECT w.stock_id, p.product_name, p.part_number, s.vendor_name, w.location, w.availble_stock
FROM warehouse_stock w
INNER JOIN products p ON w.product_id = p.product_id
INNER JOIN suppliers s ON w.supplier_id = s.id;

-- Q47: Get all suppliers and their products (including suppliers with no products)
SELECT s.vendor_name, p.product_name, p.part_number
FROM suppliers s
LEFT JOIN products p ON s.id = p.supplier_id
ORDER BY s.vendor_name;

-- Q48: Get NCR records with product name and project for CMR1 project
SELECT n.ncr_no, n.date, p.product_name, n.ncr_qty, n.disposal
FROM ncr_tracking n
INNER JOIN products p ON n.product_id = p.product_id
WHERE p.project_name = 'CMR1';

-- Q49: Get all RTV Pending records with supplier info
SELECT r.rtv_id, r.ncr_no, r.dispatch_date, r.qty_sent, s.vendor_name, s.city
FROM rtv_tracking r
LEFT JOIN ncr_tracking n ON r.ncr_no = n.ncr_no
LEFT JOIN products p ON n.product_id = p.product_id
LEFT JOIN suppliers s ON p.supplier_id = s.id
WHERE r.return_status = 'Pending';

-- Q50: Full NCR to Supplier traceability report
SELECT n.ncr_no, n.date, p.product_name, p.part_number,
       s.vendor_name, s.city, n.ncr_qty, n.disposal, n.responsibility
FROM ncr_tracking n
INNER JOIN products p ON n.product_id = p.product_id
INNER JOIN suppliers s ON p.supplier_id = s.id
ORDER BY n.date;

-- Q51: Purchase orders with NCR and product details
SELECT po.po_id, po.purchase_order, po.po_date,
       p.product_name, n.ncr_no, po.qty_sent, po.supplier_status
FROM purchase_orders po
INNER JOIN products p ON po.product_id = p.product_id
LEFT JOIN ncr_tracking n ON po.ncr_no = n.ncr_no
ORDER BY po.po_date;

-- Q52: Warehouse stock with total value (stock × unit_price)
SELECT w.stock_id, p.product_name, w.location,
       w.availble_stock, p.unit_price,
       (w.availble_stock * p.unit_price) AS total_value
FROM warehouse_stock w
INNER JOIN products p ON w.product_id = p.product_id
ORDER BY total_value DESC;

-- Q53: NCR records with RTV dispatch info
SELECT n.ncr_no, n.date, p.product_name, n.ncr_qty,
       r.rtv_id, r.dispatch_date, r.qty_sent, r.return_status
FROM ncr_tracking n
LEFT JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
INNER JOIN products p ON n.product_id = p.product_id;

-- Q54: Supplier-wise total NCR quantity
SELECT s.vendor_name, s.city, SUM(n.ncr_qty) AS total_ncr_qty
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name, s.city
ORDER BY total_ncr_qty DESC;

-- Q55: Products with no NCR records (good products)
SELECT p.product_id, p.product_name, p.part_number, s.vendor_name
FROM products p
LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
INNER JOIN suppliers s ON p.supplier_id = s.id
WHERE n.product_id IS NULL;

-- Q56: Monthly NCR trend with product details
SELECT TO_CHAR(n.date, 'YYYY-MM') AS month,
       COUNT(n.ncr_no) AS ncr_count,
       SUM(n.ncr_qty) AS total_qty_rejected
FROM ncr_tracking n
GROUP BY TO_CHAR(n.date, 'YYYY-MM')
ORDER BY month;

-- Q57: Supplier performance: NCR count per supplier
SELECT s.vendor_name, COUNT(n.ncr_no) AS ncr_count,
       SUM(n.ncr_qty) AS total_qty_rejected
FROM suppliers s
LEFT JOIN products p ON s.id = p.supplier_id
LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name
ORDER BY ncr_count DESC;

-- Q58: Products in warehouse stock vs NCR count
SELECT p.product_name, w.availble_stock,
       COUNT(n.ncr_no) AS ncr_count
FROM products p
LEFT JOIN warehouse_stock w ON p.product_id = w.product_id
LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY p.product_name, w.availble_stock
ORDER BY ncr_count DESC;

-- Q59: RTV records received back with days taken to return
SELECT r.rtv_id, r.ncr_no, r.dispatch_date, r.return_date,
       (r.return_date - r.dispatch_date) AS days_to_return,
       r.return_status
FROM rtv_tracking r
WHERE r.return_status = 'Received'
ORDER BY days_to_return DESC;

-- Q60: Complete SCM process report: NCR → PO → RTV
SELECT n.ncr_no, n.date AS ncr_date, p.product_name,
       s.vendor_name, n.ncr_qty, n.disposal,
       po.purchase_order, po.po_date,
       r.rtv_id, r.dispatch_date, r.return_status
FROM ncr_tracking n
INNER JOIN products p ON n.product_id = p.product_id
INNER JOIN suppliers s ON p.supplier_id = s.id
LEFT JOIN purchase_orders po ON n.ncr_no = po.ncr_no
LEFT JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
ORDER BY n.date;
