--===========================================
---FINAL SOURCE TABLES
--==========================================


Use Inova_OLTP

--=======================================
--Location Related Entities: The Where
--======================================
--PK_CountryID_Country [Primary Key]
--FK_StateID_City [Foreign Key]

--# Country  #
--drop table Country 
Create Table Country
( 
	CountryID int Identity(1,1),
	Country nvarchar(50) NOT NULL,
	Continent nvarchar(50),
	Constraint  Country_pk primary key(CountryID)
)

--# State #----
--drop table [State] 
Create Table [State] 
(
	StateID int Identity(1,1),
	[State] nvarchar(50) NOT NULL,
	CountryID int NOT NULL,
	Constraint  State_pk primary key(StateID),
	Constraint  State_CountryID_fk foreign key(CountryID) references Country(CountryID)
)


--# City #----
--drop table City
Create Table City
(
	CityID int Identity(1,1),
	City nvarchar(50) NOT NULL,
	StateID int NOT NULL,
	Constraint  City_pk primary key(CityID),
	Constraint  City_StateID_fk foreign key(StateID) references State(StateID) 
)

--# Plant #----
--drop table Plant
create table Plant
(
	PlantID int Identity(1,1), 
	PlantName nvarchar(50) NOT NULL,
	PlantCapacity int NOT NULL,
	PlantAddress nvarchar(250) NOT NULL,
	CityID int NOT NULL,
	constraint Plant_Pk primary key(PlantID),
	constraint Plant_CityFk_City foreign key (CityID) references City(CityID)
)

--Alter table Plant
--swap column CityID with column PlantCapacity


---# Warehouse # ---
--drop table Warehouse
create table Warehouse
(
	WarehouseID int identity(1,1),
	WarehouseName nvarchar(50) NOT NULL,
	WarehouseCapacity int NOT NULL,
	WarehouseAddress nvarchar(250) NOT NULL,
	CityID int NOT NULL,
	constraint warehouse_pk primary key(WarehouseID),
	constraint warehouse_city_fk foreign key(CityID) references City(CityID)

)

--=====================================
--People Related Entities: The Who
--=====================================

 --- # Department #---
 --truncate table Department
 --drop table Department
Create Table Department
(
	DepartmentID int identity (1,1),
	Department nvarchar (50),
	Constraint  Department_Pk Primary Key (DepartmentID)
)

---# Employee #---
--drop table Employee
Create Table Employee
(
	EmployeeID int identity (1,1),
	EmployeeFirstName nvarchar (50) NOT NULL,
	EmployeeLastName nvarchar (50) NOT NULL,
	SupervisorID int,
	Position nvarchar (50),
	DepartmentID int,
	Constraint Employee_Pk Primary Key (EmployeeID),
	Constraint Employee_DepartmentFK_Deparment Foreign Key (DepartmentID) References Department(DepartmentID),
	Constraint Employee_SupervisorFK_Supervisor Foreign Key (SupervisorID) References Employee(EmployeeID)
)

--We have to drop the Allowance

--# Allowance #----
CREATE TABLE Allowance (
    AllowanceID INT IDENTITY(1,1),
    EmployeeID INT,
    AllowanceType NVARCHAR(50), -- Type of allowance (e.g., salary, training, annual bonus)
    Amount DECIMAL(10,2),
    AllowanceDate Datetime,
	Comment nvarchar(50), --always null; otherwise, sick or leave
	Constraint Allowance_Pk Primary Key (AllowanceID),
    CONSTRAINT FK_Allowance_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID) -- Foreign key constraint to Employee table
);

---- Optional: Create an index to optimize queries on EmployeeID
--CREATE INDEX IDX_EmployeeID ON Allowance(EmployeeID);


 ----# Shift #-----
 --drop Table [Shift]
 Create Table [Shift]
(
	ShiftID int identity (1,1),
	EmployeeID int NOT NULL,
	ShiftName nvarchar(50),
	ShiftStartDateTime DateTime NOT NULL,
	ShiftEndDateTime DateTime NOT NULL,
	Constraint Shift_Pk Primary Key (ShiftID),
	Constraint Shift_EmployeeFK_Employee Foreign Key (EmployeeID) References Employee (EmployeeID)
)

---# OverTime #----
--drop Table OverTime
Create Table OverTime
(
	OverTimeID int identity (1,1),
	EmployeeID int NOT NULL,
	OverTimeStartDateTime DateTime NOT NULL,
	OverTimeEndDateTime Datetime NOT NULL, 
	Constraint  OverTime_Pk Primary Key (OverTimeID),
	Constraint  OverTime_EmployeeFK_Employee Foreign Key (EmployeeID) References Employee (EmployeeID)
)

