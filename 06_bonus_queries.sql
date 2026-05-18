-- ============================================================
-- SCM NCR SQL Project
-- File: 06_bonus_queries.sql
-- Category: Bonus — 38 New Unique Queries
-- Queries: B1 to B38
-- ============================================================


-- B1: Top 5 suppliers with highest NCR quantity
SELECT s.vendor_name, SUM(n.ncr_qty) AS total_ncr_qty
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name
ORDER BY total_ncr_qty DESC
LIMIT 5;

-- B2: Project-wise RTV pending percentage
SELECT p.project_name,
       COUNT(r.rtv_id) AS total_rtv,
       SUM(CASE WHEN r.return_status = 'Pending' THEN 1 ELSE 0 END) AS pending,
       ROUND(SUM(CASE WHEN r.return_status = 'Pending' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(r.rtv_id), 0), 2) AS pending_pct
FROM products p
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
LEFT JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
GROUP BY p.project_name
ORDER BY pending_pct DESC;

-- B3: Products having stock less than total NCR quantity raised
SELECT p.product_name, p.part_number,
       COALESCE(w.available_stock, 0) AS current_stock,
       SUM(n.ncr_qty) AS total_ncr_qty
FROM products p
LEFT JOIN warehouse_stock w ON p.product_id = w.product_id
LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY p.product_name, p.part_number, w.available_stock
HAVING COALESCE(w.available_stock, 0) < SUM(n.ncr_qty)
ORDER BY total_ncr_qty DESC;

-- B4: Suppliers whose products have more than 3 NCRs
SELECT s.vendor_name, p.product_name, COUNT(n.ncr_no) AS ncr_count
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name, p.product_name
HAVING COUNT(n.ncr_no) > 3
ORDER BY ncr_count DESC;

-- B5: Disposal type contributing highest NCR quantity
SELECT n.disposal, SUM(n.ncr_qty) AS total_ncr_qty
FROM ncr_tracking n
WHERE n.disposal IS NOT NULL
GROUP BY n.disposal
ORDER BY total_ncr_qty DESC;

-- B6: Products never involved in RTV process
SELECT p.product_id, p.product_name, p.part_number, s.vendor_name
FROM products p
INNER JOIN suppliers s ON p.supplier_id = s.id
WHERE p.product_id IN (SELECT product_id FROM ncr_tracking)
AND p.product_id NOT IN (
    SELECT DISTINCT n.product_id FROM ncr_tracking n
    INNER JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
    WHERE n.product_id IS NOT NULL
);

-- B7: Suppliers with maximum pending RTV cases
SELECT s.vendor_name,
       COUNT(r.rtv_id) AS total_rtv,
       SUM(CASE WHEN r.return_status = 'Pending' THEN 1 ELSE 0 END) AS pending_count
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
INNER JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
GROUP BY s.vendor_name
ORDER BY pending_count DESC;

-- B8: Average NCR quantity supplier-wise
SELECT s.vendor_name, ROUND(AVG(n.ncr_qty), 2) AS avg_ncr_qty
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name
ORDER BY avg_ncr_qty DESC;

-- B9: Products whose unit price is above project average price
SELECT product_name, project_name, unit_price,
       ROUND(AVG(unit_price) OVER (PARTITION BY project_name), 2) AS project_avg_price
FROM products
WHERE unit_price > (
    SELECT AVG(p2.unit_price) FROM products p2
    WHERE p2.project_name = products.project_name
)
ORDER BY project_name, unit_price DESC;

-- B10: Project having highest completed PO quantity
SELECT p.project_name, SUM(po.qty_sent) AS total_completed_qty
FROM products p
INNER JOIN purchase_orders po ON p.product_id = po.product_id
WHERE po.supplier_status = 'Completed'
GROUP BY p.project_name
ORDER BY total_completed_qty DESC
LIMIT 1;

