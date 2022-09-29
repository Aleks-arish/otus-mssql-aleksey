/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT	 year(i.InvoiceDate) as yearSales
		,month(i.InvoiceDate) as monthSales
		,AVG(il.[UnitPrice]) AvgPrice
		,sum(il.[UnitPrice]*il.[Quantity]) TotalSales
  FROM [Sales].[InvoiceLines] il 
  Inner Join [Sales].[Invoices] i ON il.[InvoiceID] = i.[InvoiceID]
  Group By	 year(i.InvoiceDate) 
			,month(i.InvoiceDate) 
  Order By   year(i.InvoiceDate) 
			,month(i.InvoiceDate)
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT	 year(i.InvoiceDate) as yearSales
		,month(i.InvoiceDate) as monthSales
		,sum(il.[UnitPrice]*il.[Quantity]) TotalSales
  FROM [Sales].[InvoiceLines] il 
  Inner Join [Sales].[Invoices] i ON il.[InvoiceID] = i.[InvoiceID]
  Group By	 year(i.InvoiceDate)
			,month(i.InvoiceDate)
  Having sum(il.[UnitPrice]*il.[Quantity]) > 4600000
    Order By year(i.InvoiceDate) 
			,month(i.InvoiceDate)
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT	 Year(i.[InvoiceDate]) as YearSales
		,Month(i.[InvoiceDate]) as MonthSales
		,si.[StockItemName]
		,sum(il.[UnitPrice]*il.[Quantity]) TotalSales
		,min(i.InvoiceDate) FirstSales
		,sum(il.[Quantity]) Quantity
		
  FROM  [Warehouse].[StockItems] si 
  Inner Join [Sales].[InvoiceLines] il ON si.[StockItemID] = il.[StockItemID]
  Inner Join [Sales].[Invoices] i ON i.[InvoiceID] = il.[InvoiceID]
  Group by	 Year(i.[InvoiceDate])
			,Month(i.[InvoiceDate])
			,si.[StockItemName]
  Order By	 Year(i.[InvoiceDate])
			,Month(i.[InvoiceDate])

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/


SELECT	 yearSales
		,monthSales
		,AVG(IsNUll(il.[UnitPrice],0)) AvgPrice
		,sum(IsNUll(il.[UnitPrice],0)*IsNUll(il.[Quantity],0)) TotalSales 
	From (values  (2013, 1, 0, 0), 
			(2013, 2, 0, 0),
			(2013, 3, 0, 0),
			(2013, 4, 0, 0),
			(2013, 5, 0, 0),
			(2013, 6, 0, 0),
			(2013, 7, 0, 0),
			(2013, 8, 0, 0),
			(2013, 9, 0, 0),
			(2013, 10, 0, 0),
			(2013, 11, 0, 0),
			(2013, 12, 0, 0),
			(2014,01, 0, 0), 
			(2014,02, 0, 0),
			(2014,03, 0, 0),
			(2014,04, 0, 0),
			(2014,05, 0, 0),
			(2014,06, 0, 0),
			(2014,07, 0, 0),
			(2014,08, 0, 0),
			(2014,09, 0, 0),
			(2014,10, 0, 0),
			(2014,11, 0, 0),
			(2014,12, 0, 0),
			(2015,01, 0, 0), 
			(2015,02, 0, 0),
			(2015,03, 0, 0),
			(2015,04, 0, 0),
			(2015,05, 0, 0),
			(2015,06, 0, 0),
			(2015,07, 0, 0),
			(2015,08, 0, 0),
			(2015,09, 0, 0),
			(2015,10, 0, 0),
			(2015,11, 0, 0),
			(2015,12, 0, 0),
			(2016,01, 0, 0), 
			(2016,02, 0, 0),
			(2016,03, 0, 0),
			(2016,04, 0, 0),
			(2016,05, 0, 0),
			(2016,06, 0, 0),
			(2016,07, 0, 0),
			(2016,08, 0, 0),
			(2016,09, 0, 0),
			(2016,10, 0, 0),
			(2016,11, 0, 0),
			(2016,12, 0, 0)
			) as Allmonth (yearSales, monthSales, AvgPrice, TotalSales)
  
  Left Join [Sales].[Invoices] i ON Allmonth.yearSales = Year(i.[InvoiceDate]) AND Allmonth.monthSales = Month(i.[InvoiceDate])
  Left Join [Sales].[InvoiceLines] il ON il.[InvoiceID] = i.[InvoiceID]
  Group By	 yearSales
			,monthSales
    Order By yearSales
			,monthSales


SELECT	 yearSales
		,monthSales
		,Case When sum(il.[UnitPrice]*il.[Quantity]) > 4600000 Then sum(IsNUll(il.[UnitPrice],0)*IsNUll(il.[Quantity],0)) Else 0 End TotalSales 
	From (values  (2013, 1, 0, 0), 
			(2013, 2, 0, 0),
			(2013, 3, 0, 0),
			(2013, 4, 0, 0),
			(2013, 5, 0, 0),
			(2013, 6, 0, 0),
			(2013, 7, 0, 0),
			(2013, 8, 0, 0),
			(2013, 9, 0, 0),
			(2013, 10, 0, 0),
			(2013, 11, 0, 0),
			(2013, 12, 0, 0),
			(2014,01, 0, 0), 
			(2014,02, 0, 0),
			(2014,03, 0, 0),
			(2014,04, 0, 0),
			(2014,05, 0, 0),
			(2014,06, 0, 0),
			(2014,07, 0, 0),
			(2014,08, 0, 0),
			(2014,09, 0, 0),
			(2014,10, 0, 0),
			(2014,11, 0, 0),
			(2014,12, 0, 0),
			(2015,01, 0, 0), 
			(2015,02, 0, 0),
			(2015,03, 0, 0),
			(2015,04, 0, 0),
			(2015,05, 0, 0),
			(2015,06, 0, 0),
			(2015,07, 0, 0),
			(2015,08, 0, 0),
			(2015,09, 0, 0),
			(2015,10, 0, 0),
			(2015,11, 0, 0),
			(2015,12, 0, 0),
			(2016,01, 0, 0), 
			(2016,02, 0, 0),
			(2016,03, 0, 0),
			(2016,04, 0, 0),
			(2016,05, 0, 0),
			(2016,06, 0, 0),
			(2016,07, 0, 0),
			(2016,08, 0, 0),
			(2016,09, 0, 0),
			(2016,10, 0, 0),
			(2016,11, 0, 0),
			(2016,12, 0, 0)
			) as Allmonth (yearSales, monthSales, AvgPrice, TotalSales)
  
  Left Join [Sales].[Invoices] i ON Allmonth.yearSales = Year(i.[InvoiceDate]) AND Allmonth.monthSales = Month(i.[InvoiceDate])
  Left Join [Sales].[InvoiceLines] il ON il.[InvoiceID] = i.[InvoiceID]
  Group By	 yearSales
			,monthSales
    Order By yearSales
			,monthSales