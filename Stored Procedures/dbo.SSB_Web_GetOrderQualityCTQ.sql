SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_Web_GetOrderQualityCTQ]
		@OrderID	nvarchar(255)		,
		@MachineID	nvarchar(255)	
AS
 
----------------------------------Declare Variables and Tables----------------------
DECLARE @OrderQC as Table (	[pom_process_segment_parameter_pk] int	,
								[pom_entry_pk]	int				,
								[seq]			int				,
								[name]			nvarchar(255)	,
								[description]	nvarchar(255)	,
								[type]			nvarchar(50)	,
								[min_val]		nvarchar(1000)	,
								[max_val]		nvarchar(1000)	,
								[LOW_MIN]		nvarchar(1000)	,
								[HIGH_MAX]		nvarchar(1000)	,
								[default_val]	nvarchar(1000)	,
								[mandatory]		int				,
								[uom]			int				,
								[GBL_PARM_PK]	int				,
								[GRP]			nvarchar(50)	,
								[VLD]			nvarchar(50))
	
DECLARE @RefQC as Table (RowID int IDENTITY,
						 [name]				nvarchar(255)	,
						 [description]		nvarchar(255)	,
						 [type]				nvarchar(50)	,
						 [UoM]				nvarchar(50)	,			
						 [LowLow]			nvarchar(1000)	,
						 [Low]				nvarchar(1000)	,
						 [Target]			nvarchar(1000)	,
						 [High]				nvarchar(1000)	,
						 [HighHigh]			nvarchar(1000)	,
						 [Freq]				int				,
						 [FreqUoM]			nvarchar(255)	,
						 [Datacollection]	nvarchar(255)	,				
						 [Valuespec]	    nvarchar(50)	,
						 [SamplingMethod]		nvarchar(10)	)

DECLARE @FinalQC as Table (		RowID								int IDENTITY	,
								[pom_process_segment_parameter_pk]	int				,
								[pom_entry_pk]						int				,
								[seq]								int				,
								[description]						nvarchar(255)	,
								[type]								nvarchar(50)	,
								[UoM]								nvarchar(50)	,			
								[LowLow]							nvarchar(1000)	,
								[Low]								nvarchar(1000)	,
								[Target]							nvarchar(1000)	,
								[High]								nvarchar(1000)	,
								[HighHigh]							nvarchar(1000)	,
								[Datacollection]					bit				,
								ResultCTQ							nvarchar(255))

 DECLARE @intStartRow		int					,
         @intEndRow			int					,
         @intelProc			int					,				
		 @Selname			nvarchar(255)		,
		 @Seldescription	nvarchar(255)		,
		 @Seltype			nvarchar(50)		,
		 @SelUoM			nvarchar(50)		,				
		 @SelLowLow			nvarchar(1000)		,
		 @SelLow			nvarchar(1000)		,
		 @SelTarget			nvarchar(1000)		,
		 @SelHigh			nvarchar(1000)		,
		 @SelHighHigh		nvarchar(1000)		,
		 @SelFreq			int					,
		 @SelFreqUoM		nvarchar(255)		,
		 @SelDatacollection	bit					,
		 @SelValuespec		nvarchar(50)		,
		 @SelPSR			int					,
		 @Selpom_entry_pk	int					,
		 @Selseq			int					,
		 @SelQCCtype		nvarchar(50)		,
		 @RefLowLow			nvarchar(1000)		,
		 @RefLow			nvarchar(1000)		,
		 @RefTarget			nvarchar(1000)		,
		 @RefHigh			nvarchar(1000)		,
		 @RefHighHigh		nvarchar(1000)		,
		 @POTarget			nvarchar(1000)		,	
		 @MachineName		nvarchar(1000)		,		
		 @EqID				nvarchar(255)		,
		 @EntryID			int					,		
		 @Ps_Name			nvarchar(255)	

		
 SELECT @EqID			=	Eq.equip_id		,
	    @EntryID		=	PoE.pom_entry_pk	,
		@MachineName	=	REPLACE(PS.PS,'*0001.00','')
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]
	WHERE PS.PS_PPR='SSB_CML'
		AND PT.[id] like '%'+ @MachineID
		AND Po.pom_order_id =@OrderID


		
SELECT  @Ps_Name =PS_LabelName
FROM [SitMesDB].[dbo].[PDefM_PS] PS
	INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
WHERE PS.PS_PPR='SSB_CML'
	AND PAR.Param_Name Like 'QUALITY_%'
	AND REPLACE(PS.[PS],'*0001.00','')= @MachineName





INSERT INTO @RefQC ([name],[description],[type]	,[UoM]	,[LowLow],[Low],[Target],[High],[HighHigh],[Freq],[FreqUoM],[Datacollection],[Valuespec],SamplingMethod)	
	EXEC [dbo].[SSB_Web_GetQualityCTQ] @Ps_Name
	


INSERT INTO  @OrderQC
  SELECT	PS.[pom_process_segment_parameter_pk],
			PS.[pom_entry_pk],
			PS.[seq],
			PS.[name],
			PS.[description],
			PS.[type],
			PS.[min_val],
			PS.[max_val],
			PS.[LOW_MIN],
			PS.[HIGH_MAX],
			PS.[default_val],
			PS.[mandatory],
			PS.[uom],
			PS.[GBL_PARM_PK],
			PS.[GRP],
			PS.[VLD]
  FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]  PS
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE ON PE.[pom_entry_pk]=PS.[pom_entry_pk]
	INNER JOIN  [SitMesDB].[dbo].[POM_ORDER] PO on PO.[pom_order_pk]=PE.[pom_order_pk]
  WHERE PO.[pom_order_id]=@OrderID
	AND PE.PS_name=@MachineName +'1'
  ORDER BY seq ASC

