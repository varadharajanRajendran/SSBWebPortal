SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_Web_SetCTQComplete]
		 @OrderID			nvarchar(50)	,
		 @MachineID			nvarchar(255)	
AS

 DECLARE 
		 @EqID				nvarchar(255)	,
		 @EntryID			int				,		
		 @Ps_Name			nvarchar(255)	,
		 @MachineName		nvarchar(255)	,
		 @PPSPR				int

 SELECT @EqID			=	Eq.equip_id		,
	    @EntryID		=	PoE.pom_entry_pk	,
		@MachineName	=	REPLACE(PS.PS,'*0001.00','')
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
	WHERE PS.PS_PPR='SSB_CML'
		AND PT.[id] like '%'+ @MachineID	 + '%'
		AND Po.pom_order_id =@OrderID


SELECT  @Ps_Name =PS_LabelName
FROM [SitMesDB].[dbo].[PDefM_PS] PS
	INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
WHERE PS.PS_PPR='SSB_CML'
	AND PAR.Param_Name Like 'QUALITY_%'
	AND REPLACE(PS.[PS],'*0001.00','')= @MachineName

SELECT	@PPSPR	=PS.[pom_process_segment_parameter_pk]
FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]  PS
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE ON PE.[pom_entry_pk]=PS.[pom_entry_pk]
	INNER JOIN  [SitMesDB].[dbo].[POM_ORDER] PO on PO.[pom_order_pk]=PE.[pom_order_pk]
WHERE PO.[pom_order_id]=@OrderID
	AND PE.PS_name=@MachineName +'1'
	AND PS.[name]='QUALITY_LogStatus'
ORDER BY seq ASC

EXEC [dbo].[SSB_Web_UpdateQCResult] @PPSPR, '1'
GO
