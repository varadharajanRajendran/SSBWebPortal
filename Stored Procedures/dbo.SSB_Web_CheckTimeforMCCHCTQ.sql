SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_Web_CheckTimeforMCCHCTQ]
		@BatchID	nvarchar(255)		,
		@MachineID	nvarchar(255)	
AS
 
  DECLARE @OrderID nvarchar(255),
		  @TimetoCTQ bit

/*
 SELECT @OrderID =CFLog.pom_order_id
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_CF_LOG] CFLog on CFLog.pom_order_id=Po.pom_order_id
	    INNER JOIN [SitMesDB].[dbo].[POM_CF_LOG_VALUE] CFVal on CFVal.pom_cf_log_pk=CFLog.pom_cf_log_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
		INNER JOIN [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] PSP ON PSP.pom_entry_pk=PoE.pom_entry_pk
	WHERE PS.PS_PPR='SSB_CML'
		AND PT.[id] like '%' + @MachineID + '%'
		AND CONVERT(nvarchar(255),CFVal.pom_cf_log_value) like @BatchID
		AND PSP.name ='TimetoCTQ'
		AND VALUE >0
*/
  
  select @OrderID=pom_order_id FROM [SitMesDB].[dbo].POMV_ORDR_PRP_VAL 
where pom_custom_fld_name = 'BorderGroup' 
AND Convert(nvarchar(255),pom_cf_value)=@BatchID



IF @OrderID<>'' OR  @OrderID IS NULL
	BEGIN
		SELECT @TimetoCTQ='1'
		SELECT @TimetoCTQ as TimetoCTQ
		EXEC [dbo].[SSB_Web_GetOrderQualityCTQ] @OrderID,@MachineID
	END
GO
