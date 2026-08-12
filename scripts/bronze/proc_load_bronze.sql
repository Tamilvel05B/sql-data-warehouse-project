/*
===============================================================================
Stored Procedure: bronze.load_bronze
===============================================================================
Purpose:
    Loads raw source data into the 'bronze' schema tables of the data
    warehouse from flat files (CSV) using BULK INSERT.

Description:
    - Truncates each bronze table before loading to ensure a full refresh.
    - Bulk-inserts data from the CRM and ERP source CSV files into their
      corresponding bronze tables.
    - Tracks and prints the load duration for each table, as well as the
      total duration for the batch.
    - Wrapped in TRY/CATCH so that any failure during the load prints the
      error message, number, and state instead of failing silently.

Tables Loaded:
    CRM Source:
      - bronze.crm_cust_info      <- cust_info.csv
      - bronze.crm_prd_info       <- prd_info.csv
      - bronze.crm_sales_details  <- sales_details.csv
    ERP Source:
      - bronze.erp_cust_az12      <- cust_az12.csv
      - bronze.erp_loc_a101       <- loc_a101.csv
      - bronze.px_cat_g1v2        <- px_cat_g1v2.csv

Usage:
    EXEC bronze.load_bronze;

Notes:
    - This procedure performs a full TRUNCATE + INSERT (not incremental).
    - File paths are hardcoded to a local source folder; update the paths
      if the source location changes.
    - Intended to be run after the bronze schema/tables have been created.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT 'Batch start time: ' +CAST( @batch_start_time AS NVARCHAR);
        PRINT '===============================================================';
        PRINT 'Loading the Bronze Layer';
        PRINT '===============================================================';

        PRINT '---------------------------------------------------------------';
        PRINT 'Loading CRM Tables'
        PRINT '---------------------------------------------------------------';

        -- Load: bronze.crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\CRM Dataset\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: bronze.crm_prd_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\CRM Dataset\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: bronze.crm_sales_details
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\CRM Dataset\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'


        PRINT '---------------------------------------------------------------';
        PRINT 'Loading ERP Tables'
        PRINT '---------------------------------------------------------------';


        -- Load: bronze.erp_cust_az12
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\ERP Dataset\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------'


        -- Load: bronze.erp_loc_a101
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\ERP Dataset\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds'
        PRINT '---------------------------------------------------------------------';


        -- Load: bronze.px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.px_cat_g1v2
        FROM 'E:\SQL Zero to Hero\Projects\DataWareHouse Project\ERP Dataset\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------';

        -- Batch summary
        PRINT '===============================================================';
        SET @batch_end_time = GETDATE();
        PRINT 'Loading Bronze Layer is Complete';
        PRINT 'Batch start time: '+ CAST(@batch_start_time AS NVARCHAR);
        PRINT 'Batch end time: '+ CAST(@batch_end_time AS NVARCHAR);
        PRINT ' -- Total Load Duration: '+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '===============================================================';


    END TRY
    BEGIN CATCH
        -- Error handling
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
        PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END;
