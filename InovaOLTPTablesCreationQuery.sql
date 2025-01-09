Use Inasa_OLTP

--=======================================
--Location Related Entities: The Where
--======================================

--# Country  #
--drop table Country 
Create Table Country
( 
	CountryID int,
	Country nvarchar(50) NOT NULL,
	Continent nvarchar(50),
	Constraint  Country_pk primary key(CountryID)
)

--# State #----
--drop table [State] 
Create Table [State] 
(
	StateID int,
	[State] nvarchar(50) NOT NULL,
	CountryID int NOT NULL,
	Constraint  State_pk primary key(StateID),
	Constraint  State_CountryID_fk foreign key(CountryID) references Country(CountryID)
)


--# City #----
--drop table City
Create Table City
(
	CityID int,
	City nvarchar(50) NOT NULL,
	StateID int NOT NULL,
	Constraint  City_pk primary key(CityID),
	Constraint  City_StateID_fk foreign key(StateID) references State(StateID) 
)

--# Plant #----
--drop table Plant
create table Plant
(
	PlantID int, 
	PlantName nvarchar(50) NOT NULL,
	PlantAddress nvarchar(250) NOT NULL,
	PlantCapacity int NOT NULL,
	CityID int NOT NULL,
	constraint Plant_Pk primary key(PlantID),
	constraint Plant_CityFk_City foreign key (CityID) references City(CityID)
)


---# Warehouse # ---
--drop table Warehouse
create table Warehouse
(
	WarehouseID int,
	WarehouseName nvarchar(50) NOT NULL,
	WarehouseAddress nvarchar(50) NOT NULL,
	WarehouseCapacity int NOT NULL,
	CityID int NOT NULL,
	constraint warehouse_pk primary key(WarehouseID),
	constraint warehouse_city_fk foreign key(CityID) references City(CityID)

)

--=====================================
--People Related Entities : The Who
--=====================================

 --- # Department #---
 --truncate table Department
 --drop table Department
Create Table Department
(
	DepartmentID int,
	Department nvarchar (50),
	Constraint  Department_Pk Primary Key (DepartmentID)
)

---# Employee #---
--drop table Employee
Create Table Employee
(
	EmployeeID int,
	EmployeeFirstName nvarchar (50) NOT NULL,
	EmployeeLastName nvarchar (50) NOT NULL,
	SupervisorID int,
	Position nvarchar (50),
	Allowance decimal(10,2) NOT NULL,
	DepartmentID int,
	Constraint Employee_Pk Primary Key (EmployeeID),
	Constraint Employee_DepartmentFK_Deparment Foreign Key (DepartmentID) References Department(DepartmentID),
	Constraint Employee_SupervisorFK_Supervisor Foreign Key (SupervisorID) References Employee(EmployeeID)
)

 ----# Shift #-----
 --drop Table [Shift]
 Create Table [Shift]
(
	ShiftID int,
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
	OverTimeID int,
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
	CustomerID int,
	CustomerFirstName nvarchar(50) NOT NULL, 
	CustomerLastName nvarchar(50) NOT NULL,
	CustomerCategory nvarchar(50) NOT NULL, ---Distributor (Address Inside Canada) /External (Address Outside Canada)
	CustomerAddress nvarchar(50) NOT NULL,
	BillingAddress nvarchar(50) NOT NULL,
	DeliveryAddress varchar ( 50 ) NOT NULL,
	PhoneNo NVARCHAR ( 50 ),
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
	ProductMakeID int,
	MakeName nvarchar (50) NOT NULL,
	constraint ProductMake_pk Primary Key (ProductMakeID)
)


--# ProductModel #
Create Table ProductModel
( 
	ProductModelID int,
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
Create Table Product
(
	ProductID int,
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
	TaxTariffID int,
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
	PolicyID int, 
	[Policy] nvarchar(max),
	CountryID int NOT NULL,
	constraint policy_pk primary key(PolicyID),
	constraint policy_country_fk foreign key(CountryID) references Country(CountryID)
)


--# Batch # --
--drop table Batch
create table Batch
(
	BatchID int, 
	BatchName nvarchar(50) NOT NULL, --Data Quality Check
	constraint Bacth_Pk primary key(BatchID)
)

--# Deficiency # --
--drop table Deficiency
create table Deficiency
(
	DeficiencyID int, 
	Deficiency nvarchar(50) NOT NULL, --Data Quality Check
	DeficienciesDescription nvarchar(50), 
	constraint Deficiency_Pk primary key(DeficiencyID)
)

--# Quality Check # --
--drop table QualityStatus
create table QualityStatus
(
	QualityStatusID int,
	QualityStatus bit NOT NULL,---Yes/No
	DeficiencyID int,
	constraint QualityStatus_Pk primary key(QualityStatusID),
	constraint QualityStatusk_DeficiencyFk_Deficiency foreign key (DeficiencyID) references Deficiency(DeficiencyID)
)


--# Delivery Status #
Create Table DeliveryStatus
( 
	DeliveryStatusID int,
	DeliveryStatus nvarchar (50) NOT NULL,
	DeliveryDatetime datetime NOT NULL,
	Reason nvarchar(Max),
	AttemptNo int,
	constraint DeliveryStatus_pk Primary Key (DeliveryStatusID)
)

--# Inventory #
create table Inventory
(
	InventoryID int,
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
create table Production
(
	ProductionID int,
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
	SalesOrderID int,
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
	LogisticsID int,
	SalesOrderID int NOT NULL,
	ProductID int NOT NULL,
	PlantID int NOT NULL,
	WarehouseID int NOT NULL,
	EmployeeID int NOT NULL,
	CustomerID int NOT NULL,
	QuantityShippedIn int NOT NULL,
	QuantityShippedOut int NOT NULL,
	ShippingOutDatetime datetime NOT NULL,
	ShippingInDatetime datetime NOT NULL,
	DeliveryMethod nvarchar(50) NOT NULL,
	DeliveryStatusID int NOT NULL,
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
