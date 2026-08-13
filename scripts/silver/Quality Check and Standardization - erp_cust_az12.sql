USE DataWarehouse;

SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	CASE	
		WHEN bdate >= GETDATE() THEN NULL
		ELSE bdate
		END AS bdate,
	CASE 
		WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
		ELSE 'Unknown'
	END AS gen
FROM bronze.erp_cust_az12

-- Identify out-of-range

SELECT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & consistency

SELECT
DISTINCT gen,
CASE 
	WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	ELSE 'Unknown'
	END AS gen
FROM bronze.erp_cust_az12

SELECT * FROM silver.erp_cust_az12