
--======
  SELECT  
      concat(UPPER(e.[EmployeeLastName]),', ',e.[EmployeeFirstName]) as EmployeeName
      ,IsSupervisor=case 
						when e.[SupervisorID]=-1 then 'Yes'
						else 'No'
					end
      ,e.[Position]
      ,format(a.[Amount],'c','en-US') as StaffAllowance,a.[AllowanceType]
      ,d.Department,a.[AllowanceDate],a.[Comment]
  FROM [Inova_OLTP].[dbo].[Employee] as e
  inner join [dbo].[Employee] as s on s.EmployeeID=e.EmployeeID
  inner join [dbo].[Department] as d on d.DepartmentID=e.DepartmentID
  inner join [dbo].[Allowance] as a on a.EmployeeID=e.EmployeeID
  where e.EmployeeID=33


---============================================================================
--The Finanace Manager want easily lookup for Employee while preparing payslip
--=============================================================================
CREATE or alter FUNCTION [dbo].[fn_EmployeeLookup] (@EMPID int)
RETURNS TABLE AS RETURN
(
  SELECT  
      concat(UPPER(e.[EmployeeLastName]),', ',e.[EmployeeFirstName]) as EmployeeName
      ,IsSupervisor=case 
						when e.[SupervisorID]=-1 then 'Yes'
						else 'No'
					end
      ,e.[Position]
      ,format(a.[Amount],'c','en-US') as StaffAllowance,a.[AllowanceType]
      ,d.Department,a.[AllowanceDate],a.[Comment]
  FROM [Inova_OLTP].[dbo].[Employee] as e
  inner join [dbo].[Employee] as s on s.EmployeeID=e.EmployeeID
  inner join [dbo].[Department] as d on d.DepartmentID=e.DepartmentID
  inner join [dbo].[Allowance] as a on a.EmployeeID=e.EmployeeID
  where e.EmployeeID=@EMPID
)


select * from [dbo].[fn_EmployeeLookup] (1)
/*
Num Shift (card)
*/

---=================
--Data Profiling
--================

/*
1. What is the revenue generated on ford explorer spare parts in Canada market
*/


select ModelName,format(sum(Revenue),'C','en-US') as TotalRevenue
from (
	select SalesOrderID, p.ProductID,pm.ModelName, (TotalAmount-Discount) as Revenue 
	from [dbo].[Sales] as s
	left join [dbo].[Product] as p on p.ProductID=s.ProductID
	left join [dbo].[ProductModel] as pm on pm.ProductModelID=p.ProductModelID
	where pm.ModelName='Explorer'
) as sb
group by ModelName

CREATE or alter FUNCTION [dbo].[fn_ProductModelLookup] (@ModelName nvarchar(50))
RETURNS TABLE AS RETURN
(
	select ModelName,format(sum(Revenue),'C','en-US') as TotalRevenue
	from (
		select SalesOrderID, p.ProductID,pm.ModelName, (TotalAmount-Discount) as Revenue 
		from [dbo].[Sales] as s
		left join [dbo].[Product] as p on p.ProductID=s.ProductID
		left join [dbo].[ProductModel] as pm on pm.ProductModelID=p.ProductModelID
		where pm.ModelName= @ModelName
	) as sb1
	group by ModelName
) 

--select * from [dbo].[ProductModel]

select * from [dbo].[fn_ProductModelLookup] ('Explorer')

/*
2. What is the most produce spare parts at Edmonton plant
*/

/*
select p.PlantName,c.City,pt.ProductName as PartName,pc.CategoryName as SparePart,sum(pd.Quantity) as SparePartTotalQuantity 
from [dbo].[Plant] as p
left join [dbo].[City] as c on c.CityID=p.CityID
left join [dbo].[Production] as pd on pd.PlantID=p.PlantID
left join [dbo].[Product] as pt on pt.ProductID=pd.ProductID
left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
where City='Edmonton'
group by pc.CategoryName, pt.ProductName,c.City,p.PlantName
order by sum(pd.Quantity) desc
*/

