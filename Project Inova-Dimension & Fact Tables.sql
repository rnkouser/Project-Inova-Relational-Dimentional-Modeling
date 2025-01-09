
--=================================
-- Create Staging and EDW databases
--=================================
--database for stagaing
create database Inova_STAGING
use [Inova_STAGING]
create schema OLTP

--database for edw
create database Inova_EDW
use [Inova_EDW]
create schema edw


--===Dimension table======
--1) Product

--extract the product
use [Inova_OLTP]

select p.ProductID as ProductSourceID, p.ProductName, p.ProductDescription,p.ProductWeight,p.ProductLength,p.ProductHeight,pm.ModelName,pm.ModelStyle,pm.ModelYear,
pk.MakeName,pc.CategoryName,p.UnitPrice --,getdate() as Loaddate
from [dbo].[Product] as p
inner join [dbo].[ProductModel] as pm on pm.ProductModelID=p.ProductModelID
inner join [dbo].[ProductMake] as pk on pk.ProductMakeID=pm.ProductMakeID
inner join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=p.ProductCategoryID

--OlptCount
select count(*) as OltpCount
from [dbo].[Product] as p
inner join [dbo].[ProductModel] as pm on pm.ProductModelID=p.ProductModelID
inner join [dbo].[ProductMake] as pk on pk.ProductMakeID=pm.ProductMakeID
inner join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=p.ProductCategoryID

--load into staging (truncate and load the denormalize product data-productmodel,productmake, and productcategory)
use [Inova_STAGING]

IF OBJECT_ID('oltp.Product', 'U') IS NOT NULL
truncate table oltp.Product 

--drop table oltp.Product
create table oltp.Product 
(
ProductSourceID int,
ProductName nvarchar(50),
ProductDescription nvarchar (50),
ProductWeight int NOT NULL,
ProductLength int NOT NULL,
ProductHeight int NOT NULL,
ModelName nvarchar (50) NOT NULL,
ModelStyle nvarchar(50),
ModelYear int NOT NULL,
MakeName nvarchar (50) NOT NULL,
CategoryName nvarchar (50) NOT NULL,
UnitPrice Float NOT NULL,
LoadDate datetime default getdate(),
constraint pk_staging_oltp_product_productsourceid primary key(ProductSourceID) 
)

--checking
select ProductSourceID, ProductName, ProductDescription,ProductWeight,ProductLength,ProductHeight,ModelName,ModelStyle,ModelYear,
MakeName,CategoryName,UnitPrice,LoadDate 
from oltp.Product

--stagecount
select count(*) as StageCount
from oltp.Product


--ingest staged product data into EDW

/*
Slow Changing Dimension (SCD)
===========================
--scd type 0: Do nothing
--scd type 1: Overwrite
--scd type 2: track change by adding new row (EffectiveStartdate, EffectiveEnddate, optional:Iscurrent) --most popular
--scd type 3: track change by adding new column (Originalproductname, Currentproductname, optional:Iscurrent)
--scd type 6: track change by adding new row and column (Originalproductname, Currentproductname,EffectiveStartdate, EffectiveEnddate, optional:Iscurrent)

*/

use [Inova_EDW]

--drop table edw.DimProduct
create table edw.DimProduct 
(
ProductKey int identity(1,1),
ProductSourceID int,
ProductName nvarchar(50), --SCD type 2
ProductDescription nvarchar (50),
ProductWeight int NOT NULL,
ProductLength int NOT NULL,
ProductHeight int NOT NULL,
ModelName nvarchar (50) NOT NULL,
ModelStyle nvarchar(50),
ModelYear int NOT NULL,
MakeName nvarchar (50) NOT NULL,
CategoryName nvarchar (50) NOT NULL,
UnitPrice Float NOT NULL,
EffectiveStartdate datetime,
EffectiveEnddate datetime,
constraint pk_edw_product_productkey primary key(ProductKey) 
)

--checking
select ProductKey, ProductSourceID,ProductName,ProductDescription,ProductWeight,ProductLength,ProductHeight,
ModelName,ModelStyle,ModelYear,CategoryName,UnitPrice,EffectiveStartdate,EffectiveEnddate 
from edw.DimProduct

--EdwCount
select count(*)
from edw.DimProduct


--===Dimension [table] Customer  ======
/*
--Businness
-===========
1. Partial Masking all addresses
2. Full Masking email, phone
3. Exclude Billing and Delivery Addresss
4. Comply with GDPR

--Partial Masking
500 Maple St, Summerside, Prince Edward Island, Canada

*/
--2) Customer

--Extract the Customer data
    
	-- Check ---
use Inova_OLTP

select CustomerID as CustomerSourceID, CustomerFirstName, CustomerLastName, CustomerAddress, ct.City,st.State,cy.Country,cy.Continent, p.policy, T.taxTariff
from Customer as C
inner join city as ct on ct.CityID= C.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID
inner join [Policy] as P on P.countryID = cy.countryID
inner join TaxTariff as T on T.countryID = cy.countryID



--============
-- TEST
--============
SELECT DISTINCT C.CustomerID as CustomerSourceID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress, ct.City, st.State, cy.Country, cy.Continent, p.Policy, T.TaxTariff
FROM Customer as C
INNER JOIN city as ct on ct.CityID = C.CityID
INNER JOIN State as st on st.StateID = ct.StateID
INNER JOIN Country as cy on cy.CountryID = st.CountryID
INNER JOIN [Policy] as P on P.countryID = cy.countryID
INNER JOIN TaxTariff as T on T.countryID = cy.countryID;

--================
---TEST
--=================

