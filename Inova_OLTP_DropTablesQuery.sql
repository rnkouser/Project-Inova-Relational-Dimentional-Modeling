USE Inova_OLTP;

/*
By using 'U', we're specifically checking for user-defined tables. 
This distinguishes them from other types of objects that might have the same name, such as views or stored procedures.

Some other common object type codes include:

'V' for View
'P' for Stored Procedure
'FN' for Scalar Function
'TF' for Table-valued Function
*/



-- Drop tables with foreign key constraints first
IF OBJECT_ID('Logistics', 'U') IS NOT NULL
    DROP TABLE Logistics;

IF OBJECT_ID('Allowance', 'U') IS NOT NULL
    DROP TABLE Allowance;

IF OBJECT_ID('Sales', 'U') IS NOT NULL
    DROP TABLE Sales;

IF OBJECT_ID('Production', 'U') IS NOT NULL
    DROP TABLE Production;

IF OBJECT_ID('Inventory', 'U') IS NOT NULL
    DROP TABLE Inventory;

IF OBJECT_ID('DeliveryStatus', 'U') IS NOT NULL
    DROP TABLE DeliveryStatus;

IF OBJECT_ID('QualityStatus', 'U') IS NOT NULL
    DROP TABLE QualityStatus;

IF OBJECT_ID('Deficiency', 'U') IS NOT NULL
    DROP TABLE Deficiency;

IF OBJECT_ID('Batch', 'U') IS NOT NULL
    DROP TABLE Batch;

IF OBJECT_ID('Policy', 'U') IS NOT NULL
    DROP TABLE Policy;

IF OBJECT_ID('TaxTariff', 'U') IS NOT NULL
    DROP TABLE TaxTariff;

IF OBJECT_ID('Product', 'U') IS NOT NULL
    DROP TABLE Product;

IF OBJECT_ID('ProductModel', 'U') IS NOT NULL
    DROP TABLE ProductModel;

IF OBJECT_ID('ProductMake', 'U') IS NOT NULL
    DROP TABLE ProductMake;

IF OBJECT_ID('ProductCategory', 'U') IS NOT NULL
    DROP TABLE ProductCategory;

IF OBJECT_ID('Customer', 'U') IS NOT NULL
    DROP TABLE Customer;

IF OBJECT_ID('OverTime', 'U') IS NOT NULL
    DROP TABLE OverTime;

IF OBJECT_ID('Shift', 'U') IS NOT NULL
    DROP TABLE Shift;

IF OBJECT_ID('Employee', 'U') IS NOT NULL
    DROP TABLE Employee;

IF OBJECT_ID('Department', 'U') IS NOT NULL
    DROP TABLE Department;

IF OBJECT_ID('Warehouse', 'U') IS NOT NULL
    DROP TABLE Warehouse;

IF OBJECT_ID('Plant', 'U') IS NOT NULL
    DROP TABLE Plant;

IF OBJECT_ID('City', 'U') IS NOT NULL
    DROP TABLE City;

IF OBJECT_ID('State', 'U') IS NOT NULL
    DROP TABLE State;

IF OBJECT_ID('Country', 'U') IS NOT NULL
    DROP TABLE Country;

PRINT 'All tables have been dropped successfully.';

--============================================
		--Drop Tables From Staging
--============================================

USE [Inova_Staging]


-- Drop tables with foreign key constraints first
IF OBJECT_ID('Oltp.Logistics', 'U') IS NOT NULL
    DROP TABLE Oltp.Logistics;

IF OBJECT_ID('Oltp.Sales', 'U') IS NOT NULL
    DROP TABLE Oltp.Sales;

IF OBJECT_ID('Oltp.Production', 'U') IS NOT NULL
    DROP TABLE Oltp.Production;

IF OBJECT_ID('Oltp.Inventory', 'U') IS NOT NULL
    DROP TABLE Oltp.Inventory;