---# Customer #----
--drop Table Customer
Create Table Customer
(
	CustomerID int identity (1,1),
	CustomerFirstName nvarchar(50) NOT NULL, 
	CustomerLastName nvarchar(50) NOT NULL,
	CustomerCategory nvarchar(50) NOT NULL, ---Distributor (Address Inside Canada) /External (Address Outside Canada)
	CustomerAddress nvarchar(250) NOT NULL,
	BillingAddress nvarchar(250) NOT NULL,
	DeliveryAddress varchar (250) NOT NULL,
	PhoneNo NVARCHAR (50),
	Email NVARCHAR (250) NOT NULL,
	CityID INT NOT NULL,
	Constraint  Customer_PK Primary Key (CustomerID),
	Constraint  Customer_CityID_FK Foreign Key (CityID) References City(CityID)
)


--===================================
--Product Related Entities: The What
--====================================

--# ProductCategory #
Create Table ProductCategory
(
	ProductCategoryID int, 
	CategoryName nvarchar (50) NOT NULL,
	constraint ProductCategory_Pk primary key (ProductCategoryID)
)

--# ProductMake #
Create Table ProductMake
( 
	ProductMakeID int Identity(1,1),
	MakeName nvarchar (50) NOT NULL,
	constraint ProductMake_pk Primary Key (ProductMakeID)
)


--# ProductModel #
Create Table ProductModel
( 
	ProductModelID int Identity(1,1),
	ModelName nvarchar (50) NOT NULL,
	ModelStyle nvarchar(50),
	ModelYear int NOT NULL,
	ProductMakeID int NOT NULL,
	constraint ProductModel_Pk primary key (ProductModelID),
	constraint PorductModel_ProductMakeFK_ProduckMake Foreign key (ProductMakeID) references ProductMake (ProductMakeID)
)

--alter table productmodel
--add ModelStyle nvarchar(50)

--# Product #
--truncate table Product
Create Table Product
(
	ProductID int Identity(1,1),
	ProductName nvarchar (50) NOT NULL, 
	ProductDescription nvarchar (50),
	ProductWeight int NOT NULL,
	ProductLength int NOT NULL,
	ProductHeight int NOT NULL, 
	UnitPrice Float NOT NULL,
	ProductCategoryID int NOT NULL, 
	ProductModelID int NOT NULL,
	constraint Product_Pk primary key(ProductID),
	constraint Product_ProductCategoryFk_ProductCategory foreign key (ProductCategoryID) references ProductCategory(ProductCategoryID),
	constraint Product_ProductModelFk_ProductModel foreign key (ProductModelID) references ProductModel(ProductModelID)
)

--===========================
--Operation Related ENTITIES
--===========================

--# TaxTariff #---
--drop Table TaxTariff
Create Table TaxTariff
(
	TaxTariffID int Identity(1,1),
	TaxTariff decimal(5,2),
	Status nvarchar(50),
	CountryID int NOT NULL,
	Constraint  TaxTariff_pk primary key(TaxTariffID),
	Constraint  TaxTariff_CountryID_fk foreign key(CountryID) references Country(CountryID)
)

---Checkout tax tariff data type if it is int, nvarchar, or decimal
--it is decimal

--alter table TaxTariff
--alter column TaxTariff decimal(5,2)

--# Policy # ---
--drop table [Policy]
create table [Policy]
(
	PolicyID int identity(1,1), 
	[Policy] nvarchar(max),
	CountryID int NOT NULL,
	constraint policy_pk primary key(PolicyID),
	constraint policy_country_fk foreign key(CountryID) references Country(CountryID)
)


--# Batch # --
--drop table Batch
create table Batch
(
	BatchID int identity(1,1), 
	BatchName nvarchar(50) NOT NULL, --Data Quality Check
	constraint Bacth_Pk primary key(BatchID)
)

--# Deficiency # --
--drop table Deficiency
create table Deficiency
(
	DeficiencyID int identity(1,1), 
	Deficiency nvarchar(50) NOT NULL, --Data Quality Check
	constraint Deficiency_Pk primary key(DeficiencyID)
)

--# Quality Check # --
--drop table QualityStatus
create table QualityStatus
(
	QualityStatusID int identity(1,1),
	QualityStatus bit NOT NULL,---Yes/No
	DeficiencyID int,
	constraint QualityStatus_Pk primary key(QualityStatusID),
	constraint QualityStatusk_DeficiencyFk_Deficiency foreign key (DeficiencyID) references Deficiency(DeficiencyID)
)