--SparePart
select pc.CategoryName as SparePart,sum(pd.Quantity) as SparePartTotalQuantity,
	DENSE_RANK() over (order by sum(pd.Quantity) desc) as SparePartRank
from [dbo].[Plant] as p
left join [dbo].[City] as c on c.CityID=p.CityID
left join [dbo].[Production] as pd on pd.PlantID=p.PlantID
left join [dbo].[Product] as pt on pt.ProductID=pd.ProductID
left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
where City='Edmonton'
group by pc.CategoryName

--Which part name in each sparepart
select pc.CategoryName as SparePart,pt.ProductName as PartName,sum(pd.Quantity) as SparePartTotalQuantity,
	DENSE_RANK() over (partition by pc.CategoryName order by sum(pd.Quantity) desc) as SparePartRank
from [dbo].[Plant] as p
left join [dbo].[City] as c on c.CityID=p.CityID
left join [dbo].[Production] as pd on pd.PlantID=p.PlantID
left join [dbo].[Product] as pt on pt.ProductID=pd.ProductID
left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
where City='Halifax'--'Edmonton'
group by pc.CategoryName,pt.ProductName

--In Edmonton Plant, where spare part is body, what the top 5 produce part name
select *
from
(
	select pc.CategoryName as SparePart,pt.ProductName as PartName,sum(pd.Quantity) as SparePartTotalQuantity,
		DENSE_RANK() over (partition by pc.CategoryName order by sum(pd.Quantity) desc) as SparePartRank
	from [dbo].[Plant] as p
	left join [dbo].[City] as c on c.CityID=p.CityID
	left join [dbo].[Production] as pd on pd.PlantID=p.PlantID
	left join [dbo].[Product] as pt on pt.ProductID=pd.ProductID
	left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
	where City='Halifax'--'Edmonton'
	and pc.CategoryName='Brakes'--'Body'
	group by pc.CategoryName,pt.ProductName
) as sb
where SparePartRank<=2

/*
rownumber()---1,2,3,4,5
rank()---1,2,2,4,5
dense_rank()--1,2,2,3,4--Top product
*/

/*
3. What is the highest demand spare parts in [2010] in African continent?
*/

select pc.CategoryName as SparePart,sum(s.QuantitySold) as SparePartTotalQuantity,
	DENSE_RANK() over (order by sum(s.QuantitySold) desc) as SparePartRank 
from [dbo].[Sales] as s
left join [dbo].[Product] as pt on pt.ProductID=s.ProductID
left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
left join [dbo].[Customer] as c on c.CustomerID=s.CustomerID
left join [dbo].[City] as ct on ct.CityID=c.CityID
left join [dbo].[State] as st on st.StateID=ct.StateID
left join [dbo].[Country] as cy on cy.CountryID=st.CountryID
where cy.Continent='Africa'
and year(s.TransactionDate) = '2010'
group by pc.CategoryName 

select *
from
(
	select pc.CategoryName as SparePart,sum(s.QuantitySold) as SparePartTotalQuantity,
		DENSE_RANK() over (order by sum(s.QuantitySold) desc) as SparePartRank 
	from [dbo].[Sales] as s
	left join [dbo].[Product] as pt on pt.ProductID=s.ProductID
	left join [dbo].[ProductCategory] as pc on pc.ProductCategoryID=pt.ProductCategoryID
	left join [dbo].[Customer] as c on c.CustomerID=s.CustomerID
	left join [dbo].[City] as ct on ct.CityID=c.CityID
	left join [dbo].[State] as st on st.StateID=ct.StateID
	left join [dbo].[Country] as cy on cy.CountryID=st.CountryID
	where cy.Continent='Africa'
	and year(s.TransactionDate) = '2010'
	group by pc.CategoryName 
) as sb
where SparePartRank=1

