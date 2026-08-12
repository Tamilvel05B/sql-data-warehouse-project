/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Purpose:
    This script creates all tables in the 'bronze' schema that serve as the
    raw data ingestion layer of the data warehouse.

Description:
    - Drops existing bronze tables (if they exist) to ensure a clean deployment.
    - Recreates the bronze tables with the required schema definitions.
    - Preserves the raw structure of source data with minimal or no transformations.
    - Serves as the foundation for downstream Silver and Gold layer processing.

Usage:
    Execute this script when:
      - Setting up the Bronze layer for the first time.
      - Rebuilding the Bronze schema during development or testing.
      - Refreshing the table structures after schema changes.

Notes:
    - Existing data in the affected tables will be permanently removed.
    - Ensure the 'bronze' schema exists before executing this script.
    - Intended for DDL (schema creation) only; data loading is handled separately.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- CRM Tables
-- =============================================================================

-- Create customer info table
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id                  INT,
    cst_key                 NVARCHAR(50),
    cst_firstname           NVARCHAR(50),
    cst_lastname            NVARCHAR(50),
    cst_marital_status      NVARCHAR(50),
    cst_gndr                NVARCHAR(50),
    cst_create_date         DATE
);
GO

-- Create product info table
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id                  INT,
    prd_key                 NVARCHAR(50),
    prd_nm                  NVARCHAR(50),
    prd_cost                INT,
    prd_line                NVARCHAR(50),
    prd_start_dt            DATE,
    prd_end_dt              DATE
);
GO

-- Create sales details table
IF OBJECT_ID('bronze.crm_sales_details') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num             NVARCHAR(50),
    sls_prd_key             NVARCHAR(50),
    sls_cust_id             INT,
    sls_order_dt            INT,
    sls_ship_dt             INT,
    sls_due_dt              INT,
    sls_sales               INT,
    sls_quantity            INT,
    sls_price                INT
);
GO

-- =============================================================================
-- ERP Tables
-- =============================================================================

-- Create ERP customer table
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid                     NVARCHAR(50),
    bdate                   DATE,
    gen                     NVARCHAR(50)
);
GO

-- Create ERP location table
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid                     NVARCHAR(50),
    cntry                   NVARCHAR(50)
);
GO

-- Create ERP category table
IF OBJECT_ID('bronze.px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.px_cat_g1v2;
GO

CREATE TABLE bronze.px_cat_g1v2 (
    cid                     NVARCHAR(50),
    cat                     NVARCHAR(50),
    subcat                  NVARCHAR(50),
    maintenance             NVARCHAR(50)
);
GO
