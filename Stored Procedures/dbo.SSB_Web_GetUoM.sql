SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get Unit of Measure by Category

  Output Parameters:
	List of UoM

  Input Parameters:
	@Category - UoM Category


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
CREATE PROCEDURE [dbo].[SSB_Web_GetUoM]
AS
 

SELECT [UomID] as UOM
FROM [SitMesDB].[dbo].[MESUoMs]
WHERE UoMID<>'MESYear'
	AND UoMID<>'MESMonth'
GO
