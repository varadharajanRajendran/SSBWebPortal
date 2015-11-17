SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Equipments assigned to the Terminal

  Output Parameters:
	List of Machines by Decription

  Input Parameters:
	NULL


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
CREATE PROCEDURE [dbo].[SSB_Get_Documents]		
AS
 
SELECT  DM.[pk] as [ID]
      , DM.[Description] as [Description]
      , DM.[FilePath] as [FilePath]
	  , DPG.[Description] as [DocumentGroup]
      , DM.[FileType] as [FileType]
	  , DM.Comments as [note]
FROM [SSBWebPortal].[dbo].[SSB_DocMgmt] as DM
INNER JOIN [SSBWebPortal].[dbo].[SSB_DocProcessGroup] as DPG ON DPG.pk=DM.DocProcessGroup
GO
