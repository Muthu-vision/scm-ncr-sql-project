-- ============================================================
-- SCM NCR SQL Project
-- File: 05_advanced_analytics.sql
-- Category: Window Functions, CTEs, CASE WHEN, Date Analytics
-- Queries: 81 to 100
-- ============================================================


-- Q81: Rank suppliers by total NCR quantity (Window Function)
SELECT s.vendor_name,
       SUM(n.ncr_qty) AS total_ncr_qty,
       RANK() OVER (ORDER BY SUM(n.ncr_qty) DESC) AS ncr_rank
FROM suppliers s
INNER JOIN products p ON s.id = p.supplier_id
INNER JOIN ncr_tracking n ON p.product_id = n.product_id
GROUP BY s.vendor_name;

-- Q82: Row number for NCR records ordered by date
SELECT ROW_NUMBER() OVER (ORDER BY date) AS row_num,
       ncr_no, date, product_id, ncr_qty
FROM ncr_tracking;

-- Q83: Running total of NCR qty over time (Window Function)
SELECT ncr_no, date, ncr_qty,
       SUM(ncr_qty) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
       AS running_total
FROM ncr_tracking
ORDER BY date;

-- Q84: Rank products by unit price within each project (DENSE_RANK)
SELECT product_name, project_name, unit_price,
       DENSE_RANK() OVER (PARTITION BY project_name ORDER BY unit_price DESC) AS price_rank
FROM products;

-- Q85: NCR classification using CASE WHEN
SELECT ncr_no, ncr_qty,
       CASE
           WHEN ncr_qty <= 2  THEN 'Low'
           WHEN ncr_qty <= 5  THEN 'Medium'
           WHEN ncr_qty <= 10 THEN 'High'
           ELSE 'Critical'
       END AS severity_level
FROM ncr_tracking
ORDER BY ncr_qty DESC;

-- Q86: RTV turnaround classification using CASE WHEN
SELECT rtv_id, ncr_no, dispatch_date, return_date,
       (return_date - dispatch_date) AS days_taken,
       CASE
           WHEN (return_date - dispatch_date) <= 5  THEN 'Fast'
           WHEN (return_date - dispatch_date) <= 10 THEN 'Normal'
           WHEN (return_date - dispatch_date) > 10  THEN 'Slow'
           ELSE 'Pending'
       END AS turnaround
FROM rtv_tracking
ORDER BY days_taken DESC NULLS LAST;

-- Q87: Supplier performance scorecard using CTE
WITH supplier_ncr AS (
    SELECT s.id, s.vendor_name,
           COUNT(n.ncr_no) AS ncr_count,
           SUM(n.ncr_qty) AS total_qty_rejected
    FROM suppliers s
    LEFT JOIN products p ON s.id = p.supplier_id
    LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
    GROUP BY s.id, s.vendor_name
)
SELECT vendor_name, ncr_count, total_qty_rejected,
       CASE
           WHEN ncr_count = 0 THEN 'Excellent'
           WHEN ncr_count <= 3 THEN 'Good'
           WHEN ncr_count <= 7 THEN 'Average'
           ELSE 'Poor'
       END AS performance_rating
FROM supplier_ncr
ORDER BY ncr_count DESC;

-- Q88: Monthly NCR trend with running total using CTE
WITH monthly_ncr AS (
    SELECT TO_CHAR(date, 'YYYY-MM') AS month,
           COUNT(*) AS ncr_count,
           SUM(ncr_qty) AS total_qty
    FROM ncr_tracking
    GROUP BY TO_CHAR(date, 'YYYY-MM')
)
SELECT month, ncr_count, total_qty,
       SUM(ncr_count) OVER (ORDER BY month) AS running_ncr_count
FROM monthly_ncr
ORDER BY month;

-- Q89: Top product by NCR count per project using CTE + RANK
WITH product_ncr AS (
    SELECT p.project_name, p.product_name,
           COUNT(n.ncr_no) AS ncr_count,
           RANK() OVER (PARTITION BY p.project_name ORDER BY COUNT(n.ncr_no) DESC) AS rnk
    FROM products p
    LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
    GROUP BY p.project_name, p.product_name
)
SELECT project_name, product_name, ncr_count
FROM product_ncr
WHERE rnk = 1;

-- Q90: Warehouse stock value analysis using CTE
WITH stock_value AS (
    SELECT w.stock_id, p.product_name, s.vendor_name,
           w.availble_stock, p.unit_price,
           (w.availble_stock * p.unit_price) AS total_value
    FROM warehouse_stock w
    INNER JOIN products p ON w.product_id = p.product_id
    INNER JOIN suppliers s ON w.supplier_id = s.id
)
SELECT product_name, vendor_name, availble_stock, unit_price, total_value,
       ROUND(total_value * 100.0 / SUM(total_value) OVER (), 2) AS pct_of_total
FROM stock_value
ORDER BY total_value DESC;

-- Q91: Lead/Lag analysis on NCR dates per product
SELECT ncr_no, product_id, date AS ncr_date,
       LAG(date) OVER (PARTITION BY product_id ORDER BY date) AS prev_ncr_date,
       (date - LAG(date) OVER (PARTITION BY product_id ORDER BY date)) AS days_between_ncr
FROM ncr_tracking
ORDER BY product_id, date;