SELECT C.CustomerID as CustomerSourceID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress, ct.City, st.State, cy.Country, cy.Continent,
MAX(p.Policy) as Policy, MAX(T.TaxTariff) as TaxTariff
FROM Customer as C
INNER JOIN city as ct on ct.CityID = C.CityID
INNER JOIN State as st on st.StateID = ct.StateID
INNER JOIN Country as cy on cy.CountryID = st.CountryID
INNER JOIN [Policy] as P on P.countryID = cy.countryID
INNER JOIN TaxTariff as T on T.countryID = cy.countryID
GROUP BY C.CustomerID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress, ct.City, st.State, cy.Country, cy.Continent

--================
-- TEST No.2
--================

SELECT C.CustomerID as CustomerSourceID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress, ct.City, st.State, cy.Country, cy.Continent, 
	MAX(p.Policy) as Policy, Max(T.TaxTariff) as TaxTariff
FROM Customer as C
LEFT JOIN city as ct ON ct.CityID = C.CityID
LEFT JOIN State as st ON st.StateID = ct.StateID
LEFT JOIN Country as cy ON cy.CountryID = st.CountryID
LEFT JOIN [Policy] as P ON P.countryID = cy.countryID
LEFT JOIN TaxTariff as T ON T.countryID = cy.countryID
GROUP BY C.CustomerID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress, ct.City, st.State, cy.Country, cy.Continent
--====================



--============================
--TEST No.3
--============================


SELECT 
c.CustomerID as CustomerSourceID, CONCAT(UPPER(c.CustomerLastName), ',', c.CustomerFirstName) as CustomerName, 
STUFF(CustomerAddress, 4, LEN(CustomerAddress), '******') as MaskedCustomerAddress,
HASHBYTES('SHA2_512', c.PhoneNo) as MaskedPhoneNo,
HASHBYTES('SHA2_512', c.Email) as MaskedEmail,ct.City, st.State, cy.Country, cy.Continent,
MAX(p.policy) as Policy, 
MAX(T.taxTariff) as TaxTariff
FROM 
Customer as C
LEFT JOIN City as ct on ct.CityID = C.CityID
LEFT JOIN State as st on st.StateID = ct.StateID
LEFT JOIN Country as cy on cy.CountryID = st.CountryID
LEFT  JOIN Policy as P on P.countryID = cy.countryID
LEFT JOIN TaxTariff as T on T.countryID = cy.countryID
GROUP BY C.CustomerID, C.CustomerFirstName, C.CustomerLastName, C.CustomerAddress,C.PhoneNo,C.Email, ct.City, st.State, cy.Country, cy.Continent

 





--===========
--==========

---SELECTCustomerID as CustomerSourceID COUNT(*) FROM Customer GROUP BY CustomerID HAVING COUNT(*) > 1 


--Implementing Business Process 
--## The STuff Function for partial masking and The Hasbytes Function for full masking 
select c.CustomerID as CustomerSourceID, concat(upper(c.CustomerLastName),',',c.CustomerFirstName) as CustomerName, 
stuff(CustomerAddress,4,len(CustomerAddress),'******') as MaskedCustomerAddress,
hashbytes('SHA2_512',c.PhoneNo) as MaskedPhoneNo,hashbytes('SHA2_512',c.Email) as MaskedEmail, ct.City,st.State,cy.Country,cy.Continent,p.policy,T.taxTariff,T.Status
from Customer as C
inner join city as ct on ct.CityID= C.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID
inner join [Policy] as P on P.countryID = cy.countryID
inner join TaxTariff as T on T.countryID = cy.countryID

--------




==================================
 
-- Count ---
select count(*) OltpCount
from Customer as C
inner join city as ct on ct.CityID= C.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID
inner join [Policy] as P on P.countryID = cy.countryID
inner join TaxTariff as T on T.countryID = cy.countryID

--load into staging 
use [Inova_STAGING]

	-- Truncate ---

If Object_ID('oltp.Customer','U') is not null
truncate table oltp.Customer



	-- Create ---
-- drop table Oltp.Customer
create table Oltp.Customer
(
CustomerGUID UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID(),
CustomerSourceID int, 
CustomerName nvarchar(250), 
MaskedCustomerAddress nvarchar(max),
MaskedPhoneNo varbinary(max),
MaskedEmail varbinary(max),
City nvarchar(50),
[State] nvarchar(50),
Country nvarchar(50),
Continent nvarchar(50),
Policy nvarchar(max),
TaxTariff decimal(5,2),
LoadDate Datetime default getdate()
constraint Oltp_Customer_CustomerSourceID primary key(CustomerGUID)
)


--==================================
--Updated to check the error in SSIS
--==================================

create table Oltp.Customer
(
CustomerSourceID int, 
CustomerFirstName nvarchar(250), 
CustomerLastName nvarchar(250), 
CustomerAddress nvarchar(max),
City nvarchar(50),
[State] nvarchar(50),
Country nvarchar(50),
Continent nvarchar(50),
Policy nvarchar(max),
TaxTariff decimal(5,2),
LoadDate Datetime default getdate()
constraint Oltp_Customer_CustomerSourceID primary key(CustomerSourceID)
)
--Check

Select * From oltp.Customer

--=========================================================

-- Check ---

select CustomerSourceID, CustomerName, MaskedCustomerAddress, MaskedPhoneNo,MaskedEmail, City, [State], Country, Continent, Policy, TaxTariff, LoadDate
from Oltp.Customer

	-- Count ---

select count(*) StageCount
from Oltp.Customer

--ingest staged data into EDW

use [Inova_EDW]
-- Create ---

