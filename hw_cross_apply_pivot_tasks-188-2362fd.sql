/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/




Select   InvoiceMonth
		,[2] as [Sylvanite, MT]
		,[3] as [Peeples Valley, AZ]
		,[4] as [Medicine Lodge, KS]
		,[5] as [Gasport, NY]
		,[6] as[Jessie, ND]
From (Select Format(i.InvoiceDate, '01.MM.yyyy') InvoiceMonth
			,c.CustomerID
			,il.Quantity
	From Sales.InvoiceLines il
	Inner join Sales.Invoices i On i.InvoiceID = il.InvoiceID
	Inner Join Sales.Customers c On c.CustomerID = i.CustomerID
	Where c.CustomerID in(2,3,4,5,6)) as CustomerData
	Pivot 
	(
	sum(CustomerData.Quantity) For CustomerData.CustomerID in ([2],[3],[4],[5],[6])
	) as SvodCustomer


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

Select   CustomerName
		,AddressLine
From (Select c.CustomerName
			,c.DeliveryAddressLine1
			,c.DeliveryAddressLine2
			,c.PostalAddressLine1
			,c.PostalAddressLine2
		From Sales.Customers c
		Where c.CustomerName Like 'Tailspin Toys%'
	) as AddressCustomer
Unpivot (AddressLine For TypeAddress IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) AddressCustomerUnpivot


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

Select   CountryId
		,CountryName
		,Code
From( Select CountryId
			,CountryName
			,IsoAlpha3Code
			,cast(IsoNumericCode as nvarchar(3)) IsoNumericCode
	From Application.Countries
	) AddressCode
Unpivot (Code For TypeCode IN(IsoAlpha3Code, IsoNumericCode)) AddressCodeUnpivot

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/



Select Distinct  c.CustomerID
		,c.CustomerName
		,InvLin.StockItemID 
		,InvLin.UnitPrice
		,InvLin.InvoiceDate
From Sales.Customers c
Cross Apply (Select Distinct Top 2 il.StockItemID 
					,il.UnitPrice
					,Inv.InvoiceDate
			From Sales.InvoiceLines il 
			Inner Join Sales.Invoices Inv ON Inv.InvoiceID = il.InvoiceID
			Where Inv.InvoiceID = il.InvoiceID 
			Order By il.UnitPrice DESC
			) InvLin
Order by c.CustomerID










