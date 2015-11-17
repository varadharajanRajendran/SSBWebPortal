SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get Work Order Details for the Entr

  Output Parameters:
	Sub Assmebly Material Information
	BOM Material INforamtion
	Properties

  Input Parameters:
	@OrderID			- Order ID
	@MachineName		- Machine Name
	@DisplayAllFields	- Filter selected Fields

  Trigger:
	From web Socket

  Data Read Other Inputs:  
	---

  Data Written Results:
	---

  Assumptions:
	---

  Dependencies 

	---

  Variables:
	---

  Tables Modified
	---

  Modification Change History:
  ---------------------------
  10/21/2014	Varadharajan R	C00V00 - Intial code
  
  
*/
CREATE  PROCEDURE [dbo].[SSB_Web_GetOrderDetails]
		@OrderID			nvarchar(50)	,
        @MachineName		nvarchar(255)	,
		@DisplayAllFields	bit
AS


DECLARE @PPR_No				nvarchar(255)	,
	    @PPR_Version		nvarchar(10)	,
		@intStartRow		int				,
        @intEndRow			int				,
        @intelProc			int				,
		@RecordCount		int				,
        @SelectedPart		nvarchar(255)	,
		@SelectedID			int				,
		@SelectedUnit		nvarchar(255)	,
		@DisplaySelected	int				,
		@SEQNo				int				,	
		@LocationID			nvarchar(255)	,
	    @SelMachineID		nvarchar(255)	,
	    @LocAlias			nvarchar(255)
	    
DECLARE	@Produced AS Table	(	RowId			int	IDENTITY	,
								ItemDesc		nvarchar(255)	,
								PartNo			nvarchar(255)	,
								PartDesc		nvarchar(255)	,
								Qty	     		decimal(6,3)	,
								UoM				nvarchar(255)	,
								Lot			    nvarchar(255)	,
								Location		nvarchar(255)	,
								MatSKU			varchar(255)	)
								
DECLARE	@Consumed AS Table	(	RowId			int	IDENTITY	,
								ItemDesc		nvarchar(255)	,
								PartNo			nvarchar(255)	,
								PartDesc		nvarchar(255)	,
								Qty	     		decimal(6,3)	,
								UoM				nvarchar(255)	,
								Lot			    nvarchar(255)	,
								Location		nvarchar(255)	,
								NPartNo			nvarchar(255)	,
								NPartDesc		nvarchar(255)	,
							    [Priority]	    smallint		,
								[Sequence]		smallint		)

DECLARE	@BOM AS Table	(	RowId			int	IDENTITY	,
							PartNo			nvarchar(255)	,
							Units			nvarchar(255)	)

DECLARE	@EntryProperty AS Table	(	RowId				int	IDENTITY	,
									[Description]		nvarchar(255)	,
									[Value]				nvarchar(255)	,
									[UoM]				nvarchar(255)	)


DECLARE	@ItemProperty AS Table	(	RowId				int	IDENTITY	,
									[PartNo]			nvarchar(255)	,
									[Description]		nvarchar(255)	,
									[Value]				nvarchar(255)	,
									[UoM]				nvarchar(255)	)
/*
SELECT @OrderID='01846499_015'		,
	   @MachineName='PanelQuilt'	,
	   @DisplayAllFields='true'
*/

IF 	@DisplayAllFields=Lower ('true')
BEGIN
	SELECT @DisplaySelected='1'
END
ELSE
BEGIN
	SELECT @DisplaySelected='0'
END

SELECT @PPR_No		=[ppr_name],
	   @PPR_Version	=[ppr_version]
FROM [SitMesDB].[dbo].[POM_ORDER]
WHERE [pom_order_id]=@OrderID


SELECT @SelMachineID=REPLACE(PS.PS,'*0001.00','')
FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
	INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
	INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
	INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
WHERE PS.PS_PPR='SSB_CML'
	AND PT.[id] like '%'+ @MachineName	 + '%'
	AND Po.pom_order_id =@OrderID
		