--# Delivery Status #
Create Table DeliveryStatus
( 
	DeliveryStatusID int Identity(1,1),
	DeliveryStatus nvarchar (50) NOT NULL,
	Reason nvarchar(Max),
	AttemptNo int,
	constraint DeliveryStatus_pk Primary Key (DeliveryStatusID)
)

--# Inventory #
create table Inventory
(
	InventoryID int identity(1,1),
	ProductID int NOT NULL,
	WarehouseID int NOT NULL,
	QuantityOnHand int NOT NULL,
	ReorderLevel int,
	LastUpdated datetime,
	constraint Inventory_Pk primary key(InventoryID),
	constraint Inventory_ProductFk_Product foreign key (ProductID) references Product(ProductID),
	constraint Inventory_WarehouseFk_Warehouse foreign key (WarehouseID) references Warehouse(WarehouseID)
)

--===========================
--MAIN ENTITIES
--========================

--# Production #
--drop table Production
--truncate table Production
create table Production
(
	ProductionID int identity(1,1),
	ProductID int NOT NULL,
	PlantID int NOT NULL,
	ProductionStartDateTime datetime NOT NULL,
	ProductionEndDateTime datetime NOT NULL, 
	BatchID int NOT NULL, 
	QualityStatusID int NOT NULL,
	EmployeeID int NOT NULL, 
	Quantity int,
	constraint Production_Pk primary key(ProductionID),
	constraint Production_ProductFk_Product foreign key (ProductID) references Product(ProductID),
	constraint Production_EmployeeFk_Employee foreign key (EmployeeID) references Employee(EmployeeID),
	constraint Production_PlantFk_Plant foreign key (PlantID) references Plant(PlantID),
	constraint Production_BatchFk_Batch foreign key (BatchID) references Batch(BatchID),
	constraint Production_QualityStatusFk_QualityStatus foreign key (QualityStatusID) references QualityStatus(QualityStatusID)
)


---# Sales #------
--drop table Sales
create table Sales
(
	SalesOrderID int identity(1,1),
	ProductID int NOT NULL,
	QuantitySold int,
	OrderDate datetime,
	Deposit decimal(10,2),
	TransactionDate datetime NOT NULL,
	PaymentMethod nvarchar(50),
	TotalAmount float,
	Tax float,
	Discount float,
	WarehouseID int NOT NULL,
	EmployeeID int NOT NULL,
	CustomerID int NOT NULL,
	constraint sales_pk primary key(SalesOrderID),
	constraint sales_product_fk foreign key(ProductID) references Product(ProductID),
	constraint sales_warehouse_fk foreign key(WarehouseID) references Warehouse(WarehouseID),
	constraint sales_employee_fk foreign key(EmployeeID) references Employee(EmployeeID),
	constraint sales_customer_fk foreign key(CustomerID) references Customer(CustomerID)
)


--Alter table Sales Alter column Deposit decimal(10,2)

---# Logistics #------
--drop table logistics
create table Logistics
(
	LogisticsID int identity(1,1),
	SalesOrderID int NOT NULL,
	ProductID int NOT NULL,
	PlantID int NOT NULL,
	WarehouseID int NOT NULL,
	EmployeeID int NOT NULL,
	CustomerID int NOT NULL,
	QuantityShippedIn int NOT NULL,
	QuantityShippedOut int NOT NULL,
	ShippingInDatetime datetime NOT NULL,
	ShippingOutDatetime datetime NOT NULL,
	DeliveryMethod nvarchar(50) NOT NULL,
	DeliveryStatusID int NOT NULL,
	DeliveryDatetime datetime,
	ClosingDatetime datetime,
	constraint logistics_pk primary key(LogisticsID),
	constraint logistics_salesorder_fk foreign key (SalesOrderID) references Sales(SalesOrderID),
	constraint logistics_product_fk foreign key(ProductID) references Product(ProductID),
	constraint logistics_plant_fk foreign key(PlantID) references Plant(PlantID),
	constraint logistics_warehouse_fk foreign key(WarehouseID) references Warehouse(WarehouseID),
	constraint logistics_employee_fk foreign key(EmployeeID) references Employee(EmployeeID),
	constraint logistics_customer_fk foreign key(CustomerID) references Customer(CustomerID),
	constraint logistics_deliverystatus_fk foreign key(DeliveryStatusID) references DeliveryStatus(DeliveryStatusID)
)