IF OBJECT_ID('Oltp.Allowance', 'U') IS NOT NULL
    DROP TABLE Oltp.Allowance;

IF OBJECT_ID('Oltp.OverTime', 'U') IS NOT NULL
    DROP TABLE oltp.OverTime;

IF OBJECT_ID('Oltp.Shift', 'U') IS NOT NULL
    DROP TABLE Oltp.Shift;

IF OBJECT_ID('Oltp.DeliveryStatus', 'U') IS NOT NULL
    DROP TABLE Oltp.DeliveryStatus;

IF OBJECT_ID('Oltp.Employee', 'U') IS NOT NULL
    DROP TABLE oltp.Employee;

IF OBJECT_ID('Oltp.Batch', 'U') IS NOT NULL
    DROP TABLE oltp.Batch;

IF OBJECT_ID('Oltp.QualityStatus', 'U') IS NOT NULL
    DROP TABLE oltp.QualityStatus;

IF OBJECT_ID('Oltp.Warehouse', 'U') IS NOT NULL
    DROP TABLE Oltp.Warehouse;

IF OBJECT_ID('Oltp.Customer', 'U') IS NOT NULL
    DROP TABLE Oltp.Customer;

IF OBJECT_ID('Oltp.Plant', 'U') IS NOT NULL
    DROP TABLE oltp.Plant;

IF OBJECT_ID('Oltp.Product', 'U') IS NOT NULL
    DROP TABLE oltp.Product;

PRINT 'All tables have been dropped successfully.';

--============================================
		--Drop Tables From EDW
--============================================

Use Inova_EDW


-- Drop tables with foreign key constraints first
IF OBJECT_ID('Edw.FactLogistics', 'U') IS NOT NULL
    DROP TABLE Edw.FactLogistics;

IF OBJECT_ID('Edw.FactSales', 'U') IS NOT NULL
    DROP TABLE  Edw.FactSales;

IF OBJECT_ID('Edw.FactProduction', 'U') IS NOT NULL
    DROP TABLE Edw.FactProduction;

IF OBJECT_ID('Edw.FactInventory', 'U') IS NOT NULL
    DROP TABLE Edw.FactInventory;

IF OBJECT_ID('Edw.FactAllowance', 'U') IS NOT NULL
    DROP TABLE Edw.FactAllowance;

IF OBJECT_ID('edw.FactOverTime', 'U') IS NOT NULL
    DROP TABLE edw.FactOverTime;

IF OBJECT_ID('Edw.FactShift', 'U') IS NOT NULL
    DROP TABLE Edw.FactShift;

IF OBJECT_ID('Edw.DimDate', 'U') IS NOT NULL
    DROP TABLE Edw.DimDate;

IF OBJECT_ID('Edw.DimTime', 'U') IS NOT NULL
    DROP TABLE Edw.DimTime;

IF OBJECT_ID('Edw.DimDeliveryStatus', 'U') IS NOT NULL
    DROP TABLE Edw.DimDeliveryStatus;

IF OBJECT_ID('Edw.DimBatch', 'U') IS NOT NULL
    DROP TABLE  Edw.DimBatch;

IF OBJECT_ID('Edw.dimQualityStatus', 'U') IS NOT NULL
    DROP TABLE Edw.dimQualityStatus;

IF OBJECT_ID('Edw.DimCustomer', 'U') IS NOT NULL
    DROP TABLE Edw.DimCustomer;

IF OBJECT_ID('Edw.DimProduct', 'U') IS NOT NULL
    DROP TABLE edw.DimProduct;

IF OBJECT_ID('Edw.DimEmployee', 'U') IS NOT NULL
    DROP TABLE Edw.DimEmployee;

IF OBJECT_ID('Edw.dimWarehouse', 'U') IS NOT NULL
    DROP TABLE Edw.dimWarehouse;

IF OBJECT_ID('Edw.DimPlant', 'U') IS NOT NULL
    DROP TABLE edw.DimPlant;

PRINT 'All tables have been dropped successfully.';