-- drop table Edw.DimCustomer
create table Edw.DimCustomer
(
CustomerKey dentity (1,1) int not null,
CustomerSourceID int, 
CustomerName nvarchar(250), 
MaskedCustomerAddress nvarchar(max),
MaskedPhoneNo varbinary(max),
MaskedEmail varbinary(max),
City nvarchar(50),
[State] nvarchar(50),
Country nvarchar(50),
Continent nvarchar(50),
Policy nvarchar(max),
TaxTariff decimal(5,2),
EffectiveStartDate Datetime,
constraint PK_Edw_Customer_CustomerKey primary key(CustomerKey)
)

	-- Check ---

select CustomerKey, CustomerSourceID, CustomerName, MaskedCustomerAddress, MaskedPhoneNo,MaskedEmail, City,
[State], Country, Continent, [Policy], TaxTariff, EffectiveStartDate
from edw.DimCustomer


	-- Count ---

select count(*) EdwCount
from edw.DimCustomer

--===Dimension [table] Plant  ======
--3) Plant

--extract the data

	-- Check ---
use Inova_OLTP


select PlantID as PlantSourceID, PlantName, PlantCapacity, PlantAddress, ct.City,st.State,cy.Country,cy.Continent
from Plant as P
inner join city as ct on ct.CityID= P.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID




	-- Count ---

select count(*) OltpCount
from Plant as P
inner join city as ct on ct.CityID= P.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID





--load into staging 


	-- Truncate ---
	use Inova_Staging

If OBJECT_ID('Plant','U') is not null
truncate table Plant

	-- Create ---
--drop table Oltp.plant
CREATE TABLE Oltp.Plant
(

PlantSourceID int, 
PlantName nvarchar(50) NOT NULL, 
PlantCapacity int NOT NULL, 
PlantAddress nvarchar(250) NOT NULL, 
City nvarchar(50) NOT NULL,
State nvarchar(50), 
Country nvarchar(50),
Continent nvarchar(50),
LoadDate Datetime DEFAULT GETDATE(),
CONSTRAINT Staging_Plant_PlantSourceID PRIMARY KEY (PlantSourceID)
)


	-- Check ---

select PlantSourceID, PlantName, PlantCapacity, PlantAddress, City,[State], Country,Continent, LoadDate
from Oltp.Plant

	-- Count ---
select count(*) StageCount
from Oltp.Plant

--ingest staged data into EDW

use [Inova_EDW]
	-- Create ---
-- drop table Edw.DimPlant
create table Edw.DimPlant
(
PlantKey int identity(1,1),
PlantSourceID int , 
PlantName nvarchar(50), -- SCD type 2
PlantCapacity int, 
PlantAddress nvarchar(250), 
City nvarchar(50),
[State] nvarchar(50), 
Country nvarchar(50),
Continent nvarchar(50),
EffectiveStartDate Datetime,
EffectiveEndDate Datetime,
Constraint Edw_Plant_PlantKey primary key(PlantKey)
)

	-- Check ---

Select PlantKey, PlantSourceID, PlantName, PlantCapacity, PlantAddress, City, [State], Country, Continent,EffectiveStartDate,EffectiveEndDate
from edw.DimPlant

	-- Count ---
Select count(*) EdwCount
from edw.DimPlant

--===Dimension [table] Warehouse  ======
--4) Warehouse

--Extract the data
use Inova_OLTP

select w.WarehouseID, w.WarehouseName, w.WarehouseCapacity, left(w.WarehouseAddress,charindex(',',w.WarehouseAddress)-1) as WarehouseAddress,
ct.City,st.State,cy.Country,cy.Continent
from Warehouse as W
inner join city as ct on ct.CityID= W.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID

--OlptCount

select count(*) OltpCount
from Warehouse as W
inner join city as ct on ct.CityID= W.CityID
inner join State as st on st.StateID=ct.StateID
inner join Country as cy on cy.CountryID=st.CountryID

--Load into staging
use [Inova_STAGING]
	
-- Truncate --
--select * from sys.all_objects where type='V'

If object_id('Oltp.Warehouse','U') is not null 
truncate table Oltp.Warehouse

-- Create --
--Drop Table Oltp.Warehouse
create table Oltp.Warehouse
(
WarehouseSourceID int not null,
WarehouseName nvarchar(250) not null,
WarehouseCapacity int not null,
WarehouseAddress nvarchar(250) not null,
City nvarchar(50) not null,
[State] nvarchar(50) not null,
Country nvarchar(50) not null,
Continent nvarchar(50) not null,
LoadDate datetime default getdate(),
Constraint Pk_Staging_Warehouse_WarehouseSourceID primary key(WarehouseSourceID)
)


-- Check ---
select WarehouseSourceID, WarehouseName, WarehouseCapacity, WarehouseAddress, City, [State], Country, Continent, LoadDate
from Oltp.Warehouse


-- Count ---
select count(*) StageCount
from Oltp.Warehouse



--Ingest staged data into EDW

use [Inova_EDW]
-- Create --
	
-- drop table Edw.Warehouse
create table Edw.DimWarehouse
(
WarehouseKey int identity(1,1) not null,
WarehouseSourceID int,
WarehouseName nvarchar(250) not null,--SCD type 2
WarehouseCapacity int not null,
WarehouseAddress nvarchar(250) not null,
City nvarchar(50) not null,
[State] nvarchar(50) not null,
Country nvarchar(50) not null,
Continent nvarchar(50) not null,
EffectiveStartDate datetime,
EffectiveEndDate datetime,
Constraint Pk_Edw_Warehouse_WarehouseKey primary key(WarehouseKey)
)

-- Check ---

select WarehouseKey, WarehouseSourceID, WarehouseName, WarehouseCapacity, WarehouseAddress, City, [State], Country, Continent, EffectiveStartDate,EffectiveEndDate
from Edw.DimWarehouse

-- Count ---

select count(*) EdwCount
from Edw.DimWarehouse


--===Dimension [table] QualityStatus  ======
--5) QualityStatus

