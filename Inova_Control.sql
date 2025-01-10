
--Create Schema
Use [Inova_Control]
Create Schema Control

--=========================================
--Create  Table For Data Control Framework
--=========================================

--===============
--Staging ==> EDW
--===============

--======================================
--      Create ENVIRONMENT Table
--======================================

Create Table Control.Environment
(
	EnvironmentID int,
	Environment nvarchar (255),
	Constraint Control_Environment_PK Primary Key(EnvironmentID)
)

Insert into Control.Environment(EnvironmentID,Environment)
Values
(1,'Staging'),
(2,'EDW')

--===========================
--Create PackageType Table
--===========================
Create Table.Control.PackageType
(
	PackageTypeID int,
	PackageType nvarchar(255),
	Constraint Control_PackageType_PK Primary Key (PackageTypeID)
)

Insert into Control.PackageType(PackageTypeID,PackageType)
Values
(1,'Dimension'),
(2,'Fact')

--===========================
--Create ControlPackage Table
--===========================

--Drop Table Control.Package
Create Table Control.Package
(
	PackageID int,
	PackageName nvarchar (50),
	SequenceID int, --e.g. stgStore.dtsx
	PackageTypeID int,  --1)Dimension  2)Fact
	EnvironmentID int,  --1)Staging    2)Edw
	StartDate date default getdate(),
	EndDate date,
	Active bit, --to pause/start data loading/running
	LastTruncate DateTime,
	LoadName nvarchar(250),
	Constraint Control_Package_pk Primary Key (PackageID),
	Constraint Control_Package_PackageType_fk Foreign Key(PackageTypeID) references Control.PackageType(PackageTypeID),
	Constraint Control_Package_Environment_fk Foreign Key(EnvironmentID) references Control.Environment(EnvironmentID),
	Constraint Control_Package_EndDate_ch Check(EndDate>=StartDate)
)

Select * From Control.Package
/*
--stgStore-->100
--stgProduct-->200
--stgPromotion-->300
--stgCustomer-->102
*/


--UPDATE Control.Package SET PackageName  = 'stg_Customer' WHERE PackageID = 3 ----Updated from stgCustomer
--UPDATE Control.Package SET PackageName  = 'stgPlant1' WHERE PackageID = 2 ----Updated from stgPlant


Insert into Control.Package(PackageID,PackageName,SequenceID,PackageTypeID,EnvironmentID,StartDate,EndDate,Active,LoadName)
Values
--(1,'stgProduct.dtsx',1000,1,1,GETDATE(),'2099-12-31',1,'Product')
--(2, 'stgPlant1.dtsx', 2000, 1, 1, GETDATE(), '2099-12-31', 1, 'Plant')
--(3, 'stg_Customer.dtsx', 3000, 1, 1, GETDATE(), '2099-12-31', 1, 'Customer')
--(4, 'stgWarehouse.dtsx', 4000, 1, 1, GETDATE(), '2099-12-31', 1, 'Warehouse')
--(5, 'stgQualityStatus.dtsx', 5000, 1, 1, GETDATE(), '2099-12-31', 1, 'QualityStatus')
--(6, 'stgBatch.dtsx', 6000, 1, 1, GETDATE(), '2099-12-31', 1, 'Batch')
(7, 'stgEmployee.dtsx', 7000, 1, 1, GETDATE(), '2099-12-31', 1, 'Employee')
(8, 'stgDeliveryStatus.dtsx', 8000, 1, 1, GETDATE(), '2099-12-31', 1, 'DeliveryStatus')
--Facts 
(9,'stgShift.dtsx', 9000, 2,1,Getdate(),'2090-12-21',1,'Shift')
(10,'stgOverTime.dtsx', 10000, 2,1,Getdate(),'2090-12-21',1,'OverTime')
(11,'stgAllowance.dtsx', 11000, 2,1,Getdate(),'2090-12-21',1,'Allowance')
(12,'stgInventory.dtsx', 12000, 2,1,Getdate(),'2090-12-21',1,'Inventory')
(13,'stgProduction.dtsx', 13000, 2,1,Getdate(),'2090-12-21',1,'Production')
(14,'stgSales.dtsx', 14000, 2,1,Getdate(),'2090-12-21',1,'Sales')
(15,'stgLogistics.dtsx', 15000, 2,1,Getdate(),'2090-12-21',1,'Logistics')

--===========================
-- Create Metric Table
--===========================
/*
Rules:

OltpCount=StageCount (Staging)
PostCount=CurrentCount+PreCount+Type2SCDCount (Edw: #Dimension)
PostCount=CurrentCount+PreCount (Edw: #Fact)

*/

--Drop Table Control.Metrics

Create Table Control.Metrics
(
    MetricsID int IDENTITY(1,1),
    PackageID int,
    OltpCount int,   --Num of data departing from the Source
    StageCount int,  --Num of data arriving to the Staging
    CurrentCount int,--Before moving data from Staging to Edw, what data currently exists in the Staging area
    PreCount int,    --What was in the warehouse before
    Type1Count int,  --This just adds new record (SCD1)
    Type2Count int,  --how many count of the records goes through Type2
    PostCount int,
    RunDate DATETIME,
    Constraint control_metrics_pk Primary Key (MetricsID),
	Constraint control_metrics_Package_fk Foreign Key (PackageID) References Control.Package(PackageID)
)



--=================================
-- Data metrics (Oltp ---> Staging)
--=================================
--Syntax to measure the product ETL Pipeline (Oltp to Staging)

Declare @OltpCount int = ?
Declare @StageCount int = ?
Declare @PackageID int = ?

Update Control.Package set LastTruncate=getdate() Where PackageID = @PackageID
Insert into Control.metrics(PackageID,OltpCount,StageCount,RunDate)
Values (@PackageID,@OltpCount,@StageCount,getdate())



--Checking 

--drop table. control.metrics

Select * From Control.Metrics


Select * From Control.Package







