# 📖 Data Catalog — Gold Layer

## Overview

The **Gold Layer** is the business-ready layer of the data warehouse, structured as a **star schema** consisting of **dimension** and **fact** views. It is built on top of the cleaned Silver layer and is intended for direct consumption by BI tools (Power BI, SQL reporting) and business users.

---

## 1. `gold.dim_customers`

**Purpose:** Provides customer master data, enriched with demographic and geographic attributes, integrated from CRM (primary source) and ERP (supplementary source).

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | `INT` | Surrogate key uniquely identifying each customer record in the dimension. Used to join with `fact_sales`. |
| `customer_id` | `INT` | Unique numeric identifier for the customer, sourced from CRM (`cst_id`). |
| `customer_number` | `NVARCHAR` | Alphanumeric business identifier used to track the customer across systems (`cst_key`). |
| `first_name` | `NVARCHAR` | Customer's first name, as recorded in CRM. |
| `last_name` | `NVARCHAR` | Customer's last name (family name), as recorded in CRM. |
| `country` | `NVARCHAR` | Customer's country of residence (e.g., `Germany`, `United States`), sourced from ERP location data. `Unknown` if not available. |
| `marital_status` | `NVARCHAR` | Customer's marital status — `Single`, `Married`, or `n/a`. |
| `gender` | `NVARCHAR` | Customer's gender — `Male`, `Female`, or `n/a`. CRM is the trusted source; ERP gender is used only when CRM has no valid value. |
| `birth_date` | `DATE` | Customer's date of birth, sourced from ERP. `NULL` if not available or invalid (future date). |
| `create_date` | `DATE` | Date the customer record was first created in the source CRM system. |

---

## 2. `gold.dim_products`

**Purpose:** Provides product master data, including category classification, cost, and product line — restricted to currently active products.

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | `INT` | Surrogate key uniquely identifying each product record in the dimension. Used to join with `fact_sales`. |
| `product_id` | `INT` | Unique numeric identifier for the product, sourced from CRM. |
| `product_number` | `NVARCHAR` | Alphanumeric business identifier/code for the product (`prd_key`), used to match against sales transactions. |
| `product_name` | `NVARCHAR` | Descriptive name of the product, including type, color, and size (where applicable). |
| `category_id` | `NVARCHAR` | Identifier linking the product to its high-level category, derived from the product key prefix. |
| `category` | `NVARCHAR` | High-level product classification (e.g., `Bikes`, `Components`), sourced from ERP category reference data. |
| `subcategory` | `NVARCHAR` | More detailed classification of the product within its category. |
| `maintenance` | `NVARCHAR` | Indicates whether the product requires maintenance (`Yes`/`No`). |
| `product_cost` | `INT` | Cost of the product, in whole currency units. `0` if not available. |
| `product_line` | `NVARCHAR` | Product line/segment the product belongs to — `Mountain`, `Road`, `Other Sales`, `Touring`, or `Unknown`. |
| `start_date` | `DATE` | Date the product became available/active for sale. |

> **Note:** Only current products are included — historical/discontinued product versions (`prd_end_dt` populated) are excluded from this view, as historization is out of scope for this project.

---

## 3. `gold.fact_sales`

**Purpose:** Transactional fact table capturing individual sales order line items, linked to the customer and product dimensions.

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | `NVARCHAR` | Unique identifier for the sales order (e.g., `SO54496`). |
| `product_key` | `INT` | Surrogate key referencing the related product in `gold.dim_products`. |
| `customer_key` | `INT` | Surrogate key referencing the related customer in `gold.dim_customers`. |
| `order_date` | `DATE` | Date the sales order was placed. `NULL` if the source date was invalid/missing. |
| `shipping_date` | `DATE` | Date the order was shipped to the customer. `NULL` if the source date was invalid/missing. |
| `due_date` | `DATE` | Date by which the order payment was due. `NULL` if the source date was invalid/missing. |
| `sales_amount` | `INT` | Total monetary value of the line item, in whole currency units (e.g., `25`). Recalculated from `quantity × price` where the source value was missing, non-positive, or inconsistent. |
| `quantity` | `INT` | Number of units of the product ordered for the line item (e.g., `1`). |
| `price` | `INT` | Unit price of the product for the line item, in whole currency units (e.g., `25`). Derived from `sales_amount / quantity` where the source value was missing or non-positive. |

---

## Entity Relationship Summary

```
gold.dim_customers  ──┐
                       ├──< gold.fact_sales
gold.dim_products   ──┘
```

- `fact_sales.customer_key` → `dim_customers.customer_key` (many-to-one)
- `fact_sales.product_key`  → `dim_products.product_key`  (many-to-one)

Each row in `fact_sales` represents a single order line item, linked to exactly one customer and one product.
