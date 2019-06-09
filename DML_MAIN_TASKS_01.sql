USE O_SYDOR_MODULE_3

/* 1. Збільшити на 10 рейтинг всіх постачальників, рейтинг яких в даний момент менший ніж рейтинг постачальника 4 */

BEGIN
	DECLARE @intRating INT
	SET @intRating = (SELECT [rating] FROM [dbo].[suppliers] WHERE [supplierid] = 4)

	UPDATE [dbo].[suppliers]
	  SET [rating] += 10
	  WHERE [rating] < @intRating
END
GO



/* 2. Побудувати таблицю, в якій занесено список номерів виробів, що або знаходяться в Лондоні, 
      або для них поставляються деталі яким-небудь постачальником з Лондона */

SELECT DISTINCT P.[productid]
      ,P.[name]
	INTO [dbo].[tmp_02]
	FROM [dbo].[supplies] AS F
	JOIN [dbo].[suppliers] AS S
	ON S.supplierid = F.supplierid
--	JOIN [dbo].[details] AS D
--	ON D.detailid = F.detailid
	JOIN [dbo].[products] AS P
	ON P.productid = F.productid
	WHERE P.city = 'London'
	OR
	S.city = 'London'

/* 3. Видалити всі вироби, для яких немає поставок деталей */
-- Since we have no records with this condition I've added two 'useless' detail here

INSERT INTO [dbo].[products]
           ([productid]
           ,[name]
           ,[city])
     VALUES
           (100
           ,'Useless detail'
           ,'London'),
		   (101
           ,'Useless detail again'
           ,'Paris')
GO

DELETE FROM products
WHERE [productid] NOT IN (
	SELECT DISTINCT productid FROM [dbo].[supplies]
)

/* 4. Створити таблицю з номерами постачальників і парами номерів деталей, таких, що кожен з постачальників поставляє обидві вказані деталі */
SELECT DISTINCT S.[supplierid] AS 'supplier'
      ,S.[detailid] AS 'detail 1'
      ,D.[detailid] AS 'detail 2'
  INTO [dbo].[tmp_04] 
  FROM [dbo].[supplies] AS S
  JOIN
  [dbo].[supplies] AS D
  ON S.supplierid = D.supplierid
  AND
  S.detailid > D.detailid


/* 5. Збільшити розмір поставки на 10 відсотків для всіх поставок тих постачальників, які поставляють яку-небудь Червону деталь */

UPDATE [dbo].[supplies]
  SET [quantity] *= 1.1
  WHERE [supplierid] IN
  (
  SELECT DISTINCT F.[supplierid]
	FROM [dbo].[supplies] AS F
	JOIN [dbo].[suppliers] AS S
	ON S.supplierid = F.supplierid
	JOIN [dbo].[details] AS D
	ON D.detailid = F.detailid
	WHERE D.color = 'Red'
  )
	

/* 6. Створити таблицю  з комбінаціями «колір деталі -- місто де зберігається деталь» з видаленням дублікатів */
SELECT DISTINCT 
       [color] AS 'detail color'
      ,[city] AS 'detail city'
	  INTO [dbo].[tmp_06]
	  FROM [dbo].[details]


/* 7. Занести в новостворену таблицю список номерів деталей, які поставляються 
      будь-яким постачальником з Лондона чи для будь-якого виробу з Лондона */
SELECT DISTINCT F.[detailid] AS 'detail id'
	INTO [dbo].[tmp_07]
	FROM [dbo].[supplies] AS F
	JOIN [dbo].[suppliers] AS S
	ON S.supplierid = F.supplierid
	JOIN [dbo].[details] AS D
	ON D.detailid = F.detailid
	JOIN [dbo].[products] AS P
	ON P.productid = F.productid
	WHERE P.city = 'London'
	OR
	S.city = 'London'

/* 8.	Вставити в таблицю постачальників постачальника з кодом 10, прізвищем Уайт, з міста Нью-Йорк з невідомим рейтингом   */
INSERT INTO [dbo].[suppliers]
           ([supplierid]
           ,[name]
           ,[city])
     VALUES
           (10
           ,'White'
           ,'New York')
