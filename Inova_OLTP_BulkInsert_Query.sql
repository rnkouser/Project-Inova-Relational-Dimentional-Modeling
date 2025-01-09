--====================================
-- Now, let's perform the bulk insert
--========================================
/*
The WITH clause specifies:

FIELDTERMINATOR = ',' : Fields in the CSV are separated by commas.
ROWTERMINATOR = '\n' : Rows in the CSV end with a newline.
FIRSTROW = 2 : Start inserting from the second row (skipping the header).
TABLOCK : Improves performance by locking the table during the insert.
*/

use [Inova_OLTP]

--=========================
--- Inserting Batch data
--=======================
BULK INSERT Batch
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Batch.csv' 
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Batch;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Batch;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--====================================
--===Inserting Deficiencies data===
--==================================


BULK INSERT Deficiency
FROM 'C:\Inova Project\InovaData\data\Deficiency.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Deficiency;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Deficiency;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--===================================
--- Inserting Quality Status data
--==============================
BULK INSERT QualityStatus
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\QualityStatus.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM QualityStatus;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM QualityStatus;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Warehouse data
--============================
BULK INSERT Warehouse
FROM 'C:\Inova Project\InovaData\data\Warehouse.csv' 
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Warehouse;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Warehouse;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Department data
--============================
BULK INSERT Department
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Department.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Department;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Department;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting OverTime data
--============================
BULK INSERT OverTime
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Overtime.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM OverTime;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM OverTime;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Shift data
--============================
BULK INSERT [Shift]
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Shift.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM [Shift];

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM [Shift];

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Employee data
--============================
BULK INSERT Employee
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Employee.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Employee;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Employee;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Allowance data
--============================
BULK INSERT Allowance
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Allowance.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Allowance;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Allowance;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Country data
--============================
BULK INSERT Country
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Country.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Country;

-- Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) FROM Country;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting TaxTariff data
--============================
BULK INSERT TaxTariff
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\TaxTariff.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM TaxTariff;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from TaxTariff;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Policy data
--============================
BULK INSERT Policy
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Policy.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Policy;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Policy;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting [State] data
--============================
BULK INSERT [State]
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\State.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM [State];

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from [State];

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting [City] data
--============================
BULK INSERT [City]
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\City.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM [City];

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from [City];

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--========================================
--- Inserting [Plant] data: DDL (Create,drop, alter) , DML (select, from, where, group by), DCL(grant,deny)
--=====================================
BULK INSERT Plant
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Plant.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM [Plant];

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from [Plant];

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--========================================
--- Inserting Customer data: 
--=====================================
BULK INSERT Customer
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Customer.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Customer;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Customer;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting ProductCategory data
--============================
BULK INSERT ProductCategory
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\ProductCategory.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM ProductCategory;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from ProductCategory;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting ProductMake data
--============================
BULK INSERT ProductMake
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\ProductMake.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM ProductMake;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from ProductMake;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting ProductModel data
--============================
BULK INSERT ProductModel
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\ProductModel.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM ProductModel;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from ProductModel;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Product data
--============================
BULK INSERT Product
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Product.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Product;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Product;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Inventory data
--============================
BULK INSERT Inventory
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Inventory.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Inventory;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Inventory;

--============================
--- Inserting DeliveryStatus data
--============================
BULK INSERT DeliveryStatus
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\DeliveryStatus.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM DeliveryStatus;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from DeliveryStatus;

--============================
--- Inserting Production data
--============================
BULK INSERT Production
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Production.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Production;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Production;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Sales data
--============================
BULK INSERT Sales
FROM 'C:\Users\nadmin\OneDrive\Desktop\Inova Project\InovaData\data\Sales.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Sales;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Sales;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));

--============================
--- Inserting Logistics data
--============================
BULK INSERT Logistics
FROM 'C:\Inova Project\InovaData\data\Logistics.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
	FORMAT='CSV',
    TABLOCK
);

-- Verify the data has been inserted
SELECT TOP 10 * FROM Logistics;

--Declare a variable to store the count
DECLARE @RowCount INT;

-- Get the total number of rows inserted
SELECT @RowCount = COUNT(*) from Logistics;

-- Print the total number of rows inserted
PRINT 'Total rows inserted: ' + CAST(@RowCount AS NVARCHAR(10));