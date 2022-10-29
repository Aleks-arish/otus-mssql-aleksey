/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/


DECLARE @xmldoc xml
SELECT @xmldoc = BulkColumn
    FROM OPENROWSET (BULK 'C:\Users\LeksL\OneDrive\Рабочий стол\Домашка ОТУС\StockItems-188-1fb5df.xml',  SINGLE_CLOB) as data


Update si
	 Set si.[StockItemName] = t.Item.value('(@Name)[1]', 'varchar(100)') 
		,si.[SupplierID] = t.Item.value('(SupplierID)[1]', 'int') 
		,si.[UnitPackageID] = t.Item.value('(Package/UnitPackageID)[1]'  ,'int')  
		,si.[OuterPackageID] = t.Item.value('(Package/OuterPackageID)[1]' ,'int')   
		,si.[QuantityPerOuter] = t.Item.value('(Package/QuantityPerOuter)[1]' ,'int')   
		,si.[TypicalWeightPerUnit] = t.Item.value('(Package/TypicalWeightPerUnit)[1]' ,'decimal(18, 3)')   
		,si.[LeadTimeDays] = t.Item.value('(LeadTimeDays)[1]' ,'int')   
		,si.[IsChillerStock] = t.Item.value('(IsChillerStock)[1]', 'bit')   
		,si.[TaxRate] = t.Item.value('(TaxRate)[1]' ,'decimal(18, 3)')   
		,si.[UnitPrice] = t.Item.value('(UnitPrice)[1]' ,'decimal(18, 2)')  
From @xmldoc.nodes('(/StockItems/Item)') as t(Item)
Inner Join Warehouse.StockItems si ON t.Item.value('(@Name)[1]', 'varchar(100)') = si.StockItemName


Insert Into [Warehouse].[StockItems]
			(StockItemName
			,SupplierID
			,UnitPackageID
			,OuterPackageID
			,QuantityPerOuter
			,TypicalWeightPerUnit
			,LeadTimeDays
			,IsChillerStock
			,TaxRate
			,UnitPrice
			,LastEditedBy)
SELECT   t.Item.value('(@Name)[1]', 'varchar(100)') StockItemName
		,t.Item.value('(SupplierID)[1]', 'int') SupplierID
		,t.Item.value('(Package/UnitPackageID)[1]'  ,'int')  UnitPackageID
		,t.Item.value('(Package/OuterPackageID)[1]' ,'int')  OuterPackageID 
		,t.Item.value('(Package/QuantityPerOuter)[1]' ,'int')  QuantityPerOuter 
		,t.Item.value('(Package/TypicalWeightPerUnit)[1]' ,'decimal(18, 3)')  TypicalWeightPerUnit 
		,t.Item.value('(LeadTimeDays)[1]' ,'int')  LeadTimeDays 
		,t.Item.value('(IsChillerStock)[1]', 'bit')  IsChillerStock 
		,t.Item.value('(TaxRate)[1]' ,'decimal(18, 3)')  TaxRate 
		,t.Item.value('(UnitPrice)[1]' ,'decimal(18, 2)')  UnitPrice
		,1
From @xmldoc.nodes('(/StockItems/Item)') as t(Item)
Left Join Warehouse.StockItems si ON t.Item.value('(@Name)[1]', 'varchar(100)') = si.StockItemName
Where si.StockItemName IS NULL

DECLARE @idoc INT
EXEC sp_xml_preparedocument @idoc OUTPUT,@xmldoc

Update si
	Set si.SupplierID = StockItemsXML.SupplierID,
		si.UnitPackageID = StockItemsXML.UnitPackageID,
		si.OuterPackageID = StockItemsXML.OuterPackageID, 
		si.QuantityPerOuter = StockItemsXML.QuantityPerOuter, 
		si.TypicalWeightPerUnit = StockItemsXML.TypicalWeightPerUnit, 
		si.LeadTimeDays = StockItemsXML.LeadTimeDays, 
		si.IsChillerStock = StockItemsXML.IsChillerStock, 
		si.TaxRate = StockItemsXML.TaxRate, 
		si.UnitPrice = StockItemsXML.UnitPrice