GO



/* 9.	Видалити всі вироби з Риму і всі відповідні поставки */

/*This script won't be work if constraints and relations are exist
If we have ON DELETE  CASCADE we need just a simple script like


But it isn't as interesting as we would like so I suppose we didn't have those constraints and wrote a little bit more complicated script (see below)

DECLARE @DelProduct TABLE (ProductID INT)
DELETE [dbo].[products]
OUTPUT DELETED.productid INTO @DelProduct
WHERE city = 'Roma'
DELETE [dbo].[supplies]
WHERE [supplies].productid IN (SELECT productid FROM @DelProduct)
GO


*/


DELETE [dbo].[products]
WHERE city = 'Roma'

/* 10.	Створити таблицю з впорядкованим списком всіх міст в яких є по крайній мірі один постачальник, одна деталь чи виріб */

SELECT city 
INTO [dbo].[tmp_10]
FROM suppliers
UNION
SELECT city FROM products
UNION
SELECT city FROM details
ORDER BY city

/* 11. Змінити колір червоних деталей з вагою менше 15 фунтів на жовтий. */
UPDATE [dbo].[details]
	SET color = 'Yellow'
	WHERE color = 'Red' AND weight < 15

/* 12. Створити таблицю з номерами виробів і назвами міст, де вони виготовляються. Додаткова умова – друга літера назва міста повинна бути ‘о’ */
SELECT [productid], [city] 
INTO [dbo].[tmp_12]
FROM products 
WHERE [city] LIKE '_o%'

/* 13.	Збільшити на 10 рейтинг тих постачальників, об’єм поставок яких вище середнього */
UPDATE [dbo].[suppliers]
	SET rating*=1.1
	WHERE [suppliers].[supplierid] IN 
	(
		SELECT [supplierid]
		--,SUM([quantity])/COUNT([quantity])
		FROM [O_SYDOR_MODULE_3].[dbo].[supplies]
		GROUP BY [supplierid]
		HAVING SUM([quantity])/COUNT([quantity]) > 
			(
			SELECT SUM([quantity])/COUNT([quantity])
			FROM [O_SYDOR_MODULE_3].[dbo].[supplies])
	)

/* 14.	Створити таблицю з впорядкованими списками номерів і прізвищами постачальників, які постачають деталі для виробу 1. */
SELECT S.[supplierid]
	  ,S.[name]
INTO [dbo].[tmp_14]
  FROM [dbo].[supplies] AS F
  JOIN [dbo].[suppliers] AS S
  ON S.supplierid = F.supplierid
  WHERE F.[productid] = 1
  ORDER BY S.name

/* 15.	Вставити в таблицю двох різних постачальників одною командою */
INSERT INTO [dbo].[suppliers]
           ([supplierid]
           ,[name]
           ,[rating]
           ,[city])
     VALUES
           (100500,
           N'Перший постачальник',
           Null,
           'Barcelona'),
		   (100501,
           N'Другий  постачальник',
           1,
           'Ternopil')
GO

/*
Merge 
1.	Створити додаткову таблицю tmp_Details (структура вище) та наповнити її даними 
2.	Написати  команду merge, яка змінить дані у таблиці Details відповідно до вхідних даних таблиці tmp_Details. 
*/


  MERGE INTO [dbo].[details]  AS D
    USING [dbo].[tmp_Details] AS T
    ON T.[detailid] = D.[detailid]
    WHEN MATCHED THEN   
        UPDATE 
		SET D.[detailid] = T.[detailid],
			D.[name]     = T.[name],
			D.[color]    = T.[color],
			D.[weight]   = T.[weight],
			D.[city]     = T.[city]
    WHEN NOT MATCHED THEN  
        INSERT ([detailid], [name],	[color], [weight], [city]) 
		VALUES (T.[detailid], T.[name],	T.[color], T.[weight], T.[city]);