--4. What city across the world has the most demand for Ford Edge
select *
from
(
	select ct.City,cy.Country,sum(s.QuantitySold) as CarModelTotalQuantity,
		DENSE_RANK() over (order by sum(s.QuantitySold) desc) as CarModelRank 
	from [dbo].[Sales] as s
	left join [dbo].[Product] as pt on pt.ProductID=s.ProductID
	left join [dbo].[ProductModel] as pm on pm.ProductModelID=pt.ProductModelID
	left join [dbo].[Customer] as c on c.CustomerID=s.CustomerID
	left join [dbo].[City] as ct on ct.CityID=c.CityID
	left join [dbo].[State] as st on st.StateID=ct.StateID
	left join [dbo].[Country] as cy on cy.CountryID=st.CountryID
	where pm.ModelName='Edge'
	group by ct.City,cy.Country
) as sb
where CarModelRank <=1


--5. Which of the plant produce the highest capacities with less production employees
select pt.PlantName, count(p.EmployeeID), pt.PlantCapacity,p.Quantity,datediff(day,p.ProductionStartDateTime,p.ProductionEndDateTime)as productionHours
from Production as p
left join plant as pt on pt.PlantID=p.PlantID
left join Employee as e on e.EmployeeID=p.EmployeeID
group by PlantName


--To fix number of batches=5
select *
from Production as p
where Productid=130
and batchid=5

select PlantName,PlantCapacity
from plant
order by PlantCapacity desc

--===== School of Thought: Elvis ===============
select PlantName,PlantCapacity,TotalEmployees,RankPlantCapacity,Rankemployees
from
(
select pt.PlantName, pt.PlantCapacity, count(p.EmployeeID) as TotalEmployees,
	DENSE_RANK() over (order by pt.PlantCapacity desc) as RankPlantCapacity,
	DENSE_RANK() over (order by count(p.EmployeeID) asc) as Rankemployees
from Production as p
left join plant as pt on pt.PlantID=p.PlantID
left join Employee as e on e.EmployeeID=p.EmployeeID
group by PlantName, pt.PlantCapacity
) as sb
where Rankemployees<=3

--===== School of Thought: Adam===============
select pt.PlantName, pt.PlantCapacity, count(p.EmployeeID) as TotalEmployees
from Production as p
left join plant as pt on pt.PlantID=p.PlantID
left join Employee as e on e.EmployeeID=p.EmployeeID
group by PlantName, pt.PlantCapacity
order by pt.PlantCapacity desc, count(p.EmployeeID) asc


/*

Adama: highest capacity with less employee (Plant)
Motola: No of employeee (the plant with least employee with highest produce) (Plant, employee, produce)
Rahila: Type of plant which can make the most product with less employees (Plant, production, employee)

*/
--When QualityStaus is 1 , deficiencyID should NULL
--6. What is the percentage of product deficiencies, damage and high quality produce in 2012

--Total Produce in 2012 (Answer=377)
select count(deficiency) as TotalProduction2012
from Production as p
left join QualityStatus as q on q.QualityStatusID=p.QualityStatusID
left join Deficiency as d on d.DeficiencyID=q.DeficiencyID
where year(p.ProductionStartDateTime) = 2012

--Total deficient Produce in 2012 (Answer=225)
select count(deficiency) as TotalDeficiency2012
from Production as p
left join QualityStatus as q on q.QualityStatusID=p.QualityStatusID
left join Deficiency as d on d.DeficiencyID=q.DeficiencyID
where year(p.ProductionStartDateTime) = 2012
and q.QualityStatus=0 

--Total Quality Produce in 2012 (Answer=152)
select count(deficiency) as TotalQuality2012
from Production as p
left join QualityStatus as q on q.QualityStatusID=p.QualityStatusID
left join Deficiency as d on d.DeficiencyID=q.DeficiencyID
where year(p.ProductionStartDateTime) = 2012
and q.QualityStatus=1