SELECT		@intStartRow=	min(RowId)	,
			@intEndRow	=	max(RowId)	
FROM	@RefQC 
    
WHILE	@intStartRow <=	@intEndRow	
	 BEGIN
		SELECT	@Selname				=	[name]			,
				@Seldescription			=	[description]	,
				@Seltype				=	[type]			,
				@SelUoM					=	[UoM]			,			
				@RefLowLow				=	[LowLow]		,
				@RefLow					=	[Low]			,
				@RefTarget				=	[Target]		,
				@RefHigh				=	[High]			,
				@RefHighHigh			=	[HighHigh]		,
				@SelValuespec			=	[Valuespec]		,
				@SelDatacollection = CASE [Datacollection]
					WHEN 'Enable' THEN 
						'1'
					ELSE
						'0'
				END
		FROM @RefQC
		WHERE RowID=@intStartRow
		
		SELECT @SelPSR				=	[pom_process_segment_parameter_pk]	,
			   @Selpom_entry_pk		=	[pom_entry_pk]						,
			   @Selseq				=	[seq]								,
			   @POTarget			=	ISNULL([default_val],0)	
		FROM @OrderQC
		WHERE [name]=@selname

		IF @POTarget = '' OR @POTarget IS NULL
			BEGIN
				SELECT @POTarget=0
			END
		IF @SelValuespec='Fixed'
			BEGIN
				SELECT  @SelLowLow		=	@RefLowLow		,
						@SelLow			=	@RefLow			,
						@SelTarget		=	@RefTarget		,
						@SelHigh		=	@RefHigh		,
						@SelHighHigh	=	@RefHighHigh
			END
		ELSE 
			BEGIN
				IF @RefLowLow='' OR @RefLowLow IS NULL
						BEGIN
							SELECT @SelLowLow=@POTarget
						END
					ELSE
						BEGIN
							SELECT @SelLowLow=CONVERT(Decimal(10,4),@RefLowLow)+ CONVERT(Decimal(10,4),@POTarget)	
						END
			
				IF @RefLow='' OR @RefLowLow IS NULL
						BEGIN
							SELECT @SelLow=@POTarget
						END
					ELSE
						BEGIN
							SELECT @SelLow=CONVERT(Decimal(10,4),@RefLow)+ CONVERT(Decimal(10,4),@POTarget)	
						END
				
				IF @RefHighHigh='' OR @RefHighHigh IS NULL
						BEGIN
							SELECT @SelHighHigh=@POTarget
						END
					ELSE
						BEGIN
							SELECT @SelHighHigh=CONVERT(Decimal(10,4),@RefHighHigh)+ CONVERT(Decimal(10,4),@POTarget)	
						END
			
				IF @RefHigh='' OR @RefHigh IS NULL
						BEGIN
							SELECT @SelHigh=@POTarget
						END
					ELSE
						BEGIN
							SELECT @SelHigh=CONVERT(Decimal(10,4),@RefHigh)+ CONVERT(Decimal(10,4),@POTarget)	
						END

				SELECT @SelTarget		=   @POTarget	
			END
		
		IF ((@SelLowLow ='')
			AND (@SelLow ='')
			AND (@SelTarget ='')
			AND (@SelHigh ='')
			AND (@SelHighHigh =''))
			BEGIN
				SELECT @Seltype='BOOL'
			END
		ELSE
			BEGIN
				SELECT @Seltype='VALUE'
			END

		INSERT INTO @FinalQC (  [pom_process_segment_parameter_pk]	,
								[pom_entry_pk]						,
								[seq]								,
								[description]						,
								[type]								,
								[UoM]								,			
								[LowLow]							,
								[Low]								,
								[Target]							,
								[High]								,
								[HighHigh]							,
								[Datacollection]					)
				    VALUES (	@SelPSR								,
							    @Selpom_entry_pk					,
								@Selseq								,
								@Seldescription						,
								@Seltype							,
								REPLACE(@SelUoM,'n/a','')			,
								@SelLowLow							,
								@SelLow								,
								@SelTarget							,
								@SelHigh							,
								@SelHighHigh						,
								@SelDatacollection					)
		
		SELECT @intStartRow=@intStartRow+1
	 END	
 

 SELECT [Description] as [Description]					,
        [Type]  as [DataType]							,
		[UoM]											,
		Round([LowLow],3) as [LowLow]					,
		Round([Low]	,3)	as [Low]						,
		Round([Target]	,3) as [Target]					,
		Round([High],3)	as [High]						,
		Round([HighHigh],3)	as [HighHigh]				,
		[pom_process_segment_parameter_pk] as [PPR_Seg] ,
		ResultCTQ
FROM @FinalQC
WHERE Datacollection=1
ORDER BY seq ASC


SELECT  Po.[pom_order_id] as [OrderID],
			ML.[def_id] as [Sub-Assembly],
		    MD.Descript as [Description]
FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po  on Pe.pom_order_pk=Po.pom_order_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT	on PT.pom_entry_type_pk= Pe.pom_entry_type_pk
		INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq On Pe.equip_pk=Eq.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] PMs ON PMS.[pom_entry_pk]=Pe.[pom_entry_pk]
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] ML ON ML.pom_material_specification_pk=PMs.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD on MD.DefID=ML.def_id
 WHERE PO.[pom_order_id]=@OrderID
	AND PE.PS_name=@MachineName +'1'
		AND PMs.[name]='PRODUCED'
GO