use [Inova_OLTP]
--extract the data

	-- Check ---

select Qs.QualityStatusID, Qs.QualityStatus, D.Deficiency
from QualityStatus Qs
inner join Deficiency D on D.DeficiencyID = Qs.DeficiencyID

-- Count ---

select count(*) OltpCount
from QualityStatus Qs
inner join Deficiency D on D.DeficiencyID = Qs.DeficiencyID

--load into staging 
use [Inova_STAGING]

-- Truncate ---
if OBJECT_ID('oltp.QualityStatus','U') is not null 
truncate table oltp.QualityStatus

	-- Create ---
--drop table Oltp.QualityStatus
create table Oltp.QualityStatus
(
QualityStatusSourceID int,
QualityStatus bit,
Deficiency nvarchar(50),
LoadDate datetime default getdate(),
Constraint Oltp_QualityStatus_QualityStatusSourceID_Pk primary key (QualityStatusSourceID)
)

-- Check ---

select QualityStatusSourceID, QualityStatus, Deficiency, LoadDate
from Oltp.QualityStatus


-- Count ---
		
select count(*) StageCount
from Oltp.QualityStatus


--ingest staged data into EDW

use [Inova_EDW]

-- Create ---
-- drop table Edw.QualityStatus
create table Edw.DimQualityStatus
(
QualityStatusKey int identity(1,1),
QualityStatusSourceID int,
QualityStatus bit, -- SCD type 2
Deficiency nvarchar(50),
EffectiveStartDate Datetime,
EffectiveEndDate Datetime,
Constraint Edw_QualityStatus_QualityStatusKey_Pk primary key (QualityStatusKey)
)

-- Check ---

select QualityStatusKey, QualityStatusSourceID, QualityStatus, Deficiency, EffectiveStartDate,EffectiveEndDate
from Edw.DimQualityStatus

-- Count ---

select count(*) EdwCount
from Edw.DimQualityStatus

--===Dimension [table] Batch  ======
--6) Batch
use [Inova_OLTP]
--extract the data

-- Check ---
select BatchID, BatchName
from Batch

-- Count ---
select count(*) OltpCount
from Batch

--load into staging 

use [Inova_STAGING]

-- Truncate ---
if OBJECT_ID('oltp.Batch', 'U') is not null
truncate table Oltp.Batch


-- Create ---
--drop table Oltp.Batch
create table Oltp.Batch
(
BatchSourceID int,
BatchName nvarchar(50), -- SCD type 1
LoadDate datetime,
constraint Oltp_Batch_BatchSourceID primary key (BatchSourceID)
)

-- Check ---

select BatchSourceID, BatchName, LoadDate 
from Oltp.Batch

-- Count ---
select count(*) StageCount
from Oltp.Batch

--ingest staged data into EDW
use [Inova_EDW]

-- Create ---
--drop table Edw.DimBatch
create table Edw.DimBatch
(
BatchKey int identity(1,1),
BatchSourceID int,
BatchName nvarchar(50),--scd type 1
EffectiveStartDate datetime,
constraint edw_Batch_BatchKey_Pk primary key (BatchKey)
)

-- Check ---

select BatchKey, BatchSourceID, BatchName, EffectiveStartDate
from edw.DimBatch


-- Count ---

select count(*) EdwCount
from edw.DimBatch

--===Dimension [table] Employee  ======
--7) Employee

--extract the data
use [Inova_OLTP]
	-- Check ---

select E.EmployeeID, concat(upper(E.EmployeeLastName),',', E.EmployeeFirstName) as EmployeeName,
IsSupervisor=case when E.SupervisorID=1 then 'Yes'
			else 'No'
		end,
E.Position, D.Department
from Employee E
inner join Department D on D.DepartmentID=E.DepartmentID

-- Count ---
select count(*) OltpCount
from Employee E
inner join Department D on D.DepartmentID=E.DepartmentID

--load into staging 

use [Inova_STAGING]
-- Truncate ---

If OBJECT_ID('oltp.Employee', 'U') is not null
truncate table Oltp.employee

-- Create ---
-- drop table Oltp.Employee
create table Oltp.Employee
(
EmployeeSourceID int,
EmployeeName nvarchar(250), 
IsSupervisor nvarchar(3), 
Position nvarchar(50), 
Department nvarchar(50),
LoadDate Datetime default getdate(),
constraint Oltp_Employee_EmployeeSourceID_Pk primary key(EmployeeSourceID)
)

-- Check ---

select EmployeeSourceID,EmployeeName, IsSupervisor, Position, Department, LoadDate
from Oltp.Employee

-- Count ---

select count(*) StageCount
from Oltp.Employee

--ingest staged data into EDW

use [Inova_EDW]

-- Create ---
-- drop table Edw.DimEmployee
create table Edw.DimEmployee
(
EmployeeKey int identity(1,1),
EmployeeSourceID int ,
EmployeeName nvarchar(250), 
IsSupervisor nvarchar(3), 
Position nvarchar(50), 
Department nvarchar(50),
EffectiveStartDate Datetime,
EffectiveEndDate Datetime,
constraint Edw_Employee_Employeekey_Pk primary key(EmployeeKey)
)

-- Check ---

select EmployeeKey, EmployeeSourceID, EmployeeName, IsSupervisor, Position, Department, EffectiveStartDate,EffectiveEndDate
from Edw.DimEmployee

-- Count ---

select count(*) EdwCount
from Edw.DimEmployee

--8) DeliveryStatus

--extract the data
use [Inova_OLTP]

-- Check ---
select DeliveryStatusID, DeliveryStatus,Reason,AttemptNo
from DeliveryStatus

-- Count ---
select count(*) OltpCount
from DeliveryStatus

--load into staging 

