USE DataWarehouse;

-- Check for Nulls or Duplicates in Primary Key
-- Expectations : No Results

SELECT
prd_id,
COUNT(*) AS Count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*	) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectation : No Results

SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative Numbers
-- Expecation Results : No Results

SELECT
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardization and consistency

SELECT
DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders

SELECT
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt