SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		R. Krishna Prasadh (with the Help of Varadha
-- Create date: December 10, 2014
-- Description:	Return if an Order has Rework/Scrap status
-- =============================================
CREATE FUNCTION [dbo].[SSB_Web_GetOrderStatus] 
(
	-- Add the parameters for the function here
	@OrderID NVARCHAR(MAX)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
    
	DECLARE @Scrap	int	, 
		@Rework int	,
		@Result int

	SELECT @Scrap=COUNT(a.[pom_entry_id])
		  FROM [SitMesDB].[dbo].[POM_ENTRY] a
	  JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] b ON
	  a.pom_entry_status_pk = b.pom_entry_status_pk
	  where a.pom_entry_id LIKE (@OrderID + '%') AND
	  b.id = 'Scrap' 

	SELECT @Rework=COUNT(a.[pom_entry_id])
		  FROM [SitMesDB].[dbo].[POM_ENTRY] a
	  JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] b ON
	  a.pom_entry_status_pk = b.pom_entry_status_pk
	  where a.pom_entry_id LIKE (@OrderID + '%') AND
	  b.id =  'Rework'
	  
	 
	  IF @Scrap>0 
		  BEGIN
			SELECT @Result=2
		  END
	  ELSE IF @Rework>0
		  BEGIN
			SELECT @Result=1
		  END
	  ELSE
		  BEGIN
			SELECT @Result=0
		  END
		  
	RETURN @Result

END
GO
