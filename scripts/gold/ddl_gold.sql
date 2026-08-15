/*
===============================================================================
Gold Layer Views
===============================================================================
Purpose:
    Exposes a business-friendly star schema (dimension + fact views) built
    on top of the Silver layer. These views are the final, analytics-ready
    layer consumed by BI tools (Power BI, SQL reporting, etc.).

Views:
    - gold.dim_customers  : Customer dimension (surrogate key + attributes)
    - gold.dim_products   : Product dimension (surrogate key + attributes,
                             current products only)
    - gold.fact_sales     : Sales fact table (links to dimension surrogate
                             keys via natural keys)

Notes:
    - Surrogate keys (*_key) are generated using ROW_NUMBER() and are used
      to join facts to dimensions instead of the natural/business keys.
    - No physical tables are created; these are views built directly on
      the Silver layer, refreshed automatically whenever queried.
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- View: gold.dim_customers
-- Purpose: Customer dimension. Integrates customer master data from CRM
--          (primary source) with ERP customer and location data
--          (supplementary attributes: gender fallback, country).
-- ============================================================================

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    -- Surrogate key for the dimension (used to join with fact_sales)
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,

    ci.cst_id       AS customer_id,
    ci.cst_key      AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname  AS last_name,
    la.cntry        AS country,
    ci.cst_marital_status AS marital_status,

    -- Gender resolution: CRM is treated as the master/trusted source.
    -- If CRM has no valid gender ('Unknown'), fall back to the ERP source;
    -- default to 'Unknown' if neither source has a value.
    CASE
        WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'Unknown')
    END AS gender,

    CAST(ca.bdate AS DATE)          AS birth_date,
    CAST(ci.cst_create_date AS DATE) AS create_date

FROM silver.crm_cust_info AS ci

-- ERP birthdate/gender data, matched on customer key/ID
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

-- ERP location data (country), matched on customer key/ID
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;
GO

-- ============================================================================
-- View: gold.dim_products
-- Purpose: Product dimension. Combines CRM product master data with ERP
--          category/subcategory data. Only current products (no end date)
--          are included, since historization is out of scope.
-- ============================================================================

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    -- Surrogate key for the dimension (used to join with fact_sales)
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    pn.prd_id    AS product_id,
    pn.prd_key   AS product_number,
    pn.prd_nm    AS product_name,
    pn.cat_id    AS category_id,
    pc.cat       AS category,
    pc.subcat    AS subcategory,
    pc.maintenance AS maintenance,
    pn.prd_cost  AS product_cost,
    pn.prd_line  AS product_line,
    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn

-- ERP category reference data, matched on category ID
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.cid

-- Only include current/active products (historical versions excluded,
-- since prd_end_dt is set once a product is superseded)
WHERE pn.prd_end_dt IS NULL;
GO

-- ============================================================================
-- View: gold.fact_sales
-- Purpose: Sales fact table. Links each sales transaction to the customer
--          and product dimensions via their surrogate keys, and carries
--          the core sales measures (sales amount, quantity, price).
-- ============================================================================

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    c.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

FROM silver.crm_sales_details sd

-- Resolve product surrogate key via the product's natural key
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

-- Resolve customer surrogate key via the customer's natural key
LEFT JOIN gold.dim_customers c
    ON sd.sls_cust_id = c.customer_id;
GO
