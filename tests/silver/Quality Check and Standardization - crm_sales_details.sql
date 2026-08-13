SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE	
	WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt,
CASE	
	WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
END AS sls_ship_dt,
CASE	
	WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
END AS sls_due_dt,
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales / NULLIF(sls_quantity,0) 
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details


-- check for invalid dates

SELECT
	NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101

SELECT
	NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 OR sls_ship_dt > 20500101

SELECT
	NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt = 0 OR LEN(sls_due_dt) != 8 OR sls_due_dt > 20500101

-- check for Invalid Date orders

SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency : Between Sales, quantity, and price.
-- >> Sales = quantity * price
-- >> Values must not be NULL, Zero, or Negative.

SELECT DISTINCT
	sls_sales AS old_sls_sales ,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS new_sls_sales,
	
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity,0) 
		ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales < 0 OR sls_quantity < 0 OR sls_price <0
ORDER BY
	sls_sales,
	sls_quantity,
	sls_price