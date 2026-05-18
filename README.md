# 📦 SCM NCR SQL Project

> A real-world **Supply Chain Management (SCM)** database project focused on **Non-Conformance Report (NCR)** tracking, Purchase Orders, RTV (Return to Vendor), and Warehouse Stock Management — built using **PostgreSQL 18**.

---

## 🧑‍💼 Project Overview

This project simulates a real manufacturing and supply chain workflow where:

- Defective materials are identified through **NCR (Non-Conformance Reports)**
- Suppliers are monitored through quality and replacement activities
- RTV (Return to Vendor) process is tracked
- Warehouse stock is monitored after replacement activities
- Purchase orders are linked to defective material handling

The project is inspired by real SCM operational activities such as:
- NCR tracking
- Supplier follow-up
- Purchase order monitoring
- Warehouse stock validation
- RTV processing
- SAP inventory movement handling

---

## 🔧 SAP Process References

This project reflects real operational activities using SAP transactions such as:

| Transaction | Description |
|---|---|
| `MB51` | Material document list |
| `LT01` | Create Transfer Order |
| `LT24` | Transfer Orders for Material |
| `LT31` | Print Transfer Order |
| `LS24` | Quants in Storage Bin |
| `QM03` | Display Quality Notification |
| `QM11` | Create Quality Notification |
| `ME23N` | Display Purchase Order |
| `ME2N` | Purchase Orders by PO Number |
| `ME5A` | Purchase Requisition List |
| `VL03N` | Display Outbound Delivery |
| `ZPUDP20` | Custom SCM Report |
| `ZPFSM` | Custom Field Service Report |

### 📦 Material Movement Types

| Movement Type | Description |
|---|---|
| **531** | NCR stock movement — defective material received |
| **541** | RTV movement — material returned to vendor |

---

## 🔄 Business Process Flow

```
1. Material received from supplier
         ↓
2. Quality team identifies defect → NCR raised
         ↓
3. NCR reviewed → Disposal decided (RTV / Scrap / Rework)
         ↓
4. Purchase Order created for replacement material
         ↓
5. Defective material dispatched to supplier (RTV)
         ↓
6. Supplier sends replacement → Warehouse stock updated
```

---

## 🗂️ Project Structure

```
scm_ncr_sql_project/
│
├── schema/
│   └── create_tables.sql           # All CREATE TABLE statements with FK constraints
│
├── queries/
│   ├── 01_basic_queries.sql        # Q1–Q20   → SELECT, WHERE, ORDER BY, LIMIT, LIKE
│   ├── 02_aggregations.sql         # Q21–Q40  → GROUP BY, COUNT, SUM, AVG, HAVING
│   ├── 03_joins.sql                # Q41–Q60  → INNER JOIN, LEFT JOIN, Multi-table JOINs
│   ├── 04_subqueries.sql           # Q61–Q80  → Subqueries, EXISTS, IN, NOT IN
│   ├── 05_advanced_analytics.sql   # Q81–Q100 → Window Functions, CTEs, CASE WHEN
│   └── 06_bonus_queries.sql        # B1–B38   → Real-world SCM business queries
│
├── erd/
│   └── scm_ncr_erd.png             # Entity Relationship Diagram
│
├── docs/
│   └── project_summary.md          # Business context and insights
│
└── README.md
```

---

## 🗄️ Database Tables

| Table | Columns | Description |
|---|---|---|
| `suppliers` | id, vendor_name, city, contact_person, phone_number | Vendor master data |
| `products` | product_id, part_number, product_name, project_name, unit_price, supplier_id | Product catalog linked to suppliers |
| `ncr_tracking` | ncr_no, date, product_id, supplier_id, part_number, ncr_qty, project, car_station, received_date, responsibility, disposal | NCR records for defective materials |
| `purchase_orders` | po_id, product_id, purchase_order, ncr_no, qty_sent, po_date, disposal, supplier_status | Purchase orders raised per NCR |
| `rtv_tracking` | rtv_id, ncr_no, dispatch_date, qty_sent, return_status, return_date | Return to Vendor dispatch records |
| `warehouse_stock` | stock_id, product_id, part_number, product_name, location, available_stock, supplier_id | Current stock levels in warehouse |

---

## 🔗 Key Relationships

| Relationship | Type | Description |
|---|---|---|
| `suppliers` → `products` | One to Many | One supplier supplies many products |
| `suppliers` → `ncr_tracking` | One to Many | One supplier can have many NCRs |
| `products` → `ncr_tracking` | One to Many | One product can have multiple NCR records |
| `products` → `purchase_orders` | One to Many | One product can appear in many POs |
| `products` → `warehouse_stock` | One to One | One product has one stock record |
| `ncr_tracking` → `rtv_tracking` | One to One | One NCR generates one RTV dispatch |
| `suppliers` → `warehouse_stock` | One to Many | One supplier stocks many warehouse items |

---

## 💡 SQL Concepts Covered

| Category | Concepts |
|---|---|
| Basic | SELECT, WHERE, ORDER BY, LIMIT, LIKE, BETWEEN, DISTINCT |
| Aggregations | COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING |
| Joins | INNER JOIN, LEFT JOIN, 3-table & 4-table JOINs |
| Subqueries | IN, NOT IN, EXISTS, NOT EXISTS, Correlated Subqueries |
| Advanced | RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD |
| Analytics | CTEs, CASE WHEN, Running Totals, PERCENTILE_CONT |
| Date | TO_CHAR, BETWEEN, Date Arithmetic, Monthly Trends |
| Business | KPI Dashboard, Scorecard, Gap Analysis, Aging Reports |

---

## 📊 Query Files Summary

| File | Queries | Key Topics |
|---|---|---|
| `01_basic_queries.sql` | 20 | Basic SELECT, filters, sorting |
| `02_aggregations.sql` | 20 | COUNT, SUM, GROUP BY, HAVING |
| `03_joins.sql` | 20 | Multi-table JOINs, traceability |
| `04_subqueries.sql` | 20 | Nested queries, EXISTS, NOT IN |
| `05_advanced_analytics.sql` | 20 | Window functions, CTEs, CASE WHEN |
| `06_bonus_queries.sql` | 38 | Real-world SCM business analytics |
| **Total** | **138** | **Basic to Advanced** |

---

## 📈 Business Insights from Queries

- Supplier-wise NCR count, defect rate and performance scorecard
- Top defective products by quantity rejected
- RTV pending vs received analysis and aging report
- Monthly NCR trend and running total analysis
- Warehouse stock value vs purchase order comparison
- Supplier RTV completion percentage
- Project-wise NCR variance and stock value
- Executive KPI dashboard — all metrics in one query

---

## 🛠️ Tech Stack

- **Database:** PostgreSQL 18
- **Tool:** pgAdmin 4
- **Language:** SQL
- **Version Control:** Git & GitHub

---

## 📌 How to Run

1. Install **PostgreSQL 18** and **pgAdmin 4**
2. Create database:
```sql
CREATE DATABASE scm_ncr_sql_project;
```
3. Run `schema/create_tables.sql` to create all 6 tables
4. Import your data using pgAdmin Import/Export or INSERT statements
5. Open any file in `queries/` folder and run in pgAdmin Query Tool

---

## 👤 Author

**R. Mutthupandiayan**
- 📧 Email: *(add your email)*
- 💼 LinkedIn: *(add your LinkedIn URL)*
- 🐙 GitHub: *(add your GitHub URL)*


