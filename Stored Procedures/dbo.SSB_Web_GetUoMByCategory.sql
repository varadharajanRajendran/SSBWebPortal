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
CREATE PROCEDURE [dbo].[SSB_Web_GetUoMByCategory]
		@Category	nvarchar(255)	
AS
 
 IF @Category='TIME'
	BEGIN
		SELECT [UomID] as FrequencyUoM
		FROM [SitMesDB].[dbo].[MESUoMs]
		WHERE Category=@Category
			AND UoMID<>'MESYear'
			AND UoMID<>'MESMonth'
	END
ELSE IF @Category='COUNT'
	BEGIN
		SELECT [UomID] as FrequencyUoM
		FROM [SitMesDB].[dbo].[MESUoMs]
		WHERE Category='n/a'
			AND UoMID='Count'
	END
ELSE
	BEGIN
		SELECT [UomID] as FrequencyUoM
		FROM [SitMesDB].[dbo].[MESUoMs]
		WHERE Category=@Category
	END
GO
