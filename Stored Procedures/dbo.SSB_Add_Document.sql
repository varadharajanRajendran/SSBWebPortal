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
CREATE  PROCEDURE [dbo].[SSB_Add_Document]
			 @MachineDesc	nvarchar(255)	,
			@FilePath		nvarchar(1000)	,
			@DocGroup		nvarchar(255)	,
			@Model			nvarchar(2000)	,
			@FileType		nvarchar(255)	,
			@ActiveUser		nvarchar(255)	
AS

/* 
 SELECT @MachineDesc = 'Test Server',
		@FilePath = 'abc',
		@DocGroup = 'abc',
		@Model = 'FEC,MU,Ribbon',
		@FileType = 'PDF',
		@ActiveUser = 'test'
*/

----------------------------------Declare Variables and Tables----------------------
DECLARE @DocLifeCycleID		int		,
		@ModelID			int		,
		@DocGroupID			int		,
		@DocumentPk			int		,
		@CurrentDateTime	datetime

DECLARE	@tblMachineMode AS Table	(	RowId					int	IDENTITY	,
									    MachineModelName		nvarchar(2000)	)

/*
SELECT @ModelID=[pk]
FROM [SSB].[dbo].[SSB_UnitGroup]
WHERE [Description]=@Model
*/

SELECT @DocGroupID	=[pk]
FROM [SSBWebPortal].[dbo].[SSB_DocProcessGroup]
WHERE [Description]=@DocGroup

SELECT @CurrentDateTime=GETDATE()				

INSERT INTO [SSBWebPortal].[dbo].[SSB_DocMgmt] ([Description],[FilePath],[DocProcessGroup],[UnitGroup],[FileType],[Status],[Comments],[CreatedDataTime],[CreatedBy])
   VALUES (	@MachineDesc			,
			@FilePath				,
			@DocGroupID				,
			''						,
			@FileType				,
			'2'						,
			@Model					,
			@CurrentDateTime		,
			@ActiveUser				)

SELECT @DocumentPk=pk
FROM [SSBWebPortal].[dbo].[SSB_DocMgmt] 
WHERE [CreatedDataTime]=@CurrentDateTime

SELECT @DocumentPk

INSERT INTO @tblMachineMode (MachineModelName)
	SELECT value FROM [ssbwebportal].dbo.Splittext(@Model)

INSERT INTO [SSBWebPortal].[dbo].[SSB_DocMachineMap] ( [DocumentPK] ,[MacinePK] ,[CreatedDataTime] ,[CreatedBy])
	SELECT	@DocumentPk			,
			UG.pk				,
			@CurrentDateTime	,
			@ActiveUser			
	FROM [SSB].[dbo].[SSB_UnitGroup] UG
		INNER JOIN @tblMachineMode MC on MC.MachineModelName COLLATE SQL_Latin1_General_CP1_CI_AS =UG.[Description]
	WHERE (@DocumentPk	IS NOT NULL 
		AND @DocumentPk	<>'')

GO
