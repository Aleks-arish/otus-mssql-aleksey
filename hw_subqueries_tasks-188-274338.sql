/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

Select	 p.PersonID
		,p.FullName 
From Application.People p
Where Not Exists(Select * From Sales.Invoices s Where s.SalespersonPersonID = p.PersonID AND s.InvoiceDate = '20150704') AND p.IsSalesperson = 1

;With CTE_s (SalespersonPersonID) as
(
Select s.SalespersonPersonID 
From Sales.Invoices s 
Where  s.InvoiceDate = '20150704'
)
Select	 p.PersonID
		,p.FullName 
From Application.People p
Left Join CTE_s ON CTE_s.SalespersonPersonID = p.PersonID
Where p.IsSalesperson = 1 AND CTE_s.SalespersonPersonID IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

Select   si.StockItemID
		,si.[StockItemName]
		,si.UnitPrice
		,(Select MIN(UnitPrice) From [Warehouse].[StockItems] ) UnitPrice
From [Warehouse].[StockItems] si
Where si.UnitPrice <=ALL (Select UnitPrice From [Warehouse].[StockItems] )


;With CTE_min_price (UnitPrice) as
(
Select min(UnitPrice) UnitPrice From [Warehouse].[StockItems]
)
Select   si.StockItemID
		,si.[StockItemName]
		,CTE_min_price.UnitPrice 
From [Warehouse].[StockItems] si
Inner join CTE_min_price on si.UnitPrice  = CTE_min_price.UnitPrice 

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/


Select * From Sales.Customers c
Where c.CustomerID in(Select Top 5 [CustomerID]
From Sales.CustomerTransactions
Order By [TransactionAmount] DESC)

;With CTE_Top_5_Sales ([CustomerID]) as
(
Select Top 5 [CustomerID]
From Sales.CustomerTransactions
Order By [TransactionAmount] DESC
)
Select * From Sales.Customers c
Inner Join CTE_Top_5_Sales on c.[CustomerID] = CTE_Top_5_Sales.[CustomerID]


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/


Select	 (Select cit.CityName 
		  From Application.Cities cit 
		  Where cit.CityID = c.DeliveryCityID
		  ) CityName
		,c.DeliveryCityID 
		,(Select p.FullName 
		  From Application.People p 
		  Where p.PersonID = i.PackedByPersonID
		  ) PackedByPersonFullName
From Sales.Customers c
Inner Join Sales.Invoices i ON i.CustomerID = c.CustomerID
Inner Join Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
Where il.StockItemID in(Select Top 3 StockItemID From Warehouse.StockItems si Order By si.UnitPrice DESC)




-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

-- Запрос выводит ид счёта, дату счёта, имя продовца, общую сумму проданных товаров по счёту и общую сумму по сумме выбранных завершёных заказов, 
-- и выбранны только те данные, где общую сумму проданных товаров по счёту больше 27 000, 
-- так же по сумме по сумме выбранных завершёных заказов стоит условие, что сбор заказа завершён


SET STATISTICS IO, TIME ON

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

(затронуто строк: 8)
Таблица "OrderLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 326, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "OrderLines". Считано сегментов 1, пропущено 0.
Таблица "InvoiceLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 322, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Orders". Сканирований 13, логических операций чтения 725, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Invoices". Сканирований 13, логических операций чтения 11994, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "People". Сканирований 9, логических операций чтения 28, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

(затронута одна строка)

 Время работы SQL Server:
   Время ЦП = 219 мс, затраченное время = 68 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

Время выполнения: 2022-10-09T13:27:20.1995556+03:00
*/


-- Я думаю, что проверка на о что сбор заказа завершён излишне, так как заказ уже оплачен, 
-- ниже запросами на всякий случай проверил, что нет данный по счетам, если заказ не завершён, за счёт того, что убрал данное условие получил оптимизацию не большую
--Для оптимизации скрипта попробовал сократить Select, за счёт inner join
-- В inner join вывел таблицу сотрудников (People), откуда берём полное имя
-- В inner join добавил таблицу InvoiceLines и добавил группировку, и having добавил что бы сумма по счёта была > 27 000. 
-- Ниже сделал ещё вариант, где подзапрос в Join вывел в CTE то же выглядит хорошо, в прои


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = Invoices.OrderId	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
inner Join Sales.InvoiceLines ON Invoices.InvoiceID = InvoiceLines.InvoiceID
inner Join  Application.People ON People.PersonID = Invoices.SalespersonPersonID
GROUP BY Invoices.InvoiceId,
		 Invoices.InvoiceDate,
		 People.FullName,
		 Invoices.OrderId
HAVING SUM(Quantity*UnitPrice) > 27000
ORDER BY TotalSummByInvoice DESC

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

(затронуто строк: 8)
Таблица "OrderLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 326, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "OrderLines". Считано сегментов 1, пропущено 0.
Таблица "InvoiceLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 322, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Invoices". Сканирований 13, логических операций чтения 11994, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "People". Сканирований 13, логических операций чтения 28, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

(затронута одна строка)

 Время работы SQL Server:
   Время ЦП = 172 мс, затраченное время = 71 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

Время выполнения: 2022-10-09T13:26:48.7476925+03:00
*/

;With InvoiceLinesCTE (InvoiceId, TotalSummByInvoice) as
(
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSummByInvoice
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	InvoiceLinesCTE.TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = Invoices.OrderId	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
Inner Join InvoiceLinesCTE ON Invoices.InvoiceID = InvoiceLinesCTE.InvoiceID
ORDER BY TotalSummByInvoice DESC

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

(затронуто строк: 8)
Таблица "OrderLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 326, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "OrderLines". Считано сегментов 1, пропущено 0.
Таблица "InvoiceLines". Сканирований 24, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 322, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Invoices". Сканирований 13, логических операций чтения 11994, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "People". Сканирований 12, логических операций чтения 28, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

(затронута одна строка)

 Время работы SQL Server:
   Время ЦП = 156 мс, затраченное время = 64 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

Время выполнения: 2022-10-09T13:26:03.5677357+03:00
*/

SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice), OrderLines.OrderID
FROM Sales.OrderLines
Inner Join Sales.Orders ON Orders.OrderID = OrderLines.OrderID
WHERE Orders.PickingCompletedWhen IS NOT NULL
Group By OrderLines.OrderID



SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice), OrderLines.OrderID
FROM Sales.OrderLines
Inner Join Sales.Orders ON Orders.OrderID = OrderLines.OrderID
WHERE Orders.PickingCompletedWhen IS NULL AND OrderLines.PickedQuantity*OrderLines.UnitPrice>0
Group By OrderLines.OrderID
				

SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice), OrderLines.OrderID
FROM Sales.OrderLines
Inner Join Sales.Orders ON Orders.OrderID = OrderLines.OrderID
Inner Join Sales.Invoices ON Orders.OrderID = Invoices.OrderID
WHERE Orders.PickingCompletedWhen IS NULL 
Group By OrderLines.OrderID