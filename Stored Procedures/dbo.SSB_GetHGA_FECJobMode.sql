SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_GetHGA_FECJobMode]		
	@EntryID as nvarchar(50)
 AS


DECLARE @recordCount	as int	
DECLARE @SKU			as nvarchar(50)
DECLARE @Result			as int

SELECT @recordCount=COUNT(*)
FROM SitMesDB.dbo.POM_ENTRY Pe
	INNER JOIN SitMesDB.dbo.POM_ORDER Po ON Po.Pom_order_Pk=Pe.Pom_order_pk
	INNER JOIN SitMesDB.dbo.POM_ENTRY Peo ON Peo.Pom_entry_id=Po.Pom_order_id
	INNER JOIN SitMesDB.dbo.POM_ENTRY Pef ON Pef.Pom_order_Pk=Pe.Pom_order_pk
WHERE Pe.Pom_entry_id ='131166544.PurchaseCoilAssem1'	
	AND Pef.pom_entry_id like '%FEC%'

IF @recordCount=1
BEGIN
	SELECT @SKU=Peo.matl_def_id
	FROM SitMesDB.dbo.POM_ENTRY Pe
		INNER JOIN SitMesDB.dbo.POM_ORDER Po ON Po.Pom_order_Pk=Pe.Pom_order_pk
		INNER JOIN SitMesDB.dbo.POM_ENTRY Peo ON Peo.Pom_entry_id=Po.Pom_order_id
		INNER JOIN SitMesDB.dbo.POM_ENTRY Pef ON Pef.Pom_order_Pk=Pe.Pom_order_pk
	WHERE Pe.Pom_entry_id =@EntryID	
		AND Pef.pom_entry_id like '%FEC%'

   IF @SKU like '500705353%' OR  @SKU like'500706552%'
   BEGIN
		SELECT @Result=2
   END
   ELSE
   BEGIN
		SELECT @Result=1
   END
END 
   ELSE
   BEGIN
		SELECT @Result=0
   END

SELECT @Result as Result
GO
