/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Completeness (no NULL surrogate keys) in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validity of core measures in the fact table.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after loading/refreshing the Gold layer.
    - Every check below states its expected result. Any query that returns
      rows when it should return none indicates a data quality issue that
      must be investigated and resolved before the layer is used for
      reporting or analysis.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================

-- Check for uniqueness of customer_key in gold.dim_customers
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check for NULL customer_key in gold.dim_customers
-- Expectation: No results
SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================

-- Check for uniqueness of product_key in gold.dim_products
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check for NULL product_key in gold.dim_products
-- Expectation: No results
SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================

-- Check the data model connectivity between fact and dimensions:
-- every fact row should successfully match a customer and a product.
-- Expectation: No results
SELECT
    f.*
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;

-- Check for invalid sales measures: sales amount, quantity, or price
-- that are NULL, zero, or negative
-- Expectation: No results
SELECT
    order_number,
    sales_amount,
    quantity,
    price
FROM gold.fact_sales
WHERE sales_amount IS NULL OR sales_amount <= 0
   OR quantity IS NULL OR quantity <= 0
   OR price IS NULL OR price <= 0;

-- Check for orders where the shipping or due date occurs before the
-- order date (logically inconsistent date sequence)
-- Expectation: No results
SELECT
    order_number,
    order_date,
    shipping_date,
    due_date
FROM gold.fact_sales
WHERE shipping_date < order_date
   OR due_date < order_date;