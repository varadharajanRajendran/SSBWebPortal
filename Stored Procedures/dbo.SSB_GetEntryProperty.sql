SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get Entry Property

  Output Parameters:
	List of Property

  Input Parameters:
	@PPR_ID				- Production Rule ID from Order
	@PPR_Version		- PPR Version Number
	@PS					- Product Segment
	@DisplaySelectedFields	- Display All Properties

  Trigger:
	From web Portal

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
CREATE  PROCEDURE [dbo].[SSB_GetEntryProperty]
		@PPR_ID				nvarchar(255)	,
	    @PPR_Version		nvarchar(255)	,
		@PS					nvarchar(255)	,
		@DisplaySelectedFields	bit
AS
        


DECLARE @intStartRow int			,
        @intEndRow int				,
        @intelProc int				,
        @PropertyDesc nvarchar(255) ,
        @MNDT		  nvarchar(2)

DECLARE	@SegmentProperty AS Table	(	RowId				int	IDENTITY	,
										[Description]		nvarchar(255)	,
										[Value]				nvarchar(255)	,
										[UoM]				nvarchar(255)	,
										[DisplayinWeb]		nvarchar(2)	)



INSERT INTO @SegmentProperty ([Description],[Value],[UoM])	
	SELECT [DSC]	,
		   [VAL]	,
		   [UOM]	
	FROM [SitMesDB].[dbo].[PDMT_PS_PRP]
	WHERE PPR=@PPR_ID
		AND PPR_VER= @PPR_Version
		AND PS like '%' + @PS	+ '%'
	 ORDER BY [SEQ] ASC

IF @DisplaySelectedFields='0'
BEGIN
	 SELECT		@intStartRow=	min(RowId)	,
				@intEndRow	=	max(RowId)	
	 FROM	@SegmentProperty 
    
	 WHILE	@intStartRow <=	@intEndRow	
	 BEGIN
	 	SELECT @PropertyDesc=[Description] 
		FROM @SegmentProperty
		WHERE RowId=@intStartRow
	 
	 	SELECT @MNDT= MNDT
		FROM [SitMesDB].[dbo].[PDMT_PS_PRP]
		WHERE PPR = 'SSB_CML'
		  AND  PPR_VER = '0001.00' 
		  AND PS LIKE '%' + @PS +'%'
		  AND DSC=@PropertyDesc


		UPDATE @SegmentProperty
			SET [DisplayinWeb]=@MNDT
		WHERE RowId=@intStartRow
	 
		SELECT @intStartRow=@intStartRow + 1
	 END

	 SELECT [Description],[Value],[UoM]	
	 FROM @SegmentProperty 
	 WHERE [DisplayinWeb]='1'
END
ELSE
BEGIN
	 SELECT [Description],[Value],[UoM]	
	 FROM @SegmentProperty 
END
GO
