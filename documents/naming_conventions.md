# 📐 Naming Conventions

This document outlines the naming conventions for schemas, tables, views, columns, and other objects in a data warehouse.

---

## 📑 Table of Contents

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
4. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)
5. [Quick Reference](#quick-reference)

---

## General Principles

| Rule | Description |
|---|---|
| **Case style** | Use `snake_case` — all lowercase, words separated by underscores (`_`). |
| **Language** | Use English for all object and column names. |
| **Reserved words** | Never use SQL reserved words (`select`, `date`, `order`, etc.) as object names. |
| **Clarity over brevity** | Prefer descriptive names over cryptic abbreviations, except for well-known standard suffixes (`_key`, `_dt`, `dwh_`). |

---

## Table Naming Conventions

### Bronze Rules

Bronze tables are a raw, 1:1 mirror of the source system — no renaming, no reshaping.

**Pattern:** `<sourcesystem>_<entity>`

| Element | Meaning |
|---|---|
| `<sourcesystem>` | Name of the source system (e.g., `crm`, `erp`) |
| `<entity>` | Exact table/file name as it exists in the source system |

**Example:** `crm_customer_info` → customer information loaded as-is from the CRM system.

### Silver Rules

Silver tables retain the same names as their Bronze counterparts — only the contents are cleaned, standardized, and deduplicated; the table identity does not change.

**Pattern:** `<sourcesystem>_<entity>`

| Element | Meaning |
|---|---|
| `<sourcesystem>` | Name of the source system (e.g., `crm`, `erp`) |
| `<entity>` | Same entity name used in the corresponding Bronze table |

**Example:** `crm_customer_info` → cleaned and standardized customer information from the CRM system.

### Gold Rules

Gold objects use meaningful, business-aligned names, prefixed by a category that describes the object's role in the model.

**Pattern:** `<category>_<entity>`

| Element | Meaning |
|---|---|
| `<category>` | Role of the object — `dim` (dimension) or `fact` (fact table) |
| `<entity>` | Descriptive, business-friendly name (e.g., `customers`, `products`, `sales`) |

**Examples:**
- `dim_customers` → dimension table for customer data
- `fact_sales` → fact table containing sales transactions

#### Glossary of Category Patterns

| Pattern | Meaning | Example(s) |
|---|---|---|
| `dim_` | Dimension table | `dim_customer`, `dim_product` |
| `fact_` | Fact table | `fact_sales` |
| `report_` | Report table | `report_customers`, `report_sales_monthly` |

---

## Column Naming Conventions

### Surrogate Keys

All primary keys in dimension tables must use the suffix `_key`.

**Pattern:** `<table_name>_key`

| Element | Meaning |
|---|---|
| `<table_name>` | Name of the table or entity the key belongs to |
| `_key` | Suffix indicating this column is a surrogate key |

**Example:** `customer_key` → surrogate key in the `dim_customers` table.

### Technical Columns

All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.

**Pattern:** `dwh_<column_name>`

| Element | Meaning |
|---|---|
| `dwh` | Prefix reserved exclusively for system-generated metadata |
| `<column_name>` | Descriptive name indicating the column's purpose |

**Example:** `dwh_load_date` → system-generated column storing the date a record was loaded.

---

## Stored Procedure Naming Conventions

All stored procedures used for loading data must follow the naming pattern below.

**Pattern:** `load_<layer>`

| Element | Meaning |
|---|---|
| `<layer>` | The layer being loaded — `bronze`, `silver`, or `gold` |

**Examples:**
- `load_bronze` → stored procedure for loading data into the Bronze layer
- `load_silver` → stored procedure for loading data into the Silver layer

---

## Quick Reference

| Layer / Object | Naming Pattern | Example |
|---|---|---|
| Bronze table | `<sourcesystem>_<entity>` | `crm_customer_info` |
| Silver table | `<sourcesystem>_<entity>` | `crm_customer_info` |
| Gold dimension | `dim_<entity>` | `dim_customers` |
| Gold fact | `fact_<entity>` | `fact_sales` |
| Surrogate key column | `<table_name>_key` | `customer_key` |
| Technical/metadata column | `dwh_<column_name>` | `dwh_load_date` |
| Load procedure | `load_<layer>` | `load_silver` |
