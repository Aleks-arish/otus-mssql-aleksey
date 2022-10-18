/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @ColumnName1 NVARCHAR(2000);

Select  @ColumnName1 = IsNull(@ColumnName1+',','')+ quotename(cast(CustomerID as nvarchar(5))) 
From (Select Distinct i.CustomerID 
	  From Sales.Invoices i
	  Inner Join Sales.Customers c On c.CustomerID = i.CustomerID
	  Where  i.CustomerID<=500
	 ) as columnName
	  Order By CustomerID
Set @ColumnName1 = @ColumnName1 + ','

DECLARE @ColumnName2 NVARCHAR(2000);
Select  @ColumnName2 = IsNull(@ColumnName2+',','')+ quotename(cast(CustomerID as nvarchar(5))) 
From (Select Distinct i.CustomerID 
	  From Sales.Invoices i
	  Inner Join Sales.Customers c On c.CustomerID = i.CustomerID
	  Where  i.CustomerID>500 AND i.CustomerID<=1000
	 ) as columnName
	  Order By CustomerID 
Set @ColumnName2 = @ColumnName2 + ','

DECLARE @ColumnName3 NVARCHAR(2000);
Select  @ColumnName3 = IsNull(@ColumnName3+',','')+ quotename(cast(CustomerID as nvarchar(5))) 
From (Select Distinct i.CustomerID 
	  From Sales.Invoices i
	  Inner Join Sales.Customers c On c.CustomerID = i.CustomerID
	  Where  i.CustomerID>1000 AND i.CustomerID<=1500
	 ) as columnName
	  Order By CustomerID 
Set @ColumnName3 = @ColumnName3 

DECLARE @SQLString NVARCHAR(4000) 
DECLARE @ParamColumn NVARCHAR(200) = N'@ColumnSqlName1 NVARCHAR(2000), @ColumnSqlName2 NVARCHAR(2000), @ColumnSqlName3 NVARCHAR(2000)'
Set @SQLString = N'exec(''Select InvoiceMonth,''+ @ColumnSqlName1 +  @ColumnSqlName2  +  @ColumnSqlName3  + '' 
	From  (	Select Format(i.InvoiceDate, ''''01.MM.yyyy'''') InvoiceMonth ,c.CustomerID,il.Quantity
			From Sales.InvoiceLines il
			Inner join Sales.Invoices i On i.InvoiceID = il.InvoiceID
			Inner Join Sales.Customers c On c.CustomerID = i.CustomerID) CustomerData
		Pivot
		(
		sum(CustomerData.Quantity) For CustomerData.CustomerID in ('' + @ColumnSqlName1 + @ColumnSqlName2 + @ColumnSqlName3 + '')) SvodCustomer'')'

Exec sp_executesql @SQLString, @ParamColumn, @ColumnName1, @ColumnName2, @ColumnName3

