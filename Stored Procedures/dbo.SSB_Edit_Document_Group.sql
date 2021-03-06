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
CREATE  PROCEDURE [dbo].[SSB_Edit_Document_Group]	
	@ID				int				,
	@Description	nvarchar(255)	,
	@Sequence		int				
AS
 
UPDATE [SSBWebPortal].[dbo].[SSB_DocProcessGroup]
	SET [Description]=@Description,
		[Sequence]	 =@Sequence			
	WHERE pk=@ID
GO
