/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

Declare @max_in_customer as int = (Select max([CustomerID]) From  [Sales].[Customers])+1


Insert Into [Sales].[Customers]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     Values
           (@max_in_customer
			,'Abbibas Game'
			,1
			,3
			,1
			,1001
			,1002
			,3
			,19586
			,19586
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO 9999'
			,'Rib12'
			,90410
			,1),
			(@max_in_customer+1
			,'Abbibas Game 2'
			,1
			,3
			,1
			,1001
			,1002
			,3
			,19586
			,19586
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO Box 8975'
			,'Ribeiroville'
			,90410
			,1
			),
			(@max_in_customer+2
			,'Abbibas Game 3'
			,1
			,3
			,1
			,1001
			,1002
			,3
			,19586
			,19586
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO Box 8975'
			,'Ribeiroville'
			,90410
			,1
			),
			(@max_in_customer+3
			,'Abbibas Game 4'
			,1
			,3
			,1
			,1001
			,1002
			,3
			,19586
			,19586
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO Box 8975'
			,'Ribeiroville'
			,90410
			,1
			),
			(@max_in_customer+4
			,'Abbibas Game 5'
			,1
			,3
			,1
			,1001
			,1002
			,3
			,19586
			,19586
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO Box 8975'
			,'Ribeiroville'
			,90410
			,1
			)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

Delete From [Sales].[Customers] Where [CustomerID]=(Select max([CustomerID]) From  [Sales].[Customers])


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

Update [Sales].[Customers]
	Set [PhoneNumber] = '(309) 777-1122'
Where [CustomerID]=(Select max([CustomerID]) From  [Sales].[Customers])

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

Select [CustomerID]
           ,[CustomerName]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
			Into [Sales].[Customers_Copy] From [Sales].[Customers] Where [CustomerID]=(Select max([CustomerID]) From  [Sales].[Customers])

Insert Into [Sales].[Customers_Copy]
           ([CustomerID]
           ,[CustomerName]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]
		   )
     Values
			((Select max([CustomerID]) From  [Sales].[Customers])+1
			,'Abbibas Game 5'
			,'2013-01-01'
			,0.000
			,0
			,0
			,7
			,'(308) 555-0100'
			,'(308) 555-0101'
			,'http://www.abbibas_game.com'
			,'Shop 777'
			,'1877 Road'
			,90410
			,0xE6100000010CE73F5A52A4BF444010638852B1A759C0
			,'PO Box 8975'
			,'Ribeiroville'
			,90410
			,1
			) 
	
Merge [Sales].[Customers_Copy] AS target 
Using(Select [CustomerID]
			,[CustomerName]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryPostalCode]
			,[PostalAddressLine1]
			,[PostalPostalCode]
			,[LastEditedBy]
	  From [Sales].[Customers]
	  ) AS source ([CustomerID], [CustomerName],[AccountOpenedDate],[StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryPostalCode],[PostalAddressLine1],[PostalPostalCode],[LastEditedBy]) ON
(target.[CustomerID] = source.[CustomerID])
When MATCHED
	Then UPDATE Set [CustomerName] = source.[CustomerName],
				[AccountOpenedDate] = source.[AccountOpenedDate],
				[StandardDiscountPercentage] = source.[StandardDiscountPercentage],
				[IsStatementSent] = source.[IsStatementSent],
				[IsOnCreditHold] = source.[IsOnCreditHold],
				[PaymentDays] = source.[PaymentDays],
				[PhoneNumber] = source.[PhoneNumber],
				[FaxNumber] = source.[FaxNumber],
				[WebsiteURL] = source.[WebsiteURL],
				[DeliveryAddressLine1] = source.[DeliveryAddressLine1],
				[DeliveryPostalCode] = source.[DeliveryPostalCode],
				[PostalAddressLine1] = source.[PostalAddressLine1],
				[PostalPostalCode] = source.[PostalPostalCode],
				[LastEditedBy] = source.[LastEditedBy]
When NOT MATCHED
	Then Insert ([CustomerID], [CustomerName],[AccountOpenedDate], [StandardDiscountPercentage],[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[WebsiteURL],[DeliveryAddressLine1],[DeliveryPostalCode],[PostalAddressLine1],[PostalPostalCode],[LastEditedBy])
		Values (source.[CustomerID],source.[CustomerName],source.[AccountOpenedDate],source.[StandardDiscountPercentage], source.[IsStatementSent],source.[IsOnCreditHold],source.[PaymentDays],source.[PhoneNumber],source.[FaxNumber],source.[WebsiteURL],source.[DeliveryAddressLine1],source.[DeliveryPostalCode],source.[PostalAddressLine1],source.[PostalPostalCode],source.[LastEditedBy])
	OUTPUT deleted.*, $action, inserted.*;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--Выставляем настройки для выполнения  bcp out и загрузить через bulk insert
EXEC sp_configure 'show advanced options', 1;  

RECONFIGURE;  

EXEC sp_configure 'xp_cmdshell', 1;  

RECONFIGURE;

drop table if exists [Sales].[Customers_bcp_BULK] 

--Создаём таблицу которую будм выгружать после загружать
Select  [CustomerID]
       ,[CustomerName]
		Into [Sales].[Customers_bcp_BULK] 
From [Sales].[Customers] 


exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers_bcp_BULK" out  "C:\otus_DZ\Customers_bcp_BULK.txt" -T -w -t"!#_#!", -S DESKTOP-O7F784A\SQL2019'

-- Чистим таблицу перед её загрузкой

TRUNCATE TABLE [Sales].[Customers_bcp_BULK];

--Выполняем загрузку
	BULK INSERT [WideWorldImporters].[Sales].[Customers_bcp_BULK]
				   FROM "C:\otus_DZ\Customers_bcp_BULK.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '!#_#!',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );


--Смотрим что загрузили
Select Count(*) From [Sales].[Customers_bcp_BULK];
Select * From [Sales].[Customers_bcp_BULK];