use [Inova_STAGING]

-- Truncate ---
if OBJECT_ID('oltp.DeliveryStatus', 'U') is not null
truncate table Oltp.DeliveryStatus


-- Create ---
-- drop table Oltp.DeliveryStatus
create table Oltp.DeliveryStatus
(
DeliveryStatusSourceID int, 
DeliveryStatus nvarchar(50),
Reason nvarchar(max),
AttemptNo int,
LoadDate datetime default getdate(),
constraint Oltp_DeliveryStatus_DeliveryStatusID primary key (DeliveryStatusSourceID)
)

-- Check ---

select DeliveryStatusSourceID, DeliveryStatus, Reason, AttemptNo, LoadDate
from Oltp.DeliveryStatus

-- Count ---
select count(*) StageCount
from Oltp.DeliveryStatus

--ingest staged data into EDW

use [Inova_EDW]
-- Create ---
-- drop table Edw.DimDeliveryStatus

create table Edw.DimDeliveryStatus
(
DeliveryStatusKey int identity(1,1),
DeliveryStatusSourceID int, 
DeliveryStatus nvarchar(50),
Reason nvarchar(max),
AttemptNo int,
EffectiveStartDate Datetime,
EffectiveEndDate Datetime,
constraint Edw_DeliveryStatus_DeliveryStatusKey primary key (DeliveryStatusKey)
)
-- Check ---

select DeliveryStatusKey, DeliveryStatusSourceID, DeliveryStatus, Reason, AttemptNo, EffectiveStartDate, EffectiveEndDate
from Edw.DimDeliveryStatus


-- Count ---

select count(*) EdwCount
from Edw.DimDeliveryStatus

--9) Time
--ingest staged data into EDW

use [Inova_EDW]

-- Create ---
-- drop table Edw.DimTime
create table Edw.DimTime
(
BusinessTimeKey int identity(1,1),
BusinessHour int,
BusinessDayPeriod nvarchar(50), --Type 1
EffectiveStartDate DateTime,
constraint Edw_DimTime_Time_TimeKey primary key (BusinessTimeKey)
)


-- Check ---
--sp: default storeed procedure
--usp: user storeed procedure
	
Create or alter procedure Edw.uspDimTime as
Begin
set nocount on
		
declare @HourCount int = 0
		
If (select count(*) from Edw.dimTime)>0
truncate table Edw.dimTime

while @HourCount <= 23 
	Begin
		Insert into Edw.dimTime(BusinessHour, BusinessDayPeriod,EffectiveStartDate)
		Values
		(
		@HourCount,
		case
			when @HourCount >= 0 and @HourCount <= 3	then 'Midnight'
			when @HourCount>3 and @HOurCount <= 11 then 'Morning'
			when @HourCount = 12 then 'Noon'
			when @HourCount > 12 and @HourCount <= 16 then 'Afternoon'
			when @HourCount > 16 and @HourCount <= 20 then 'Evening'
			when @HourCount > 20 and @HourCount <= 23 then 'Night'
		End,
		getdate() 
		)

		select @HourCount = @HourCount+1
	End
End
		
--populate DimTime with stored procedure
execute Edw.uspDimTime

--10) Date

select convert(nvarchar(8),getdate(),112) as BusinessDateKey,
TRY_CAST(getdate() as date) as BusinessDate, year(getdate()) as BusinessYear,month(getdate()) as BusinessMonth, day(getdate()) as BusinessDay,
concat('Q',datepart(QUARTER,getdate())) as BusinessQuarter,
datepart(WEEK,getdate()) as BusinessWeekofYear,left(datename(month,getdate()),3) as BusinessEnglishMonth,left(datename(WEEKDAY,getdate()),3) as BusinessWeekDay


use [Inova_EDW]

--ingest staged data into EDW

-- Create ---
			
--drop table Edw.DimDate
Create table Edw.DimDate
(
BusinessDateKey int, 
BusinessDate Date,
BusinessYear int,
BusinessMonth int,
BusinessDay int,
BusinessQuarter nvarchar(2), 
BusinessWeekofYear int,
BusinessEnglishMonth nvarchar(3),
BusinessWeekDay nvarchar(3),
EffectiveStartDate datetime
constraint Edw_dim_Date_DateKey primary key (BusinessDateKey)
)

-- Build the DimDate Stored Procedure ---
CREATE OR ALTER PROCEDURE Edw.uspDimDate
@EndDate DATE = NULL, 
@YearInterval INT = NULL
AS
BEGIN
SET NOCOUNT ON;

DECLARE @StartDate DATE = (SELECT MIN(ProductionStartDateTime) FROM [Inova_OLTP].[dbo].[Production]);
    
-- If neither @EndDate nor @YearInterval is provided, default to 40 years
IF @EndDate IS NULL AND @YearInterval IS NULL
    SET @YearInterval = 40;
    
-- If @EndDate is not provided, calculate it based on @YearInterval
IF @EndDate IS NULL
    SET @EndDate = DATEADD(YEAR, @YearInterval, @StartDate);
    
-- If @EndDate is provided, use it as is

DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO Edw.DimDate (
        BusinessDateKey, BusinessDate, BusinessYear, BusinessMonth, BusinessDay,
        BusinessQuarter, BusinessWeekofYear, BusinessEnglishMonth, BusinessWeekDay,
        EffectiveStartDate
    )
    VALUES (
        CAST(FORMAT(@CurrentDate, 'yyyyMMdd') AS INT),
        @CurrentDate,
        YEAR(@CurrentDate),
        MONTH(@CurrentDate),
        DAY(@CurrentDate),
        'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS NVARCHAR(1)),
        DATEPART(WEEK, @CurrentDate),
        LEFT(DATENAME(MONTH, @CurrentDate), 3),
        LEFT(DATENAME(WEEKDAY, @CurrentDate), 3),
        GETDATE()
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

END;


-- Populate with default 40 years
EXEC Edw.uspDimDate;

--# Fact Tables: Shift, OverTime, Allowance, Inventory, Production, Sales, and Logistics
/*

Business Case: 
1. Employee Analytics: Shift, OverTime, Allowance
2. Inventory
3. Production
4. Sales
5. Logistics

*/

--=== 1) Shift Fact Table  ======

