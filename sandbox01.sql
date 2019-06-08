SELECT P.[productid]
      ,P.[name]
      ,P.[city]
  FROM [dbo].[products] AS P

SELECT S.[supplierid]
      ,S.[name]
      ,S.[rating]
      ,S.[city]
  FROM [dbo].[suppliers] AS S

SELECT D.[detailid]
      ,D.[name]
      ,D.[color]
      ,D.[weight]
      ,D.[city]
  FROM [dbo].[details] AS D

SELECT F.[supplierid]
      ,F.[detailid]
      ,F.[productid]
      ,F.[quantity]
  FROM [dbo].[supplies] AS F
GO
-----------------
SELECT F.[supplierid]
      ,S.[name]
      ,S.[rating]
      ,S.[city]
	  ,F.[detailid]
      ,D.[name]
      ,D.[color]
      ,D.[weight]
      ,D.[city]
	  ,F.[productid]
      ,P.[name]
      ,P.[city]
	  ,F.[quantity]
	FROM [dbo].[supplies] AS F
	JOIN [dbo].[suppliers] AS S
	ON S.supplierid = F.supplierid
	JOIN [dbo].[details] AS D
	ON D.detailid = F.detailid
	JOIN [dbo].[products] AS P
	ON P.productid = F.productid
	ORDER BY P.productid
	ORDER BY S.supplierid
	WHERE P.city = 'London'
	OR
	S.city = 'London'


SELECT DISTINCT F.[productid]
      ,P.[name]
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