-- B11: Supplier-wise completed vs pending PO count
SELECT s.vendor_name,
       SUM(CASE WHEN po.supplier_status = 'Completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN po.supplier_status = 'Pending'   THEN 1 ELSE 0 END) AS pending,
       COUNT(po.po_id) AS total_pos
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN purchase_orders po ON p.product_id = po.product_id
GROUP BY s.vendor_name
ORDER BY total_pos DESC;

-- B12: RTV dispatch delay greater than 7 days from NCR date
SELECT r.rtv_id, r.ncr_no, n.date AS ncr_date,
       r.dispatch_date,
       (r.dispatch_date - n.date) AS dispatch_delay_days
FROM rtv_tracking r
INNER JOIN ncr_tracking n ON r.ncr_no = n.ncr_no
WHERE (r.dispatch_date - n.date) > 7
ORDER BY dispatch_delay_days DESC;

-- B13: Products repeated in NCR more than 5 times
SELECT p.product_name, p.part_number, COUNT(n.ncr_no) AS ncr_count
FROM products p
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY p.product_name, p.part_number
HAVING COUNT(n.ncr_no) > 5
ORDER BY ncr_count DESC;

-- B14: Top 3 costly products supplier-wise (Window Function)
SELECT vendor_name, product_name, unit_price, price_rank
FROM (
    SELECT s.vendor_name, p.product_name, p.unit_price,
           DENSE_RANK() OVER (PARTITION BY s.vendor_name ORDER BY p.unit_price DESC) AS price_rank
    FROM suppliers s
    INNER JOIN products p ON s.id = p.supplier_id
) ranked
WHERE price_rank <= 3
ORDER BY vendor_name, price_rank;

-- B15: Monthly RTV dispatch quantity
SELECT TO_CHAR(dispatch_date, 'YYYY-MM') AS month,
       COUNT(rtv_id) AS rtv_count,
       SUM(qty_sent) AS total_dispatched
FROM rtv_tracking
GROUP BY TO_CHAR(dispatch_date, 'YYYY-MM')
ORDER BY month;

-- B16: Warehouse location storing maximum number of products
SELECT location, COUNT(product_id) AS product_count,
       SUM(available_stock) AS total_stock
FROM warehouse_stock
GROUP BY location
ORDER BY product_count DESC
LIMIT 1;

-- B17: Products with zero stock but active NCRs
SELECT p.product_name, p.part_number,
       COALESCE(w.available_stock, 0) AS current_stock,
       COUNT(n.ncr_no) AS active_ncr_count
FROM products p
LEFT JOIN warehouse_stock w ON p.product_id = w.product_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
WHERE COALESCE(w.available_stock, 0) = 0
GROUP BY p.product_name, p.part_number, w.available_stock
ORDER BY active_ncr_count DESC;

-- B18: Supplier contribution percentage to total NCR quantity
SELECT s.vendor_name,
       SUM(n.ncr_qty) AS supplier_ncr_qty,
       ROUND(SUM(n.ncr_qty) * 100.0 /
             (SELECT SUM(ncr_qty) FROM ncr_tracking), 2) AS contribution_pct
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name
ORDER BY contribution_pct DESC;

-- B19: Average dispatch time for completed RTV
SELECT ROUND(AVG(return_date - dispatch_date), 2) AS avg_dispatch_days
FROM rtv_tracking
WHERE return_status = 'Received'
AND return_date IS NOT NULL
AND dispatch_date IS NOT NULL;

-- B20: Products having both SCRAP and REWORK disposal in NCR
SELECT p.product_name, p.part_number
FROM products p
WHERE p.product_id IN (
    SELECT product_id FROM ncr_tracking WHERE disposal = 'SCRAP'
)
AND p.product_id IN (
    SELECT product_id FROM ncr_tracking WHERE disposal = 'REWORK'
);

-- B21: Projects with no pending RTV
SELECT DISTINCT p.project_name
FROM products p
WHERE p.project_name NOT IN (
    SELECT DISTINCT p2.project_name
    FROM products p2
    INNER JOIN ncr_tracking n ON p2.product_id = n.product_id
    INNER JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
    WHERE r.return_status = 'Pending'
);

-- B22: Supplier-wise total stock value
SELECT s.vendor_name,
       SUM(w.available_stock * p.unit_price) AS total_stock_value
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN warehouse_stock w ON p.product_id = w.product_id
GROUP BY s.vendor_name
ORDER BY total_stock_value DESC;

-- B23: Latest NCR raised for each supplier
SELECT s.vendor_name, MAX(n.date) AS latest_ncr_date,
       COUNT(n.ncr_no) AS total_ncrs
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name
ORDER BY latest_ncr_date DESC;

-- B24: RTV records without matching PO completion
SELECT r.rtv_id, r.ncr_no, r.dispatch_date, r.return_status
FROM rtv_tracking r
WHERE r.ncr_no NOT IN (
    SELECT po.ncr_no FROM purchase_orders po
    WHERE po.supplier_status = 'Completed'
    AND po.ncr_no IS NOT NULL
);

-- B25: Products with highest stock-to-NCR ratio
SELECT p.product_name, p.part_number,
       COALESCE(w.available_stock, 0) AS stock,
       COUNT(n.ncr_no) AS ncr_count,
       ROUND(COALESCE(w.available_stock, 0) * 1.0 /
             NULLIF(COUNT(n.ncr_no), 0), 2) AS stock_to_ncr_ratio
FROM products p
LEFT JOIN warehouse_stock w ON p.product_id = w.product_id
LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY p.product_name, p.part_number, w.available_stock
ORDER BY stock_to_ncr_ratio DESC NULLS LAST;

-- B26: Disposal type-wise average NCR quantity
SELECT disposal, ROUND(AVG(ncr_qty), 2) AS avg_ncr_qty,
       COUNT(*) AS ncr_count
FROM ncr_tracking
WHERE disposal IS NOT NULL
GROUP BY disposal
ORDER BY avg_ncr_qty DESC;

-- B27: Project-wise supplier count
SELECT p.project_name, COUNT(DISTINCT p.supplier_id) AS supplier_count
FROM products p
GROUP BY p.project_name
ORDER BY supplier_count DESC;

-- B28: Suppliers whose all RTVs are completed (no pending)
SELECT s.vendor_name, COUNT(r.rtv_id) AS total_rtv
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
INNER JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
GROUP BY s.vendor_name
HAVING SUM(CASE WHEN r.return_status = 'Pending' THEN 1 ELSE 0 END) = 0
ORDER BY total_rtv DESC;

-- B29: NCR quantity variance between projects
SELECT project,
       MAX(ncr_qty) AS max_qty,
       MIN(ncr_qty) AS min_qty,
       ROUND(AVG(ncr_qty), 2) AS avg_qty,
       (MAX(ncr_qty) - MIN(ncr_qty)) AS qty_variance
FROM ncr_tracking
GROUP BY project
ORDER BY qty_variance DESC;

-- B30: Products with increasing NCR trend (more NCRs each month)
WITH monthly_product_ncr AS (
    SELECT product_id,
           TO_CHAR(date, 'YYYY-MM') AS month,
           COUNT(*) AS ncr_count
    FROM ncr_tracking
    GROUP BY product_id, TO_CHAR(date, 'YYYY-MM')
),
with_lag AS (
    SELECT product_id, month, ncr_count,
           LAG(ncr_count) OVER (PARTITION BY product_id ORDER BY month) AS prev_count
    FROM monthly_product_ncr
)
SELECT DISTINCT p.product_name, w.product_id
FROM with_lag w
INNER JOIN products p ON w.product_id = p.product_id
WHERE w.ncr_count > COALESCE(w.prev_count, 0)
ORDER BY p.product_name;

-- B31: Supplier with highest average unit price
SELECT s.vendor_name, ROUND(AVG(p.unit_price), 2) AS avg_unit_price
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
GROUP BY s.vendor_name
ORDER BY avg_unit_price DESC
LIMIT 1;

-- B32: Supplier-wise RTV completion percentage
SELECT s.vendor_name,
       COUNT(r.rtv_id) AS total_rtv,
       SUM(CASE WHEN r.return_status = 'Received' THEN 1 ELSE 0 END) AS completed,
       ROUND(SUM(CASE WHEN r.return_status = 'Received' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(r.rtv_id), 0), 2) AS completion_pct
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
INNER JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
GROUP BY s.vendor_name
ORDER BY completion_pct DESC;

-- B33: Project contributing highest warehouse stock value
SELECT p.project_name,
       SUM(w.available_stock * p.unit_price) AS total_stock_value
FROM products p
INNER JOIN warehouse_stock w ON p.product_id = w.product_id
GROUP BY p.project_name
ORDER BY total_stock_value DESC
LIMIT 1;

-- B34: Products with duplicate warehouse entries
SELECT product_id, COUNT(*) AS entry_count
FROM warehouse_stock
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY entry_count DESC;

-- B35: Top 10 NCR products based on quantity rejected
SELECT p.product_name, p.part_number,
       SUM(n.ncr_qty) AS total_rejected
FROM products p
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY p.product_name, p.part_number
ORDER BY total_rejected DESC
LIMIT 10;

-- B36: RTV cases without dispatch date
SELECT rtv_id, ncr_no, qty_sent, return_status
FROM rtv_tracking
WHERE dispatch_date IS NULL;

-- B37: Completed RTVs with delayed return (more than 10 days)
SELECT r.rtv_id, r.ncr_no, r.dispatch_date, r.return_date,
       (r.return_date - r.dispatch_date) AS days_taken,
       p.product_name, s.vendor_name
FROM rtv_tracking r
LEFT JOIN ncr_tracking n ON r.ncr_no = n.ncr_no
LEFT JOIN products p ON n.product_id = p.product_id
LEFT JOIN suppliers s ON p.supplier_id = s.id
WHERE r.return_status = 'Received'
AND (r.return_date - r.dispatch_date) > 10
ORDER BY days_taken DESC;

-- B38: Monthly PO completion rate
SELECT TO_CHAR(po_date, 'YYYY-MM') AS month,
       COUNT(*) AS total_pos,
       SUM(CASE WHEN supplier_status = 'Completed' THEN 1 ELSE 0 END) AS completed,
       ROUND(SUM(CASE WHEN supplier_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 /
             NULLIF(COUNT(*), 0), 2) AS completion_rate_pct
FROM purchase_orders
GROUP BY TO_CHAR(po_date, 'YYYY-MM')
ORDER BY month;