use [Inova_OLTP]

if (select count(*) from [Inova_EDW].edw.FactShift) = 0
begin
	--From the beginning to current date (Full Loading)
	select ShiftID, EmployeeID,ShiftName as ShiftDayPeriod,convert(date,ShiftStartDateTime) as ShiftStartDate,
		datepart(hour,ShiftStartDateTime) as ShiftStartHour,convert(date,ShiftEndDateTime) as ShiftEndDate,
		datepart(hour,ShiftEndDateTime) as ShiftEndHour, getdate() as Loaddate
	from [dbo].[Shift]
	where convert(date,ShiftStartDateTime) <= dateadd(day,-1,convert(date,getdate()))
end

else

begin
	--For N-1 (Incremental Loading)
	select ShiftID, EmployeeID,ShiftName as ShiftDayPeriod,convert(date,ShiftStartDateTime) as ShiftStartDate,
		datepart(hour,ShiftStartDateTime) as ShiftStartHour,convert(date,ShiftEndDateTime) as ShiftEndDate,
		datepart(hour,ShiftEndDateTime) as ShiftEndHour, getdate() as Loaddate
	from [dbo].[Shift]
	where convert(date,ShiftStartDateTime) = dateadd(day,-1,convert(date,getdate()))
end

--Oltp Count
if (select count(*) from [Inova_EDW].edw.FactShift) = 0
begin
	--From the beginning to current date (Full Loading)
	select count(*) as OltpCount
	from [dbo].[Shift]
	where convert(date,ShiftStartDateTime) <= dateadd(day,-1,convert(date,getdate()))
end

else

begin
	--For N-1 (Incremental Loading)
	select count(*) as OltpCount
	from [dbo].[Shift]
	where convert(date,ShiftStartDateTime) = dateadd(day,-1,convert(date,getdate()))
end

--Loading into Staging
use [Inova_STAGING]

-- Truncate ---
if OBJECT_ID('oltp.Shift', 'U') is not null
truncate table Oltp.Shift


-- Create ---
-- drop table Oltp.Shift
create table Oltp.Shift
(
ShiftSourceID int, 
EmployeeID int,
ShiftDayPeriod nvarchar(50),
ShiftStartDate date,
ShiftStartHour int,
ShiftEndDate date,
ShiftEndHour int,
LoadDate datetime default getdate(),
constraint Oltp_Shift_ShiftID primary key (ShiftSourceID)
)

--checking
Select ShiftSourceID,EmployeeID,ShiftDayPeriod,ShiftStartDate,ShiftStartHour,ShiftEndDate,ShiftEndHour,LoadDate from oltp.Shift

--StageCount
Select count(*) as StageCount
from oltp.Shift

--Loading into EDW

use [Inova_EDW]

-- drop table Edw.FactShift
create table Edw.FactShift
(
ShiftKey int,
ShiftSourceID int, 
EmployeeKey int,
ShiftDayPeriod nvarchar(50),
ShiftStartDateKey int,
ShiftStartHourKey int,
ShiftEndDateKey int,
ShiftEndHourKey int,
EffectiveStartDate datetime default getdate(),
constraint edw_FactShift_ShiftKey primary key (ShiftKey),
constraint edw_FactShift_EmployeeKey foreign key (EmployeeKey) references [edw].[DimEmployee](EmployeeKey),
constraint edw_FactShift_ShiftStartDateKey foreign key (ShiftStartDateKey) references [edw].[DimDate](BusinessDateKey),
constraint edw_FactShift_ShiftEndDateKey foreign key (ShiftEndDateKey) references [edw].[DimDate](BusinessDateKey),
constraint edw_FactShift_ShiftStartHourKey foreign key (ShiftStartHourKey) references [edw].[DimTime](BusinessTimeKey),
constraint edw_FactShift_ShiftEndHourKey foreign key (ShiftEndHourKey) references [edw].[DimTime](BusinessTimeKey)
)

--checking
select ShiftKey,ShiftSourceID,EmployeeKey,ShiftDayPeriod,
ShiftStartDatekey,ShiftStartHourkey,ShiftStartDatekey,ShiftStartHourkey 
from edw.FactShift

--==========================================
--			Sales Fact Table
--==========================================

use [Inova_OLTP]

IF (Select Count(*) from [Inova_EDW].Edw.FactSales)=0

    --- From the beginning to Full Load
	BEGIN
	Select SalesOrderID,ProductId,QuantitySold,convert(date,OrderDate) as OrderDate,
	DatePart(Hour,OrderDate) as OrderHour,Deposit, Convert(Date,TransactionDate) as TransactionDate,
	DatePart(Hour,TransactionDate) TransactionHour,PaymentMethod,TotalAmount,Tax,Discount,WarehouseID,EmployeeID,CustomerID 
	From [dbo].[Sales]
	where convert(date,OrderDate) <= dateadd(day,-1,convert(date,getdate()))
	END
ELSE

    --For N-1 (Incremental Loading) --
BEGIN
	Select SalesOrderID,ProductId,QuantitySold,convert(date,OrderDate) as OrderDate,
	DatePart(Hour,OrderDate) as OrderHour,Deposit, Convert(Date,TransactionDate) as TransactionDate,
	DatePart(Hour,TransactionDate) TransactionHour,PaymentMethod,TotalAmount,Tax,Discount,WarehouseID,EmployeeID,CustomerID 
	From [dbo].[Sales]
	where convert(date,OrderDate) = dateadd(day,-1,convert(date,getdate()))
