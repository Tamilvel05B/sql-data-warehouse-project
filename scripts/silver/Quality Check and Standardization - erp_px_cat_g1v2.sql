SELECT
cid,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

-- Check for unwanted spaces
SELECT maintenance
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance)

-- Data Standardization & Consistency

SELECT
DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2