INSERT INTO @Produced (ItemDesc,PartNo,PartDesc,Qty,UoM	,Lot,MatSKU)
	SELECT	MMClass. [Descript]			,
			MAT_List.[def_name]			,
			MMDef.[Descript]			,
			MAT_List.[quantity]			,
		    UoM.[UomID] AS [Unit]		,
			MAT_List.[lot]  AS [Lot]	,
			POM_Order.ppr_label						
	FROM [SitMesDB].[dbo].[POM_ENTRY] POM_Entry
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] POM_Order On POM_order.[pom_order_pk] =POM_Entry.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION]  MAT_Spec ON MAT_Spec.[POM_ENTRY_PK]= POM_Entry.[pom_entry_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] MAT_List ON MAT_List.[pom_material_specification_pk]=MAT_Spec.[pom_material_specification_pk]
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMClass ON MMClass.[ClassID]=MAT_List.[class]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef ON MMDef.[DefID]=MAT_List.[def_name]
		INNER JOIN [SitMesDB].[dbo].[MESUoMs] UoM on UoM.[UomPK]=MAT_List.[uom]
	  WHERE POM_Entry.[ps_name] like '%' + @SelMachineID + '%'
		AND POM_order.[POM_Order_ID]=@OrderID
		AND MAT_Spec.name='PRODUCED'



SELECT Top 1 @SelectedPart=PartNo
FROM @Produced

/*
SELECT TOP 1 @LocationID	=(REPLACE(LOCPath,'WPB.CML01.'+ @SelMachineID + '01.',''))
FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
	INNER JOIN [SitMesDB].[dbo].[MMLots] MMLot on MMLot.LotID=MMList.[lot]
	INNER JOIN [SitMesDB].[dbo].[MMLocations] MMLoc on MMLoc.LocPK=MMLot.LocPK
WHERE MMList.[def_id]=@SelectedPart
*/

SELECT TOP 1 @LocationID	=MMLoc.LocAlias
FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
	INNER JOIN [SitMesDB].[dbo].[MMLots] MMLot on MMLot.LotID=MMList.[lot]
	INNER JOIN [SitMesDB].[dbo].[MMLocations] MMLoc on MMLoc.LocPK=MMLot.LocPK
WHERE MMList.[def_id]=@SelectedPart

UPDATE @Produced
SET Location=@LocationID
WHERE PartNo=@SelectedPart

INSERT INTO @BOM (PartNo,Units)
	SELECT MBOMItems.ItemAltName,UoM.UomID
	FROM [SitMesDB].[dbo].[MMDefinitions] MDef
	  INNER JOIN [SitMesDB].[dbo].[MMBoms] MBOMs on MDef.DefPK=MBOMs.DefPK
	  INNER JOIN [SitMesDB].[dbo].[MMBomAlts] MAlt on MAlt.BOMPK=MBOMs.BomPK
	  INNER JOIN [SitMesDB].[dbo].[MMBomItemAlts] MBOMItems on MBOMItems.BomAltPK=MAlt.BomAltPK
	  INNER JOIN [SitMesDB].[dbo].[MESUoMs] UoM on UoM.UomPK=MBOMItems.UomPK
	WHERE MDef.DefID=@SelectedPart
	ORDER BY MBOMItems.BomItemAltPK ASC