END

---OLTP Count----	

IF (select count(*) from [Inova_EDW].edw.FactSales) = 0
BEGIN
	--From the beginning to current date (Full Loading)
	select count(*) as OltpCount
	from [dbo].[Sales]
	where convert(date,OrderDate) <= dateadd(day,-1,convert(date,getdate()))
END

ELSE

BEGIN
	--For N-1 (Incremental Loading)
	select count(*) as OltpCount
	from [dbo].[Sales]
	where convert(date,OrderDate) = dateadd(day,-1,convert(date,getdate()))
END


---Loading into Staging---

use [Inova_Staging]

----Truncate-----
IF OBJECT_ID('oltp.Sales', 'U') is not null
Truncate table Oltp.Sales

--==== Create Sales Table ====

-- Drop table Oltp.Sales
Create table Oltp.Sales
(
SalesSourceID int, 
ProductID int NOT NULL,
QuantitySold int NULL,
OrderDate Date NULL,
OrderHour int Null,
Deposit Decimal (10,2) Null,
TransactionDate Date Not Null,
TransactionHour int Not Null,
PaymentMethod Float Null,
TotalAmount Float Null,
Tax Float Null,
Discount Float Null,
WareHouseID int Not Null,
EmployeeID int Not Null,
CustomerID int Not Null,
LoadDate datetime default getdate(),
constraint Oltp_Sales_SalesID primary key (SalesSourceID)
)

---Checking---

Select SalesSourceID,ProductID,QuantitySold,OrderDate,OrderHour,Deposit,TransactionDate,TransactionHour,PaymentMethod,
TotalAmount,Tax,Discount,WarehouseID,EmployeeID,CustomerID,LoadDate 
From [oltp].[Sales]

---StageCount---
Select Count(*) As StageCount From [oltp].[Sales]

--===Load into EDW=====

use [Inova_EDW]

-- Drop table Edw.FactSales
create table Edw.FactSales
(
SalesKey int,
SalesSourceID int, 
ProductKey int NOT NULL,
QuantitySold int NULL,
OrderDateKey int NULL,
OrderHourKey int Null,
Deposit Decimal (10,2) Null,
TransactionDateKey int Not Null,
TransactionHourKey int Not Null,
PaymentMethod Float Null,
TotalAmount Float Null,
Tax Float Null,
Discount Float Null,
WareHouseKey int Not Null,
EmployeeKey int Not Null,
CustomerKey int Not Null,
LoadDate datetime default getdate(),

constraint EDW_FactSales_SalesKey primary key (SalesKey),
constraint EDW_FactSales_ProductKey Foreign key (ProductKey) references [edw].[DimProduct](ProductKey),
constraint EDW_FactSales_OrderDateKey Foreign key (OrderDateKey) references [edw].[DimDate](BusinessDateKey),
constraint EDW_FactSales_OrderHourKey Foreign key (OrderHourKey) references [edw].[DimTime](BusinessTimeKey),
constraint EDW_FactSales_TransactionDateKey Foreign key (TransactionDateKey) references [edw].[DimDate](BusinessDateKey),
constraint EDW_FactSales_TransactionHourHourKey Foreign key (TransactionHourKey) references [edw].[DimTime](BusinessTimeKey),
constraint EDW_FactSales_WarehouseKey Foreign key (WarehouseKey) references [edw].[DimWarehouse](WarehouseKey),
constraint edw_FactSales_EmployeeKey foreign key (EmployeeKey) references [edw].[DimEmployee](EmployeeKey),
constraint EDW_FactSales_CustomerKey Foreign key (CustomerKey) references [edw].[DimCustomer](CustomerKey)
)

---Checking---
Select SalesKey,SalesSourceID,ProductKey,QuantitySold,OrderDateKEy,OrderHourKey,Deposit,TransactionDateKey,TransactionHourKey,
PaymentMethod,TotalAmount,Tax,Discount,WarehouseKey,EmployeeKey,CustomerKey 
From  [edw].[FactSales]


---EDW Count---
Select count (*) as EDWCount From [edw].[FactSales]

--==========================================
--			Logistics Fact Table
--==========================================


USE [Inova_OLTP];

IF (SELECT COUNT(*) FROM Inova_EDW.EDW.Logistics) = 0
BEGIN
-- From the beginning to Full Load
SELECT  LogisticsSourceID,SalesOrderID, ProductID, PlantID, WarehouseID, EmployeeID, CustomerID,
        QuantityShippedIn, QuantityShippedOut, CONVERT(date, ShippingInDatetime) AS ShippingInDate,
		DATEPART(Hour, ShippingInDatetime) AS ShippingInHour,
        CONVERT(date, ShippingOutDatetime) AS ShippingOutDate,DATEPART(Hour,ShippingOutDatetime) AS ShippingOutHour, 
		DeliveryMethod, DeliveryStatusID,
        Convert(DATE,DeliveryDateTime) AS DeliveryDate,DATEPART(Hour,DeliveryDateTime) AS DeliveryHour, CONVERT(Date,ClosingDateTime) AS CclosingDate,
		DATEPART(Hour,ClosingDateTime) AS ClosingHour
FROM [dbo].[Logistics]
WHERE CONVERT(date, ShippingInDatetime) <= DATEADD(day, -1, CONVERT(date, GETDATE()))
END
ELSE
BEGIN
-- For N-1 (Incremental Loading)
SELECT  LogisticsSourceID,SalesOrderID, ProductID, PlantID, WarehouseID, EmployeeID, CustomerID,
        QuantityShippedIn, QuantityShippedOut, CONVERT(datetime, ShippingInDatetime) AS ShippingInDatetime,
        CONVERT(datetime, ShippingOutDatetime) AS ShippingOutDatetime, DeliveryMethod, DeliveryStatusID,
        DeliveryDateTime, ClosingDateTime
