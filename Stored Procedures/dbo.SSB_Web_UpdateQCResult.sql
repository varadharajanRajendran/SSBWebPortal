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
CREATE PROCEDURE [dbo].[SSB_Web_UpdateQCResult]
		@ID	nvarchar(255)			,
		@QCResult	nvarchar(255)	
AS
 


DECLARE @CTQResult		nvarchar(255)	,
        @oldValue		nvarchar(255)	,
		@newValue		nvarchar(255)	,
		@Result			nvarchar(255)

IF @QCResult=LOWER('pass') 
	BEGIN
		SELECT  @CTQResult=1
	END
ELSE IF @QCResult=LOWER('fail') 
	BEGIN
		SELECT  @CTQResult=0
	END
ELSE
BEGIN
	SELECT @CTQResult=@QCResult
END

IF @CTQResult is NOT NULL
	BEGIN
		UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] 
		SET [value]=@CTQResult,
			RowUpdated=GETDATE()
		WHERE Pom_process_segment_parameter_pk=@ID

		UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] 
			SET default_val=CONVERT(numeric,PoRT.VAL) FROM [SitMesDB].[dbo].[POM_CUSTOM_FIELD_RT] PoRT
				INNER JOIN [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] Parm on parm.pom_entry_pk=PoRT.pom_entry_pk
			WHERE Parm.name=REPLACE(PoRT.pom_custom_fld_name,'PROD_','QUALITY_')
				AND Parm.pom_entry_pk='192337'
				AND Parm.Pom_process_segment_parameter_pk=@ID

		SELECT @Result= '1'
	END
ELSE
	BEGIN
		SELECT @Result= '0'
	END
SELECT @Result as Result

/*
	SELECT PoRT.VAL FROM [SitMesDB].[dbo].[POM_CUSTOM_FIELD_RT] PoRT
		INNER JOIN [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER] Parm on parm.pom_entry_pk=PoRT.pom_entry_pk
	WHERE Parm.name=REPLACE(PoRT.pom_custom_fld_name,'PROD_','QUALITY_')
		AND Parm.pom_entry_pk='192337'
*/








GO