From OPENXML(@idoc, '/StockItems/Item',2)
	With (  
			StockItemName varchar(100) '@Name',
			SupplierID int 'SupplierID',
			UnitPackageID  int 'Package/UnitPackageID',
			OuterPackageID int 'Package/OuterPackageID', 
			QuantityPerOuter int 'Package/QuantityPerOuter', 
			TypicalWeightPerUnit decimal(18, 3) 'Package/TypicalWeightPerUnit', 
			LeadTimeDays int 'LeadTimeDays', 
			IsChillerStock bit 'IsChillerStock', 
			TaxRate decimal(18, 3) 'TaxRate', 
			UnitPrice decimal(18, 2) 'UnitPrice') StockItemsXML
Inner Join Warehouse.StockItems si ON StockItemsXML.StockItemName = si.StockItemName

Insert Into [Warehouse].[StockItems]
			(StockItemName
			,SupplierID
			,UnitPackageID
			,OuterPackageID
			,QuantityPerOuter
			,TypicalWeightPerUnit
			,LeadTimeDays
			,IsChillerStock
			,TaxRate
			,UnitPrice
			,LastEditedBy)
Select StockItemsXML.* ,1
From OPENXML(@idoc, '/StockItems/Item',2)
	With (  
			StockItemName varchar(100) '@Name',
			SupplierID int 'SupplierID',
			UnitPackageID  int 'Package/UnitPackageID',
			OuterPackageID int 'Package/OuterPackageID', 
			QuantityPerOuter int 'Package/QuantityPerOuter', 
			TypicalWeightPerUnit decimal(18, 3) 'Package/TypicalWeightPerUnit', 
			LeadTimeDays int 'LeadTimeDays', 
			IsChillerStock bit 'IsChillerStock', 
			TaxRate decimal(18, 3) 'TaxRate', 
			UnitPrice decimal(18, 2) 'UnitPrice') StockItemsXML
LEFT Join Warehouse.StockItems si ON si.StockItemName = StockItemsXML.StockItemName
Where si.StockItemName IS NULL




/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

--DECLARE @cmd  VARCHAR(2000);
--Set @cmd = 'bcp "Select StockItemName [@Name] From Warehouse.StockItems For XML PATH(''Item''), ROOT(''StockItems'')" queryout  C:\otus_DZ\StockItems.xml -x -c -t -T -S DESKTOP-O7F784A\SQL2019'
--exec master..xp_cmdshell @cmd

--Select StockItemName [@Name] From Warehouse.StockItems For XML PATH('Item'), ROOT('StockItems')

--CREATE TABLE Warehouse.StockItems_xml (xCol xml)

--Declare @xmlsql xml = (
Select si.StockItemName [@Name] 
		,si.SupplierID 
		,si.UnitPackageID [Package/UnitPackageID]
		,si.OuterPackageID [Package/UnitPackageID]
		,si.QuantityPerOuter [Package/QuantityPerOuter]
		,si.TypicalWeightPerUnit [Package/TypicalWeightPerUnit]	  
		,si.LeadTimeDays 	  
		,si.IsChillerStock 	  
		,si.TaxRate 	  
		,si.UnitPrice 
	From Warehouse.StockItems si For XML PATH('Item'), ROOT('StockItems')
--	)

--INSERT INTO  Warehouse.StockItems_xml (xCol)
-- 	Select  @xmlsql
	
--Select xCol From Warehouse.StockItems_xml 

--exec master..xp_cmdshell 'bcp "Warehouse.StockItems_xml" out "C:\otus_DZ\StockItems.xml"   -w -T -x -S DESKTOP-O7F784A\SQL2019'
--не получилось у меня выгрузить xml в файл(((, может никогда не придётся с этим работать, или кто-то мне прям покажет где я что делаю не так

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

Select StockItemID
	,StockItemName
	,(Select * From Openjson(CustomFields)
		With (CountryOfManufacture nvarchar(50) '$.CountryOfManufacture')
	  )  CountryOfManufacture
	,(Select * From Openjson(CustomFields)
		With (CountryOfManufacture nvarchar(50) '$.Tags[0]')
	 )  FirstTag
From Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


Select StockItemID
	,StockItemName
	,Json_Value(CustomFields, '$.Tags[0]') FirstTag
	,Replace(Replace(Json_Query(CustomFields, '$.Tags'),']',''),'[','') AllTag
	,Tag.value
From Warehouse.StockItems
Cross apply Openjson(CustomFields, '$.Tags') Tag
Where Tag.value = 'Vintage'