FROM [dbo].[Logistics]
WHERE CONVERT(date, ShippingInDatetime) = DATEADD(day, -1, CONVERT(date, GETDATE()))
END


--- OLTP Count ---
IF (SELECT COUNT(*) FROM [Inova_EDW].edw.FactLogistics) = 0
BEGIN
SELECT COUNT(*) AS OltpCount
FROM [dbo].[Logistics]
WHERE CONVERT(date, ShippingInDatetime) <= DATEADD(day, -1, CONVERT(date, GETDATE()))
END
ELSE
BEGIN
SELECT COUNT(*) AS OltpCount
FROM [dbo].[Logistics]
WHERE CONVERT(date, ShippingInDatetime) = DATEADD(day, -1, CONVERT(date, GETDATE()))
END
*/

--- Loading into Staging ---
USE [Inova_Staging];

--- Truncate ---
IF OBJECT_ID('oltp.Logistics', 'U') IS NOT NULL
TRUNCATE TABLE Oltp.Logistics;

--- Drop Table Oltp.Logistics

--- Create Logistics Table ---
CREATE TABLE Oltp.Logistics (
LogisticsSourceID int,
SalesOrderID int NOT NULL,
ProductID int NOT NULL,
PlantID int NOT NULL,
WarehouseID int NOT NULL,
EmployeeID int NOT NULL,
CustomerID int NOT NULL,
QuantityShippedIn int NOT NULL,
QuantityShippedOut int NOT NULL,
ShippingInDate date NOT NULL,
ShippingInHour int NOT NULL,
ShippingOutDate date NOT NULL,
ShippingOutHour int NOT NULL,
DeliveryMethod nvarchar(50) NOT NULL,
DeliveryStatusID int NOT NULL,
DeliveryDate date NULL,
DeliveryHour int Null,
ClosingDate date NULL,
ClosingHour int Null,
LoadDate datetime DEFAULT GETDATE(),
CONSTRAINT Oltp_Logistics_LogisticsID PRIMARY KEY (LogisticsSourceID))

--- Checking ---
SELECT LogisticsSourceID, SalesOrderID, ProductID, PlantID, WarehouseID, EmployeeID, CustomerID,
    QuantityShippedIn, QuantityShippedOut, ShippingInDate,ShippingInHour, ShippingOutDate,ShippingOutHour,DeliveryMethod,
    DeliveryStatusID, DeliveryDate,DeliveryHour, ClosingDate,ClosingHour, LoadDate
FROM   [oltp].[Logistics]

--- Stage Count ---
SELECT COUNT(*) AS StageCount
FROM [oltp].[Logistics]

--- Load into EDW ---
USE [Inova_EDW]

CREATE TABLE Edw.FactLogistics (
LogisticsKey int,
LogisticsSourceID int,
SalesOrderKey int NOT NULL,
ProductKey int NOT NULL,
PlantKey int NOT NULL,
WarehouseKey int NOT NULL,
EmployeeKey int NOT NULL,
CustomerKey int NOT NULL,
QuantityShippedInKey int NOT NULL,
QuantityShippedOutKey int NOT NULL,
ShippingInDateKey int NOT NULL,
ShippingInHourKey int NOT NULL,
ShippingOutDateKey int NOT NULL,
ShippingOutHourKey int NOT NULL,
DeliveryMethod nvarchar(50) NOT NULL,
DeliveryStatusKey int NOT NULL,
DeliveryDateKey int NULL,
DeliveryHourKey int Null,
ClosingDateKey int NULL,
ClosingHourKey int Null,
LoadDate datetime DEFAULT GETDATE(),
CONSTRAINT EDW_FactLogistics_LogisticsKey PRIMARY KEY (LogisticsKey),
CONSTRAINT EDW_FactLogistics_ProductKey FOREIGN KEY (ProductID) REFERENCES [edw].[DimProduct](ProductKey),
CONSTRAINT EDW_FactLogistics_PlantKey FOREIGN KEY (PlantID) REFERENCES [edw].[DimPlant](PlantKey),
CONSTRAINT EDW_FactLogistics_WarehouseKey FOREIGN KEY (WarehouseID) REFERENCES [edw].[DimWarehouse](WarehouseKey),
CONSTRAINT EDW_FactLogistics_EmployeeKey FOREIGN KEY (EmployeeID) REFERENCES [edw].[DimEmployee](EmployeeKey),
CONSTRAINT EDW_FactLogistics_CustomerKey FOREIGN KEY (CustomerID) REFERENCES [edw].[DimCustomer](CustomerKey),
CONSTRAINT EDW_FactLogistics_DeliveryStatusKey FOREIGN KEY (DeliveryStatusID) REFERENCES [edw].[DimDeliveryStatus](DeliveryStatusKey))


--- Checking ---
SELECT LogisticsKey, LogisticsSourceID, SalesOrderKey, ProductKey, PlantKey, WarehouseKey, EmployeeKey,
    CustomerKey, QuantityShippedInKey, QuantityShippedOutKey, ShippingInDateKey,ShippingInHourKey, ShippingOutDateKey,ShippingOutHourKey,
    DeliveryMethod, DeliveryStatusKey, DeliveryDateKey,DeliveryHourKey, ClosingDateKey,ClosingHourKey, LoadDate
FROM   [edw].[FactLogistics]

--- EDW Count ---
SELECT COUNT(*) AS EDWCount
FROM [edw].[FactLogistics]



