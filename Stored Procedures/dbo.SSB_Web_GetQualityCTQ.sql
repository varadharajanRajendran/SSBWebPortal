SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of CTQ's by Machines

  Output Parameters:
	List of CTQ's by Machines

  Input Parameters:
	@Machine Name - Production Unit Name


  Trigger:
	From SSB Web Portal

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
  11/12/2014	Varadharajan R	C00V00 - Intial code
  
  
*/
CREATE PROCEDURE [dbo].[SSB_Web_GetQualityCTQ]
		@MachineName	nvarchar(255)	
AS
 

----------------------------------Declare Variables and Tables----------------------
DECLARE @VersionID nvarchar(255),
        @MachineID nvarchar(255)
   /* 
	    ,@MachineName nvarchar(255)
	
	
	SELECT @MachineName='PanelQuilt'
	*/

    SELECT @MachineID =  REPLACE(PS.[PS],'*0001.00','')
	FROM [SitMesDB].[dbo].[PDefM_PS] PS
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
	WHERE PS.PS_PPR='SSB_CML'
		AND PAR.Param_Name Like 'QUALITY_%'
		AND PS_LabelName =@MachineName


SELECT  TOP 1 @VersionID=Param_PPRVersion
FROM  [SitMesDB].[dbo]. PDefM_PS_Param 
WHERE Param_PS LIKE '%' + @MachineID + '%'
	AND Param_PPR = 'SSB_CML'
ORDER BY Param_PPRVersion DESC

SELECT  PM.[Param_Name]				AS [ID]					, 
	    PM.[Param_Desc]				AS [Description]		, 
		CASE(PM.[Param_Type])	
			WHEN 'TRUTH-VALUE'  THEN 'Attribute'
			WHEN 'FLOAT'		THEN 'Variable'
			ELSE PM.[Param_Type]
		END
									AS [CollectionType]		, 
		PM.[Param_UOM]				AS [UoM]				, 
		PM.[LOW_MIN]				AS [LowLow]				,
		PV.[ParamValues_MinVal]		AS [Low]				, 
		PV.[ParamValues_Target]		AS [Target]				, 
		PV.[ParamValues_MaxVal]		AS [High]				, 
		PM.[HIGH_MAX]				AS [HighHigh]			,
		PM.[FRQY]					AS [Frequency]			, 
		PM.[FRQY_UOM]				AS [FrequencyUoM]		,
		CASE(PM.[Param_Mandatory])	
			WHEN '1'  THEN 'Enable'
			ELSE 'Disable'
		END
			AS [DataCollection]								,
				
		CASE(PM.[DATA_INTRPRTN])	
			WHEN 'Product'  THEN 'Product'
			ELSE 'Fixed'
		END
			AS [ValueSpecification]							,	
		CASE(PM.[FRQY_UOM])	
			WHEN 'Count'  THEN 'Count'
			ELSE 'Time'
		END
			AS [SamplingMethod]	
FROM  [SitMesDB].[dbo]. PDefM_PS_Param AS PM
	INNER JOIN [SitMesDB].[dbo].[PDefM_PS_ParamValues] as PV ON PV.[ParamValues_Num]=PM.Param_ValuesLink
WHERE PM.Param_PS LIKE  '%' + @MachineID + '%'
	AND PM.Param_PPR = 'SSB_CML'
	AND PM.Param_PPRVersion=@VersionID
	AND PM.Param_Desc <> 'Quality Log Status'
ORDER BY Param_PPRVersion DESC


GO
