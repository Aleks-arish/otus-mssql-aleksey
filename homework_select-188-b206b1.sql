/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

Select WSI.StockItemID,
	   WSI.StockItemName 
From Warehouse.StockItems WSI
Where WSI.StockItemName Like '%urgent%' OR  WSI.StockItemName Like 'Animal%'   

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

Select PS.SupplierName From Purchasing.Suppliers PS Left Join  Purchasing.PurchaseOrders PPO ON
	PS.SupplierID = PPO.SupplierID
Where PPO.SupplierID IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

Select  o.OrderID,
		Format(o.OrderDate, 'dd.MM.yyyy') OrderDate,
		Format(o.OrderDate, 'MMMM') OrderMonth,
		DatePart(qq, o.OrderDate) OrderNumQuarter,
		DatePart(m, o.OrderDate)/4 + Case When DatePart(m, o.OrderDate) % 4 <> 0 Then 1 Else 0 End OrderthirdOfTheYear,	
		C.CustomerName,
		ol.Quantity,
		ol.UnitPrice

From Sales.Orders o 
Inner Join Sales.Customers c ON o.CustomerID = c.CustomerID
Inner Join Sales.OrderLines ol ON o.OrderID = ol.OrderID
Where (ol.Quantity>20 OR ol.UnitPrice>100 ) AND Not ol.PickingCompletedWhen IS Null
Order by OrderNumQuarter, OrderthirdOfTheYear, o.OrderDate
offset (1000) rows fetch First 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

Select	dm.DeliveryMethodName,
		po.ExpectedDeliveryDate,
		s.SupplierName,
		p.FullName
From Purchasing.Suppliers s 
INNER JOIN Purchasing.PurchaseOrders po ON po.SupplierID = s.SupplierID
INNER JOIN Application.DeliveryMethods dm ON dm.DeliveryMethodID = s.DeliveryMethodID
INNER JOIN Application.People p ON p.PersonID = po.ContactPersonID
Where	(po.ExpectedDeliveryDate between '20130101' AND '20130131') AND 
		(dm.DeliveryMethodName = 'Air Freight' OR dm.DeliveryMethodName = 'Refrigerated Air Freight') AND 
		po.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

Select Distinct	Top 10
		o.OrderDate,
		c.CustomerName,
		p.FullName
From Sales.Orders o 
INNER JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Application.People p ON p.PersonID = o.ContactPersonID
Order by o.OrderDate Desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

Select	c.CustomerID, 
		c.CustomerName,
		c.PhoneNumber
From Warehouse.StockItems si
INNER JOIN Warehouse.StockItemTransactions sit ON si.SupplierID = sit.SupplierID
INNER JOIN Sales.InvoiceLines io ON sit.StockItemID = io.StockItemID
INNER JOIN Sales.Invoices i ON io.InvoiceID = i.InvoiceID
INNER JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
Where si.StockItemName = 'Chocolate frogs 250g' 