INSERT INTO @Consumed (ItemDesc,PartNo,PartDesc,Qty,UoM	,Lot)
	SELECT	MMClass. [Descript]			,
			MAT_List.[def_name]			,
			MMDef.[Descript]			,
			MAT_List.[quantity]			,
		    UoM.[UomID] AS [Unit]		,
			MAT_List.[lot]  AS [Lot]							
	FROM [SitMesDB].[dbo].[POM_ENTRY] POM_Entry
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] POM_Order On POM_order.[pom_order_pk] =POM_Entry.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION]  MAT_Spec ON MAT_Spec.[POM_ENTRY_PK]= POM_Entry.[pom_entry_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] MAT_List ON MAT_List.[pom_material_specification_pk]=MAT_Spec.[pom_material_specification_pk]
		INNER JOIN [SitMesDB].[dbo].[MMClasses] MMClass ON MMClass.[ClassID]=MAT_List.[class]
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMDef ON MMDef.[DefID]=MAT_List.[def_name]
		INNER JOIN [SitMesDB].[dbo].[MESUoMs] UoM on UoM.[UomPK]=MAT_List.[uom]
	  WHERE POM_Entry.[ps_name] like '%' + @SelMachineID + '%'
		AND POM_order.[POM_Order_ID]=@OrderID
		AND MAT_Spec.name='CONSUMED'

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@BOM
																												WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @SelectedPart=PartNo,
		   @SelectedUnit=units
	FROM @BOM
	WHERE RowId=@intStartRow

	SELECT Top 1 @SelectedId=RowID
	FROM @Consumed
	WHERE PartNo=@SelectedPart
		AND Sequence is NULL
	
	/*
	SELECT TOP 1 @LocationID	=(REPLACE(LOCPath,'WPB.CML01.'+ @SelMachineID + '01.',''))
	FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
		INNER JOIN [SitMesDB].[dbo].[MMLots] MMLot on MMLot.LotID=MMList.[lot]
		INNER JOIN [SitMesDB].[dbo].[MMLocations] MMLoc on MMLoc.LocPK=MMLot.LocPK
	WHERE MMList.[def_id]=@SelectedPart
	*/
	IF @MachineName = 'MU'
		BEGIN
			SELECT TOP 1 @LocationID	=ISNULL(PickID,0)
			FROM [SSB].[dbo].TempMULocation 
			WHERE PartNo=@SelectedPart
		END
	ELSE
		BEGIN
			SELECT TOP 1 @LocationID	=MMLoc.LocAlias
			FROM [SitMesDB].[dbo].[POM_MATERIAL_LIST]  MMList
				INNER JOIN [SitMesDB].[dbo].[MMLots] MMLot on MMLot.LotID=MMList.[lot]
				INNER JOIN [SitMesDB].[dbo].[MMLocations] MMLoc on MMLoc.LocPK=MMLot.LocPK
			WHERE MMList.[def_id]=@SelectedPart
		END

	IF @LocationID='' OR @LocationID is NULL
	BEGIN
		SELECT @LocationID='0'
	END
	
	
	UPDATE @Consumed
		SET [Sequence]=@intStartRow,
			[UoM]	 =@SelectedUnit,
			[Location]=@LocationID
		WHERE RowId=@SelectedID
	
	SELECT @intStartRow=@intStartRow+1
END

--- Get Next Part No and Descritpion ---
    

--- Get Next Part Priority ---


--- Get Property ---
    --- Get Sub Assembly Property ---
   INSERT INTO @EntryProperty([Description],[Value],[UoM])
	EXEC [SSBWebPortal].[dbo].[SSB_GetEntryProperty]
		  @PPR_ID =@PPR_No,
		  @PPR_Version = @PPR_Version,
		  @PS = @SelMachineID,
		  @DisplaySelectedFields = @DisplaySelected
 
 UPDATE @Produced
	SET UoM=''
	WHERE UoM='n/a'

UPDATE @Consumed
	SET UoM=''
	WHERE UoM='n/a'

UPDATE @EntryProperty
	SET UoM=''
	WHERE UoM='n/a'

 SELECT ItemDesc		As [Item Description]	,
	   PartNo		AS [Part No]			,
	   PartDesc		AS [Part Description]	,
	   Qty			AS [Quantity]			,
	   UoM			AS [Unit]				,
	   Location		AS [Location]			,
	   Lot		    AS [Lot]				 ,
	   MatSKU		as [Mattress SKU No]  	 
FROM @Produced

SELECT ItemDesc		As [Item Description]		,
	   PartNo		AS [Part No]				,
	   PartDesc		AS [Part Description]		,
	   Qty			AS [Quantity]				,
	   UoM			AS [Unit]					,
	   Location		AS [Location]				,
	   Lot		    AS [Lot]					,
	   NPartNo		AS [Next Part No]			,
	   NPartDesc	AS [Next Part Description]	,
	   [Priority]	AS [Priority]											
FROM @Consumed 
ORDER BY [Sequence] ASC

SELECT [Description] as [Property] ,[Value],[UoM] FROM @EntryProperty


