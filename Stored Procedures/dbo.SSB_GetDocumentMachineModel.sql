SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Equipments assigned to the Terminal

  Output Parameters:
	List of Machines

  Input Parameters:
	@TerminalName - User Logged in/selected Terminal Name


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

CREATE  PROCEDURE [dbo].[SSB_GetDocumentMachineModel]
		@DocID			int
AS
 
----------------------------------Declare Variables and Tables----------------------
SELECT	UG.Description		
FROM [SSB].[dbo].[SSB_UnitGroup] UG
	INNER JOIN [SSBWebPortal].[dbo].[SSB_DocMachineMap] DM on DM.MacinePK=UG.pk
WHERE DM.DocumentPk=@DocID
GO
