# 📋 SCM NCR SQL Project — Project Summary

## 🏭 Business Context

This project represents a **real-world Supply Chain Management (SCM)** system used in manufacturing companies to track and manage **Non-Conformance Reports (NCRs)** — i.e., defective materials received from suppliers.

---

## 🔄 Business Process Flow

```
1. Material received from supplier
        ↓
2. Quality team identifies defect → NCR raised
        ↓
3. NCR reviewed → Disposal decided (RTV / Scrap / Rework)
        ↓
4. Purchase Order created for replacement
        ↓
5. Defective material dispatched to supplier (RTV)
        ↓
6. Supplier sends replacement → Warehouse stock updated
```

---

## 📊 Key Business Metrics Tracked

| Metric | Description |
|---|---|
| NCR Count | Total non-conformances raised |
| Qty Rejected | Total defective quantity |
| Supplier Performance | NCR count per supplier |
| RTV Resolution Rate | % of RTVs received back |
| RTV Aging | Pending RTVs older than 30 days |
| Warehouse Stock Value | Stock × Unit Price |
| Monthly NCR Trend | Month-wise defect pattern |

---

## 💡 Key Insights from Data

1. **Supplier Risk Analysis** — Identify which suppliers cause most NCRs
2. **Product Defect Patterns** — Which products fail quality checks most
3. **RTV Turnaround Time** — How quickly suppliers return material
4. **Warehouse Stock Health** — Low stock alerts and stock value
5. **Monthly Trend Analysis** — Seasonal patterns in defects

---

## 🧠 SQL Skills Demonstrated

### Basic (Q1–Q20)
- SELECT, WHERE, ORDER BY, LIMIT
- BETWEEN, LIKE, DISTINCT

### Aggregations (Q21–Q40)
- COUNT, SUM, AVG, MAX, MIN
- GROUP BY, HAVING
- TO_CHAR for date formatting

### Joins (Q41–Q60)
- INNER JOIN, LEFT JOIN
- 3-table and 4-table joins
- Full traceability reports

### Subqueries (Q61–Q80)
- IN, NOT IN, EXISTS, NOT EXISTS
- Correlated subqueries
- Scalar subqueries

### Advanced Analytics (Q81–Q100)
- Window Functions: RANK, DENSE_RANK, ROW_NUMBER
- LAG, LEAD for time-series analysis
- CTEs (Common Table Expressions)
- CASE WHEN for classification
- PERCENTILE_CONT for statistical analysis
- Running totals and cumulative sums
- KPI Dashboard query

---

## 📁 Files in This Project

| File | Purpose |
|---|---|
| `schema/create_tables.sql` | Table definitions with constraints |
| `data/insert_data.sql` | Sample data for all 6 tables |
| `queries/01_basic_queries.sql` | Q1–Q20: Basic SQL |
| `queries/02_aggregations.sql` | Q21–Q40: Aggregations |
| `queries/03_joins.sql` | Q41–Q60: JOINs |
| `queries/04_subqueries.sql` | Q61–Q80: Subqueries |
| `queries/05_advanced_analytics.sql` | Q81–Q100: Advanced SQL |
| `erd/scm_ncr_erd.png` | Entity Relationship Diagram |

---

## 🎯 Target Roles

This project is built to demonstrate skills for:
- **Data Analyst** — Aggregations, trends, KPI dashboards
- **SQL Developer** — Complex joins, CTEs, window functions
- **Business Analyst** — Process flow, business rules, insights

---

*Built with PostgreSQL 18 | pgAdmin 4 | Git & GitHub*
