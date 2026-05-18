-- ============================================================
-- SCM NCR SQL Project — Schema
-- Author: [Your Name]
-- Database: PostgreSQL 18
-- Description: Supply Chain Management NCR Tracking System
-- ============================================================

-- 1. SUPPLIERS TABLE
CREATE TABLE suppliers (
    id               SERIAL PRIMARY KEY,
    vendor_name      VARCHAR(150) NOT NULL,
    city             VARCHAR(50),
    contact_person   VARCHAR(100),
    phone_number     VARCHAR(20)
);

-- 2. PRODUCTS TABLE
CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    part_number   VARCHAR(50),
    product_name  VARCHAR(100),
    project_name  VARCHAR(10),
    unit_price    DECIMAL(10,2),
    supplier_id   INT,
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 3. NCR TRACKING TABLE
CREATE TABLE ncr_tracking (
    ncr_no          VARCHAR(10) PRIMARY KEY,
    date            DATE,
    product_id      INT,
    supplier_id     INT,
    part_number     VARCHAR(50),
    ncr_qty         INT,
    project         VARCHAR(10),
    car_station     VARCHAR(10),
    received_date   DATE,
    responsibility  VARCHAR(50),
    disposal        VARCHAR(50),
    CONSTRAINT fk_ncr_product  FOREIGN KEY (product_id)  REFERENCES products(product_id),
    CONSTRAINT fk_ncr_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- 4. PURCHASE ORDERS TABLE
CREATE TABLE purchase_orders (
    po_id            INT PRIMARY KEY,
    product_id       INT,
    purchase_order   VARCHAR(9),
    ncr_no           VARCHAR(8),
    qty_sent         INT,
    po_date          DATE,
    disposal         VARCHAR(10),
    supplier_status  VARCHAR(30),
    CONSTRAINT fk_po_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 5. RTV TRACKING TABLE
CREATE TABLE rtv_tracking (
    rtv_id         INT PRIMARY KEY,
    ncr_no         VARCHAR(50),
    dispatch_date  DATE,
    qty_sent       INT,
    return_status  VARCHAR(50),
    return_date    DATE
);

-- 6. WAREHOUSE STOCK TABLE
CREATE TABLE warehouse_stock (
    stock_id       INT PRIMARY KEY,
    product_id     INT,
    part_number    VARCHAR(50),
    product_name   VARCHAR(100),
    location       VARCHAR(10),
    available_stock INT,
    supplier_id    INT,
    CONSTRAINT fk_ws_product  FOREIGN KEY (product_id)  REFERENCES products(product_id),
    CONSTRAINT fk_ws_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);
