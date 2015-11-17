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
CREATE PROCEDURE [dbo].[SSB_Web_GetInspectionQualityCheckList]
		@OrderID	nvarchar(255)	
AS
 

SELECT	PS.[seq] as [SequenceNo]				,
		PS.[GRP] as [GroupID]					,
        PS.[description] as [Description]		,
        PS.[type] as [DataType]					,
		PS.Pom_process_segment_parameter_pk as [ID]
  FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]  PS
	INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY] PE ON PE.[pom_entry_pk]=PS.[pom_entry_pk]
	INNER JOIN  [SitMesDB].[dbo].[POM_ORDER] PO on PO.[pom_order_pk]=PE.[pom_order_pk]
  WHERE PE.PS_name='Inspection1'
	AND PO.[pom_order_id]=@OrderID
  ORDER BY seq ASC
GO
