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
CREATE  PROCEDURE [dbo].[SSB_Web_GetMachinesCTQ]	
AS
 

----------------------------------Declare Variables and Tables----------------------
DECLARE	@tblMCLists AS Table	(	RowId			int	IDENTITY	,
									Machines		nvarchar(255)	,
									Sequence		int				)

INSERT INTO @tblMCLists (Machines,Sequence)
	SELECT [PS_LabelName],
		   [PS_Seq]
	FROM [SitMesDB].[dbo].[PDefM_PS] PS
		INNER JOIN [SitMesDB].[dbo].[PDefM_PS_Param] PAR ON PS.PS=PAR.Param_PS
	WHERE PS.PS_PPR='SSB_CML'
		AND PAR.Param_Name Like 'QUALITY_%'
	ORDER BY PS.PS_Seq ASC

SELECT DISTINCT Machines FROM @tblMCLists
GO
