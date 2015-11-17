SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get List of Document for the Selected Equipment

  Output Parameters:
	Document Table

  Input Parameters:
	@Machine Name -User Selected machine name


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
CREATE PROCEDURE [dbo].[SSB_Web_GetSafetyDocumentsbyTerminal]
	@TerminalName		nvarchar(50)
AS
 

----------------------------------Declare Variables and Tables----------------------


SELECT @TerminalName='WC18'

 ----------------------------------Declare Variables and Tables----------------------
DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @MachineID		int				,
		@Machinemodel nvarchar(255)

DECLARE	@Machines AS Table	(	RowId			int	IDENTITY	,
								MachineID		int				)	


DECLARE	@tblDocument AS Table	(	RowId			int	IDENTITY	,
									Category		nvarchar(50)	,		
									FileDescription nvarchar(100)	,
									FilePath		nvarchar(255)	,
									FileType		nvarchar(10)	)

/* Get Equipments assigned to the Terminal */
INSERT INTO	@Machines (MachineID)
	 SELECT [equip_pk]
	 FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
	 WHERE equip_prpty_id ='Terminalname' 
		  AND equip_prpty_value=@TerminalName
		  
SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@Machines 
    
/* Get Equipment Name from Equipment ID*/
WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @MachineID=MachineID 
	FROM @Machines 
	WHERE RowId=@intStartRow
	
/* Find Machine Model */
	SELECT @Machinemodel=EP.equip_prpty_value
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] E
	INNER JOIN [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
	ON E.equip_pk=Ep.equip_pk
	WHERE E.equip_pk= @MachineID
	AND EP.equip_prpty_id='MACHINE_MODEL'

 /* Get List of Documents */
 INSERT INTO @tblDocument(Category,FileDescription,FilePath,FileType)
	SELECT  PG.[Description] as Category, DM.[Description] as FileDescription ,DM.[FilePath] as FilePath,DM.[FileType] as FileType
	FROM [SSB].[dbo].[SSB_DocMgmt] DM
	INNER JOIN [SSB].[dbo].[SSB_DocProcessGroup] PG On DM.DocProcessGroup=PG.pk
	INNER JOIN [SSB].[dbo].[SSB_UnitGroup] UG ON DM.UnitGroup=UG.pk
	WHERE DM.[Status]=2 
	 AND  UG.[Description]=@Machinemodel
	 AND  PG.[Description] ='Safety'
	ORDER BY PG.[Description] ASC

		
	SELECT	@intStartRow	=	@intStartRow	+	1
END

SELECT DISTINCT(FilePath),Category,FileDescription,FileType FROM @tblDocument
GO
