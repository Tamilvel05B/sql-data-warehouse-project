USE DataWarehouse;

-- Check for Nulls or Duplicates in Primary Key
-- Expectations : No Results

SELECT
cst_id,
COUNT(*) AS Count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(cst_key) > 1 OR cst_id IS NULL

-- check for unwanted spaces
-- Expectation : No Results

SELECT
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

-- Data Standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info