IF @DisplayAllFields=Lower ('true')
BEGIN 
		--- Get Produced Parts Property ---
		SELECT	@intStartRow=	min(RowId)	,
				@intEndRow	=	max(RowId)	
		FROM	@Produced
																																WHILE	@intStartRow <=	@intEndRow	
		BEGIN
			SELECT @SelectedPart=PartNo
			FROM @Produced
			WHERE RowId=@intStartRow

			SELECT @RecordCount=COUNT(CONVERT(varchar(max),P.PropertyID)) 
			FROM	[SitMesDB].[dbo].MMvBomItemAltPrpVals AS BIAPV WITH (NOLOCK) INNER JOIN
							[SitMesDB].[dbo].MMBomItemAlts AS BIA WITH (NOLOCK) ON BIA.BomItemAltPK = BIAPV.BomItemAltPK INNER JOIN
							[SitMesDB].[dbo].MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = BIA.DefPK INNER JOIN
							[SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR
							P.VisibleOnRT = 1) INNER JOIN
							[SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK INNER JOIN
							[SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK  
			WHERE   DefID=@SelectedPart
				AND CONVERT(varchar(max),P.PropertyID)<>'MES_ONLY'
	
			IF @RecordCount>0
			BEGIN
				INSERT INTO @ItemProperty([PartNo],[Description],[Value],[UoM])
				SELECT @SelectedPart,CONVERT(varchar(max),P.PropertyID) ,CONVERT(varchar(max),BIAPV.PValue) ,CONVERT(varchar(max),UM.Descript)
				FROM	[SitMesDB].[dbo].MMvBomItemAltPrpVals AS BIAPV WITH (NOLOCK) INNER JOIN
						[SitMesDB].[dbo].MMBomItemAlts AS BIA WITH (NOLOCK) ON BIA.BomItemAltPK = BIAPV.BomItemAltPK INNER JOIN
						[SitMesDB].[dbo].MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = BIA.DefPK INNER JOIN
						[SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR
						P.VisibleOnRT = 1) INNER JOIN
						[SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK INNER JOIN
						[SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK  
				WHERE   DefID=@SelectedPart
				AND CONVERT(varchar(max),P.PropertyID)<>'MES_ONLY'
			END
			SELECT @intStartRow=@intStartRow+1
		END

		--- Get Consumed Parts Property ---
		SELECT	@intStartRow=	min(RowId)	,
				@intEndRow	=	max(RowId)	
		FROM	@Produced
																																WHILE	@intStartRow <=	@intEndRow	
		BEGIN
			SELECT @SelectedPart=PartNo
			FROM @Consumed
			WHERE RowId=@intStartRow

			SELECT @RecordCount=COUNT(CONVERT(varchar(max),P.PropertyID)) 
			FROM	[SitMesDB].[dbo].MMvBomItemAltPrpVals AS BIAPV WITH (NOLOCK) INNER JOIN
							[SitMesDB].[dbo].MMBomItemAlts AS BIA WITH (NOLOCK) ON BIA.BomItemAltPK = BIAPV.BomItemAltPK INNER JOIN
							[SitMesDB].[dbo].MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = BIA.DefPK INNER JOIN
							[SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR
							P.VisibleOnRT = 1) INNER JOIN
							[SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK INNER JOIN
							[SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK  
			WHERE   DefID=@SelectedPart
				AND CONVERT(varchar(max),P.PropertyID)<>'MES_ONLY'
	
			IF @RecordCount>0
			BEGIN
				INSERT INTO @ItemProperty([PartNo],[Description],[Value],[UoM])
					SELECT @SelectedPart,CONVERT(varchar(max),P.PropertyID) ,CONVERT(varchar(max),BIAPV.PValue) ,CONVERT(varchar(max),UM.Descript)
					FROM	[SitMesDB].[dbo].MMvBomItemAltPrpVals AS BIAPV WITH (NOLOCK) INNER JOIN
							[SitMesDB].[dbo].MMBomItemAlts AS BIA WITH (NOLOCK) ON BIA.BomItemAltPK = BIAPV.BomItemAltPK INNER JOIN
							[SitMesDB].[dbo].MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = BIA.DefPK INNER JOIN
							[SitMesDB].[dbo].MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BIAPV.PropertyPK AND (P.IsSpecial = 0 OR
							P.VisibleOnRT = 1) INNER JOIN
							[SitMesDB].[dbo].MMPrpGroups AS PG WITH (NOLOCK) ON PG.PrpGroupPK = P.PrpGroupPK INNER JOIN
							[SitMesDB].[dbo].MESUoMs AS UM WITH (NOLOCK) ON UM.UomPK = P.UoMPK  
					WHERE   DefID=@SelectedPart
					AND CONVERT(varchar(max),P.PropertyID)<>'MES_ONLY'
			END
			SELECT @intStartRow=@intStartRow+1
		END

		UPDATE @ItemProperty
		SET UoM=''
		WHERE UoM='n/a'

		SELECT [PartNo] as [Part No], [Description] as [Property],[Value],[UoM] FROM @ItemProperty

END




GO