--7. Which employee(s) engaged most in the production of Ford Edge over the years in each country
select concat(upper(e.EmployeeLastName),', ',e.EmployeeFirstName) as EmployeeName,c.Country,
	sum(datediff(day,p.ProductionStartDateTime,p.ProductionEndDateTime))as productionHours
from Production p
left join Product as pd on pd.ProductID=p.ProductID
left join ProductModel as pm on pm.ProductModelID=pd.ProductModelID
left join Employee as e on e.EmployeeID=p.EmployeeID
left join plant as pt on pt.PlantID=p.PlantID
left join city as ct on ct.CityID=pt.CityID
left join State as s on s.StateID=ct.StateID
left join Country as c on c.CountryID=s.CountryID
where pm.ModelName='Edge'
group by e.EmployeeLastName,e.EmployeeFirstName,c.Country
order by sum(datediff(day,p.ProductionStartDateTime,p.ProductionEndDateTime)) desc

--Other method
select EmployeeName,City, Country,Plant, sum(productionHours) as TotalHours
from
(
	select concat(upper(e.EmployeeLastName),', ',e.EmployeeFirstName) as EmployeeName,ct.City,c.Country,pt.PlantName as Plant,
		datediff(day,p.ProductionStartDateTime,p.ProductionEndDateTime) as productionHours
	from Production p
	left join Product as pd on pd.ProductID=p.ProductID
	left join ProductModel as pm on pm.ProductModelID=pd.ProductModelID
	left join Employee as e on e.EmployeeID=p.EmployeeID
	left join plant as pt on pt.PlantID=p.PlantID
	left join city as ct on ct.CityID=pt.CityID
	left join State as s on s.StateID=ct.StateID
	left join Country as c on c.CountryID=s.CountryID
	where pm.ModelName='Edge'
) as sb
group by EmployeeName,City,Country,Plant
order by sum(productionHours) desc

--8. What total quantity shipped out from Canada plants by road in 2015
select sum(QuantityShippedOut) as TotalQuantityShippedOutByRoadIn2015
from Logistics
where year(ShippingOutDatetime)=2015
and DeliveryMethod='Land'

CREATE FUNCTION [fn.TotalQuantityShippedOut](@NumYear int, @DeliveryMethod nvarchar(50))
RETURNS TABLE AS RETURN
(
	select sum(QuantityShippedOut) as TotalQuantityShippedOut
	from Logistics
	where year(ShippingOutDatetime)=@NumYear
	and DeliveryMethod=@DeliveryMethod
)


select * from [fn.TotalQuantityShippedOut] (2015,'Air')

--Remember to call Select one when using multiple Function calls
select * from [fn.TotalQuantityShippedOut] (2015,'Air') as ShipVisAir, 
	 [fn.TotalQuantityShippedOut] (2015,'Land') as ShipVisLand,
	 [fn.TotalQuantityShippedOut] (2015,'Sea') as ShipVisSea

--Other method to display more
select TotalQuantityShippedOut as ShipVisAir from [fn.TotalQuantityShippedOut] (2015,'Air')  
select TotalQuantityShippedOut as ShipVisLand from [fn.TotalQuantityShippedOut] (2015,'Land')
select TotalQuantityShippedOut as ShipVisSea from [fn.TotalQuantityShippedOut] (2015,'Sea')


--9. How much did the Nigeria and Democratic Republic of Congo parts purchase over the years
select cy.Country,format(sum(TotalAmount-Discount),'C','en-US') as TotalPurchase
from sales as s
left join Customer as c on c.CustomerID=s.CustomerID
left join city as ct on ct.CityID=c.CityID
left join State as st on st.StateID=ct.StateID
left join Country as cy on cy.CountryID=st.CountryID
where cy.Country in ('Nigeria','Congo DRC')
group by cy.Country


--Row-based storage
--Parquet (row-column storage | hybrid Storage
--row 1: 100, Augustina, lastname, age, Ghana







