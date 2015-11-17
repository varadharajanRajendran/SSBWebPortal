SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_Web_UpdateQualityCTQ]
		@MachineName			nvarchar(255)	,
		@QualityParamID			nvarchar(255)	,
		@Description			nvarchar(255)	,
		@UoM					nvarchar(32)	,
		@LowLow					nvarchar(1000)	,
		@Low					nvarchar(1000)	,
		@Target					nvarchar(1000)	,
		@High					nvarchar(1000)	,
		@HighHigh				nvarchar(1000)	,
		@Frequency				float			,
		@FrequencyUoM			nvarchar(32)	,
		@DataCollection			int				,
		@ValueSpecification		nvarchar(255)	
AS
 

----------------------------------Declare Variables and Tables----------------------
DECLARE @VersionID		nvarchar(20)	,
		@Param_Type		nvarchar(50)	,
		@Data_Intrprtn	nvarchar(255)	,
		@PK				int				,
		@MachineID		nvarchar(255)	,
		@PVnum			int


    SELECT @MachineID =  REPLACE(PS.[PS],'*0001.00','')
	FROM [SitMesDB].[dbo].[PDefM_PS] PS
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
	WHERE PS.PS_PPR='SSB_CML'
		AND PAR.Param_Name Like 'QUALITY_%'
		AND PS_LabelName =@MachineName


IF @ValueSpecification='Product'
	BEGIN
		SELECT @Data_Intrprtn='Product'
	END
ELSE
	BEGIN
		SELECT @Data_Intrprtn='Fixed'
	END


SELECT  TOP 1 @VersionID=Param_PPRVersion
FROM  [SitMesDB].[dbo]. PDefM_PS_Param 
WHERE Param_PS LIKE '%' + @MachineID + '%'
	AND Param_PPR = 'SSB_CML'
ORDER BY Param_PPRVersion DESC

SELECT @PK=[PK],
		@PVnum=[Param_ValuesLink]
FROM  [SitMesDB].[dbo]. PDefM_PS_Param 
WHERE Param_PPR = 'SSB_CML'
		AND [Param_PPRVersion]=@VersionID
		AND [Param_Name]=@QualityParamID
		AND [Param_PS] LIKE '%' + @MachineID + '%'


UPDATE [SitMesDB].[dbo].[PDefM_PS_Param]
	SET [Param_Desc]=@Description			,
		[Param_Mandatory]=@DataCollection	,
		[Param_UOM]=@UoM					,
		[LOW_MIN]=@LowLow					,
		[HIGH_MAX]=@HighHigh				,
		[FRQY]	=@Frequency					,
		[FRQY_UOM]=@FrequencyUoM			,
		[DATA_INTRPRTN]=@Data_Intrprtn		,
		[RowUpdated]=GETDATE()
WHERE Param_PPR = 'SSB_CML'
		AND [Param_PPRVersion]=@VersionID
		AND [Param_Name]=@QualityParamID
		AND [Param_PS] LIKE '%' + @MachineID + '%'
		

UPDATE [SitMesDB].[dbo].[PDefM_PS_ParamValues]
	SET [ParamValues_MinVal]=@Low		,
	    [ParamValues_MaxVal]=@High		,	
        [ParamValues_Target]=@Target	,
        [RowUpdated]		=GETDATE()
WHERE [ParamValues_Num]=@PVnum
GO
