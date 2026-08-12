/*
===============================================================================
Script: Create Database and Schemas
===============================================================================
Purpose:
    This script initializes the DataWarehouse environment by creating a new
    SQL Server database and configuring the required schemas for the data
    warehouse architecture.

    The script performs the following tasks:
    • Checks whether the DataWarehouse database already exists.
    • Drops the existing database if found.
    • Creates a new DataWarehouse database.
    • Creates the following schemas:
        - bronze : Stores raw data imported from source systems.
        - silver : Stores cleansed and transformed data.
        - gold   : Stores business-ready data optimized for analytics and reporting.

Usage:
    Execute this script before running any ETL processes or creating database
    objects such as tables, views, procedures, and functions.

Warning:
    This script is DESTRUCTIVE.
    If the DataWarehouse database already exists, it will be dropped and
    recreated, resulting in the permanent deletion of all existing data and
    database objects.

    Ensure you have a valid backup before executing this script in any
    environment where data preservation is required.
===============================================================================
*/

USE master;
GO

-- DROP and recreate the DataWarehourse database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create DataBase 'DataWarehouse'

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
