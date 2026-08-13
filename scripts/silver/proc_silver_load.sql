/*
===============================================================================
Stored Procedure: silver.load_silver
===============================================================================
Purpose:
    Loads cleaned and standardized data into the 'silver' schema tables of
    the data warehouse from the 'bronze' schema.

Description:
    - Truncates each silver table before loading to ensure a full refresh.
    - Inserts data from bronze tables into their corresponding silver tables,
      applying cleaning, standardization, and deduplication logic.
    - Tracks and prints the load duration for each table, as well as the
      total duration for the batch.
    - Wrapped in TRY/CATCH so that any failure during the load prints the
      error message, number, and state instead of failing silently.

Tables Loaded:
    CRM Source:
      - silver.crm_cust_info      <- bronze.crm_cust_info
      - silver.crm_prd_info       <- bronze.crm_prd_info
      - silver.crm_sales_details  <- bronze.crm_sales_details
    ERP Source:
      - silver.erp_cust_az12      <- bronze.erp_cust_az12
      - silver.erp_loc_a101       <- bronze.erp_loc_a101
      - silver.erp_px_cat_g1v2    <- bronze.erp_px_cat_g1v2

Usage:
    EXEC silver.load_silver;

Notes:
    - This procedure performs a full TRUNCATE + INSERT (not incremental).
    - Intended to be run after the bronze layer has been loaded.
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT 'Batch start time: ' +CAST( @batch_start_time AS NVARCHAR);
        PRINT '===============================================================';
        PRINT 'Loading the Silver Layer';
        PRINT '===============================================================';

        PRINT '---------------------------------------------------------------';
        PRINT 'Loading CRM Tables'
        PRINT '---------------------------------------------------------------';

        -- Load: silver.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,

            -- Remove leading/trailing whitespace from name fields
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname)  AS cst_lastname,

            -- Standardize marital status codes into full, readable values
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,

            -- Standardize gender codes into full, readable values
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'Unknown'
            END AS cst_gndr,

            cst_create_date

        FROM (
            -- Deduplicate customers: keep only the most recent record per cst_id
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL   -- Exclude records with missing customer ID
        ) AS t
        WHERE flag_last = 1;          -- Keep only the latest record per customer
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: silver.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,

            -- Extract category ID from the first 5 characters of prd_key
            -- and convert the separator from '-' to '_' to match the
            -- format used in the category reference table
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

            -- Extract the actual product key by removing the category prefix
            -- (everything from position 7 onward)
            TRIM(SUBSTRING(prd_key, 7, LEN(prd_key))) AS prd_key,

            prd_nm,

            -- Replace NULL product costs with 0
            ISNULL(prd_cost, 0) AS prd_cost,

            -- Standardize product line codes into full, readable values
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'Unknown'
            END AS prd_line,

            -- Cast start date to DATE (strip any time component)
            CAST(prd_start_dt AS DATE) AS prd_start_dt,

            -- Derive end date as the day before the next start date for the same
            -- product key (i.e. a product's validity ends when its successor begins)
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt ASC
                ) - 1 AS DATE
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: silver.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert order date from integer (YYYYMMDD) to DATE;
            -- treat 0 or any value not exactly 8 digits long as invalid
            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            -- Convert ship date from integer (YYYYMMDD) to DATE;
            -- treat 0 or any value not exactly 8 digits long as invalid
            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            -- Convert due date from integer (YYYYMMDD) to DATE;
            -- treat 0 or any value not exactly 8 digits long as invalid
            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,

            -- Recalculate sales if missing, non-positive, or inconsistent with
            -- quantity * price; otherwise keep the original value
            CASE
                WHEN sls_sales IS NULL OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            -- Derive price from sales / quantity if missing or non-positive;
            -- guard against divide-by-zero with NULLIF; otherwise keep original
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        PRINT '---------------------------------------------------------------';
        PRINT 'Loading ERP Tables'
        PRINT '---------------------------------------------------------------';

        -- Load: silver.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            -- Remove 'NAS' prefix from customer ID if present, to align with
            -- the customer ID format used elsewhere (e.g. crm_cust_info)
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            -- Nullify birthdates that are in the future (data quality issue)
            CASE
                WHEN bdate >= GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            -- Standardize gender codes/values into full, readable values
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
                ELSE 'Unknown'
            END AS gen

        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: silver.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            -- Remove hyphens from customer ID to match the format used in
            -- other customer tables (e.g. crm_cust_info)
            REPLACE(cid, '-', '') AS cid,

            -- Standardize country codes/values into full, readable names;
            -- blank or NULL values are mapped to 'Unknown'
            CASE
                WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2 (
            cid,
            cat,
            subcat,
            maintenance
        )
        SELECT
            cid,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------';

        -- Batch summary
        PRINT '===============================================================';
        SET @batch_end_time = GETDATE();
        PRINT 'Loading Silver Layer is Complete';
        PRINT 'Batch start time: '+ CAST(@batch_start_time AS NVARCHAR);
        PRINT 'Batch end time: '+ CAST(@batch_end_time AS NVARCHAR);
        PRINT ' -- Total Load Duration: '+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '===============================================================';


    END TRY
    BEGIN CATCH
        -- Error handling
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
        PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END;

EXEC silver.load_silver