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
CREATE PROCEDURE [dbo].[SSB_CheckTimetoQCTest]
		@OrderID	nvarchar(255)			,
		@MachineID	nvarchar(255)
AS
 
 DECLARE @PS				nvarchar(255)	,
		 @EqID				nvarchar(255)	,
		 @Freq				decimal(5,2)	,
		 @TimeDiff			decimal(5,2)	,
		 @LastSampleTime	nvarchar(255)	,
		 @ParmCounter		int				,
		 @EntryID			int				,
		 @EqPK				int
/*
		 ,@OrderID			nvarchar(50)	,
		 @MachineID			nvarchar(255)	,
SELECT @MachineID='MCCH',
		@OrderID ='107931002'
*/

SELECT @ParmCounter=COUNT([Param_Desc])
  FROM [SitMesDB].[dbo].[PDefM_PS_Param]
  WHERE Param_PPR='SSB_CML'
	AND Param_PS like '%'+ @MachineID	 + '%'
	AND Param_Name like 'QUALITY%'


IF @ParmCounter>0 
BEGIN
	SELECT @EqID	 = Eq.equip_id,
		   @EntryID	 = PoE.pom_entry_pk
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]
	WHERE PoE.[pom_entry_id] like '%'+ @MachineID	 + '%'
		AND Po.pom_order_id =@OrderID
	
	SELECT @Freq=EP.equip_prpty_value,
		   @EqPK=E.equip_pk
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] E ON E.equip_pk=EP.equip_pk
	WHERE EP.equip_prpty_id ='Sample_Frequency' 
		AND E.equip_id =@EqID
 
	SELECT @LastSampleTime=EP.equip_prpty_value
	FROM [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY] EP
		INNER JOIN  [SitMesDB].[dbo].[BPM_EQUIPMENT] E ON E.equip_pk=EP.equip_pk
	WHERE EP.equip_prpty_id ='Last_Sample_Time' 
		AND E.equip_id =@EqID
 
	

	IF @LastSampleTime='' OR @LastSampleTime IS NULL 
		BEGIN
			
			/*  ACTION ITEMS : Update QC set Points */

			UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
						SET VALUE=1
						WHERE pom_entry_pk=@EntryID
							AND name ='TimetoCTQ'	
			
			UPDATE [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
				SET equip_prpty_value=GETDATE()
				WHERE equip_pk=@EqPK
					AND equip_prpty_id ='Last_Sample_Time' 

			/*  ACTION ITEMS : Update Sampling Interval */

		END
	ELSE
		BEGIN
			SELECT @TimeDiff=DATEDIFF(MINUTE,@LastSampleTime,GETDATE())
			IF @TimeDiff>=@Freq
				BEGIN
					
					/* ACTION ITEMS : Update QC set Points */

					UPDATE [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]
						SET VALUE=1
						WHERE pom_entry_pk=@EntryID
							AND name ='TimetoCTQ'	
					
					UPDATE [SitMesDB].[dbo].[BPM_EQUIPMENT_PROPERTY]
						SET equip_prpty_value=GETDATE()
						WHERE equip_pk=@EqPK
							AND equip_prpty_id ='Last_Sample_Time' 

					/* ACTION ITEMS : Update Sampling Interval */
			END
		END
END




GO