-- Q92: Cumulative RTV qty dispatched per month
SELECT TO_CHAR(dispatch_date, 'YYYY-MM') AS month,
       SUM(qty_sent) AS monthly_dispatched,
       SUM(SUM(qty_sent)) OVER (ORDER BY TO_CHAR(dispatch_date, 'YYYY-MM')) AS cumulative_dispatched
FROM rtv_tracking
GROUP BY TO_CHAR(dispatch_date, 'YYYY-MM')
ORDER BY month;

-- Q93: NCR records in Q1 2025 (January to March)
SELECT ncr_no, date, product_id, ncr_qty, disposal
FROM ncr_tracking
WHERE date BETWEEN '2025-01-01' AND '2025-03-31'
ORDER BY date;

-- Q94: Identify duplicate NCR numbers if any
SELECT ncr_no, COUNT(*) AS occurrence
FROM ncr_tracking
GROUP BY ncr_no
HAVING COUNT(*) > 1;

-- Q95: Products with NCR qty above 90th percentile
SELECT ncr_no, product_id, ncr_qty
FROM ncr_tracking
WHERE ncr_qty >= (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY ncr_qty)
    FROM ncr_tracking
)
ORDER BY ncr_qty DESC;

-- Q96: Full supplier NCR dashboard (CTE multi-step)
WITH base AS (
    SELECT s.vendor_name, s.city,
           COUNT(DISTINCT n.ncr_no) AS ncr_count,
           SUM(n.ncr_qty) AS total_rejected,
           COUNT(DISTINCT r.rtv_id) AS rtv_raised,
           SUM(CASE WHEN r.return_status = 'Pending' THEN 1 ELSE 0 END) AS rtv_pending
    FROM suppliers s
    LEFT JOIN products p ON s.id = p.supplier_id
    LEFT JOIN ncr_tracking n ON p.product_id = n.product_id
    LEFT JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
    GROUP BY s.vendor_name, s.city
)
SELECT vendor_name, city, ncr_count, total_rejected,
       rtv_raised, rtv_pending,
       CASE WHEN ncr_count = 0 THEN 'No Issues'
            WHEN ncr_count <= 3 THEN 'Minor'
            WHEN ncr_count <= 6 THEN 'Moderate'
            ELSE 'Critical' END AS risk_level
FROM base
ORDER BY ncr_count DESC;

-- Q97: Compare NCR qty vs RTV qty per NCR (gap analysis)
SELECT n.ncr_no, n.ncr_qty AS ncr_qty_raised,
       COALESCE(r.qty_sent, 0) AS qty_dispatched_rtv,
       (n.ncr_qty - COALESCE(r.qty_sent, 0)) AS qty_gap
FROM ncr_tracking n
LEFT JOIN rtv_tracking r ON n.ncr_no = r.ncr_no
ORDER BY qty_gap DESC;

-- Q98: Percentage of NCRs resolved (Received) vs pending
SELECT
    COUNT(*) AS total_rtv,
    SUM(CASE WHEN return_status = 'Received' THEN 1 ELSE 0 END) AS received,
    SUM(CASE WHEN return_status = 'Pending'  THEN 1 ELSE 0 END) AS pending,
    ROUND(SUM(CASE WHEN return_status = 'Received' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
        AS resolution_pct
FROM rtv_tracking;

-- Q99: NCR aging report — how old are pending RTVs
SELECT r.rtv_id, r.ncr_no, r.dispatch_date,
       (CURRENT_DATE - r.dispatch_date) AS age_in_days,
       n.ncr_qty, p.product_name, s.vendor_name,
       CASE
           WHEN (CURRENT_DATE - r.dispatch_date) <= 15 THEN 'Fresh'
           WHEN (CURRENT_DATE - r.dispatch_date) <= 30 THEN 'Aging'
           WHEN (CURRENT_DATE - r.dispatch_date) <= 60 THEN 'Overdue'
           ELSE 'Critical Overdue'
       END AS aging_status
FROM rtv_tracking r
LEFT JOIN ncr_tracking n ON r.ncr_no = n.ncr_no
LEFT JOIN products p ON n.product_id = p.product_id
LEFT JOIN suppliers s ON p.supplier_id = s.id
WHERE r.return_status = 'Pending'
ORDER BY age_in_days DESC;

-- Q100: Executive Summary Dashboard — Full SCM KPIs
SELECT
    (SELECT COUNT(*) FROM suppliers)                          AS total_suppliers,
    (SELECT COUNT(*) FROM products)                           AS total_products,
    (SELECT COUNT(*) FROM ncr_tracking)                       AS total_ncrs,
    (SELECT SUM(ncr_qty) FROM ncr_tracking)                   AS total_qty_rejected,
    (SELECT COUNT(*) FROM purchase_orders)                    AS total_pos,
    (SELECT COUNT(*) FROM rtv_tracking)                       AS total_rtvs,
    (SELECT COUNT(*) FROM rtv_tracking WHERE return_status = 'Pending')  AS rtv_pending,
    (SELECT COUNT(*) FROM rtv_tracking WHERE return_status = 'Received') AS rtv_received,
    (SELECT SUM(availble_stock) FROM warehouse_stock)         AS total_warehouse_stock,
    (SELECT ROUND(AVG(unit_price),2) FROM products)           AS avg_product_price;
