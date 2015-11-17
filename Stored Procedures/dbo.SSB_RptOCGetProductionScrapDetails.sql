SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptOCGetProductionScrapDetails]
		@StartTime dateTime,
		@EndTime	dateTime	
AS
 
SELECT CONVERT(date, DATEADD(minute,-[actual_start_time_bias],[actual_start_time]))  as [Date],
		[pom_order_id]
	  ,REPLACE([ppr_name],'PPR_','') as [SKU]
      ,DATEADD(minute,-[actual_start_time_bias],[actual_start_time]) as [Start Time]
      ,DATEADD(minute,-[actual_end_time_bias],[actual_end_time]) as [End Time]
	  ,-1 * (DATEDIFF(minute,(DATEADD(minute,-[actual_end_time_bias],[actual_end_time])),(DATEADD(minute,-[actual_start_time_bias],[actual_start_time])))) as [Duration]
	  ,pom_entry_status_id
  FROM [SitMesDB].[dbo].[POMV_ETRY]
 WHERE  Pom_entry_type_Id='OVERCAST'
	 AND actual_start_time >=@StartTime AND [actual_end_time]<=@EndTime
	 AND pom_entry_status_id='Scrap'
GO
