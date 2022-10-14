/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

set statistics time, io on

Select   i.InvoiceID
		,c.CustomerName
		,i.InvoiceDate
		,il.Quantity*il.UnitPrice CurentSales
		,(Select Sum(il2.Quantity*il2.UnitPrice) SalesTotal
			From Sales.Invoices i2
			Inner Join Sales.InvoiceLines il2 ON i2.InvoiceID = il2.InvoiceID
			Where i2.InvoiceDate<=EOMONTH(i.InvoiceDate) AND i2.InvoiceDate>='20150101'
			) SalesTotal
From Sales.Invoices i
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Inner Join Sales.Customers c ON i.CustomerID = c.CustomerID
Where i.InvoiceDate>='20150101'
order by  i.InvoiceID, c.CustomerName, i.InvoiceDate

-- Время работы SQL Server:
--   Время ЦП = 36109 мс, затраченное время = 44585 мс.

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

Select   i.InvoiceID
		,c.CustomerName
		,i.InvoiceDate
		,il.Quantity*il.UnitPrice CurentSales
		,sum(il.Quantity*il.UnitPrice) over (Order By  year(i.InvoiceDate), month(i.InvoiceDate) ) SalesTotal
From Sales.Invoices i
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Inner Join Sales.Customers c ON i.CustomerID = c.CustomerID
Where i.InvoiceDate>='20150101'
order by  i.InvoiceDate

 --Время работы SQL Server:
 --  Время ЦП = 110 мс, затраченное время = 703 мс.

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;with Rating_1_StockCTE (StockItemName, montNumber, Quantity, place) AS
(
Select   si.StockItemName 
		,month(i.InvoiceDate) montNumber
		,sum(il.Quantity) Quantity
		,rank() over (partition by  month(i.InvoiceDate) Order By month(i.InvoiceDate), sum(il.Quantity) DESC) place
From Sales.Invoices i
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Inner Join Warehouse.StockItems si ON si.StockItemID = il.StockItemID
Where i.InvoiceDate>'20151201'	AND i.InvoiceDate<'20170101'	
Group By si.StockItemName 
		,month(i.InvoiceDate)
)
Select StockItemName
		,montNumber
From Rating_1_StockCTE 
Where place<3
Order By montNumber


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/


Select si.StockItemID
	  ,si.StockItemName
	  ,si.Brand
	  ,c.ColorName
	  ,si.TypicalWeightPerUnit
	  ,ROW_NUMBER() over(partition by Left(si.StockItemName,1) order by si.StockItemName) RowFirstSivol
	  ,COUNT(si.StockItemName) over() coutRows
	  ,COUNT(si.StockItemName) over(partition by Left(si.StockItemName,1) order by Left(si.StockItemName,1)) coutRowsFirstSivol
	  ,LEAD(si.StockItemID) over(order by si.StockItemName) NextID
	  ,LAG(si.StockItemID) over(order by si.StockItemName) PreviousID
	  ,LAG(si.StockItemName, 2, 'No items') over(order by si.StockItemName) PreviousFourStockItemName
	  ,NTILE(30) Over(Order By si.TypicalWeightPerUnit) GroupTypicalWeight_30
From Warehouse.StockItems si
Inner Join [Warehouse].[Colors] c ON si.ColorID = c.ColorID
Order By si.StockItemName



/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/


Select Top (1) with ties p.PersonID
	  ,p.FullName
	  ,c.CustomerID
	  ,c.CustomerName
	  ,i.InvoiceDate
	  ,ct.TransactionDate
	  ,ct.TransactionAmount
From Sales.CustomerTransactions ct 
Inner Join Sales.Invoices i ON i.InvoiceID = ct.InvoiceID
Inner Join Application.People p ON p.PersonID = i.SalespersonPersonID
Inner Join Sales.Customers c ON i.CustomerID = c.CustomerID
Order by ROW_NUMBER() over(Partition By p.PersonID Order by ct.TransactionDate DESC, c.CustomerID) 



/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;With RatingCustomerStockItem (CustomerName, CustomerID, StockItemID, UnitPrice, Pace) as
(
Select Distinct c.CustomerName
		,c.CustomerID
		,il.StockItemID
		,il.UnitPrice
		,dense_rank() over (Partition By c.CustomerID Order By il.UnitPrice DESC) Pace
From Sales.Invoices i
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Inner Join Sales.Customers c ON i.CustomerID = c.CustomerID
)Select  CustomerName
		,CustomerID
		,StockItemID
		,UnitPrice
From RatingCustomerStockItem
Where Pace<3
Order By CustomerName


;With RatingCustomerStockItem (CustomerName, CustomerID, StockItemID, UnitPrice, Pace) as
(
Select Distinct  c.CustomerName
		,c.CustomerID
		,il.StockItemID
		,il.UnitPrice
From Sales.Invoices i
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Inner Join Sales.Customers c ON i.CustomerID = c.CustomerID
Order by il.UnitPrice DESC
)Select  CustomerName
		,CustomerID
		,StockItemID
		,UnitPrice
From RatingCustomerStockItem
Where Pace<3
Order By CustomerName

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 