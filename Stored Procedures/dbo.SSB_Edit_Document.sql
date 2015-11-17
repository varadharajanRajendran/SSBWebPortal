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

CREATE  PROCEDURE [dbo].[SSB_Edit_Document]
		@MachineID		int				,
        @MachineDesc	nvarchar(255)	,
		@FilePath		nvarchar(1000)	,
		@FileType		nvarchar(1000)	,
		@DocGroup		nvarchar(255)	,
		@Model			nvarchar(2000)	,	
		@ActiveUser		nvarchar(255)	
AS
 
----------------------------------Declare Variables and Tables----------------------
DECLARE @DocLifeCycleID int,
		@ModelID		int,
		@DocGroupID		int	,
		@CurrentDateTime	datetime

DECLARE	@tblMachineMode AS Table	(	RowId					int	IDENTITY	,
									    MachineModelName		nvarchar(2000)	)
--SELECT @DocLifeCycleID=[pk]
--FROM [SSB].[dbo].[SSB_DBLifeCycle]
--WHERE [Description]=@DocLifeCycle

SELECT @ModelID=[pk]
FROM [SSB].[dbo].[SSB_UnitGroup]
WHERE [Description]=@MachineDesc

SELECT @DocGroupID	=[pk]
FROM [SSBWebPortal].[dbo].[SSB_DocProcessGroup]
WHERE [Description]=@DocGroup

SELECT @CurrentDateTime=GETDATE()

UPDATE [SSBWebPortal].[dbo].[SSB_DocMgmt]
   SET	[Description]		=	@MachineDesc			,
		[FilePath]			=	@FilePath				,
		[DocProcessGroup]	=	@DocGroupID				,
		[UnitGroup]			=	''						,
		[Status]			=	'2'						,
		[ModifiedDataTime]	=	@CurrentDateTime		,
		[ModifiedBy]		=	@ActiveUser				,
		[Comments]			=	@Model
  WHERE pk= @MachineID

 DELETE FROM [SSBWebPortal].[dbo].[SSB_DocMachineMap]
 WHERE DocumentPK=@MachineID


INSERT INTO @tblMachineMode (MachineModelName)
	SELECT value FROM [ssbwebportal].dbo.Splittext(@Model)

INSERT INTO [SSBWebPortal].[dbo].[SSB_DocMachineMap] ( [DocumentPK] ,[MacinePK] ,[CreatedDataTime] ,[CreatedBy])
	SELECT	@MachineID		,
			UG.pk				,
			@CurrentDateTime	,
			@ActiveUser			
	FROM [SSB].[dbo].[SSB_UnitGroup] UG
		INNER JOIN @tblMachineMode MC on MC.MachineModelName COLLATE SQL_Latin1_General_CP1_CI_AS =UG.[Description]
	WHERE (@MachineID	IS NOT NULL 
		AND @MachineID	<>'')
GO
