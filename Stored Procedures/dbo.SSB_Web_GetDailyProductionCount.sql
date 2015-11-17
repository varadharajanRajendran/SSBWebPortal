SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  

CREATE  PROCEDURE [dbo].[SSB_Web_GetDailyProductionCount]
		
AS
 
 SELECT COUNT(Po.pom_order_id)   
  FROM  [SitMesDB].[dbo].[POM_ORDER] as Po
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] as Pe on Pe.pom_order_pk=Po.pom_order_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] as ps on ps.pom_entry_status_pk=pe.pom_entry_status_pk
  WHERE pom_entry_id like '%PurchaseCoilAssem1'
	AND Ps.id='Completed'
	AND CONVERT(VARCHAR(10), Po.RowUpdated, 120)=CONVERT(VARCHAR(10), GetDate(), 120)
GO
