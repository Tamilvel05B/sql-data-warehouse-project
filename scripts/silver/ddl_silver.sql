/*
===============================================================================
DDL Script: Create silver Tables
===============================================================================
Purpose:
    This script creates all tables in the 'silver' schema that serve as the
    raw data ingestion layer of the data warehouse.

Description:
    - Drops existing silver tables (if they exist) to ensure a clean deployment.
    - Recreates the silver tables with the required schema definitions.
    - Preserves the raw structure of source data with minimal or no transformations.
    - Serves as the foundation for downstream Silver and Gold layer processing.

Usage:
    Execute this script when:
      - Setting up the silver layer for the first time.
      - Rebuilding the silver schema during development or testing.
      - Refreshing the table structures after schema changes.

Notes:
    - Existing data in the affected tables will be permanently removed.
    - Ensure the 'silver' schema exists before executing this script.
    - Intended for DDL (schema creation) only; data loading is handled separately.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- CRM Tables
-- =============================================================================

-- Create customer info table
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id                  INT,
    cst_key                 NVARCHAR(50),
    cst_firstname           NVARCHAR(50),
    cst_lastname            NVARCHAR(50),
    cst_marital_status      NVARCHAR(50),
    cst_gndr                NVARCHAR(50),
    cst_create_date         DATETIME,
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO

-- Create product info table
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id                  INT,
    cat_id                  NVARCHAR(50),
    prd_key                 NVARCHAR(50),
    prd_nm                  NVARCHAR(50),
    prd_cost                INT,
    prd_line                NVARCHAR(50),
    prd_start_dt            DATE,
    prd_end_dt              DATE,
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO

-- Create sales details table
IF OBJECT_ID('silver.crm_sales_details') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num             NVARCHAR(50),
    sls_prd_key             NVARCHAR(50),
    sls_cust_id             INT,
    sls_order_dt            DATE,
    sls_ship_dt             DATE,
    sls_due_dt              DATE,
    sls_sales               INT,
    sls_quantity            INT,
    sls_price               INT,
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO

-- =============================================================================
-- ERP Tables
-- =============================================================================

-- Create ERP customer table
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid                     NVARCHAR(50),
    bdate                   DATETIME,
    gen                     NVARCHAR(50),
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO

-- Create ERP location table
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid                     NVARCHAR(50),
    cntry                   NVARCHAR(50),
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO

-- Create ERP category table
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    cid                     NVARCHAR(50),
    cat                     NVARCHAR(50),
    subcat                  NVARCHAR(50),
    maintenance             NVARCHAR(50),
    dwh_load_date           DATETIME2 DEFAULT GETDATE()
);
GO