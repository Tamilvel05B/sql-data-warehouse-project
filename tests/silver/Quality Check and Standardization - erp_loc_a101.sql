SELECT
	REPLACE(cid,'-','') AS cid,
	CASE
		WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany' 
		WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
		ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101

-- Data Standardization and Consistency

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry