SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptCLSGetProductionCountbySKU]
		@StartTime dateTime,
		@EndTime	dateTime	
AS

DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @OrderID		nvarchar(20)	,	
		@SelDate		Date			,
		@SelSKU			nvarchar(20)	,
		@CompleteCount	int				,
		@ScrapCount		int				,
		@ProdCount		int				,
		@ScheduleCount	int				

DECLARE	@tblProductionDetails AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
											SKUNO			nvarchar(20)	,
									        OrderID			nvarchar(20)	,
											EntryStatus		nvarchar(20)	)

DECLARE	@tblDate AS Table				(	RowId			int	IDENTITY	,
											DateT			Date			)

DECLARE	@tblSKU	AS Table				(	RowId			int	IDENTITY	,
											DateT			Date			,
											SKUNo			nvarchar(20)	)
				
DECLARE	@tblProductionCount AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
									        SKUNo			nvarchar(20)	,
											Complete		int				,
											Scrap			int				,
											InProduction	int				,
											Scheduled		int				)


INSERT INTO @tblProductionDetails (DateT,SKUNO,OrderID,EntryStatus)
	SELECT CONVERT(date, DATEADD(minute,-[actual_start_time_bias],[actual_start_time]))  as [Date]
		   ,REPLACE([ppr_name],'PPR_','') as SKU
		   ,[pom_order_id]
		  ,pom_entry_status_id
	  FROM [SitMesDB].[dbo].[POMV_ETRY]
	 WHERE  Pom_entry_type_Id='CLOSING'
	 AND actual_start_time >=@StartTime AND [actual_end_time]<=@EndTime

INSERT INTO @tblDate (DateT)
	SELECT DISTINCT(DateT)
		FROM  @tblProductionDetails 

SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblDate 

WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @SelDate=DateT	
	FROM @tblDate
	WHERE RowId=@intStartRow

	INSERT INTO @tblSKU (SKUNo,DateT)
		SELECT DISTINCT(SKUNO),@SelDate
		FROM  @tblProductionDetails 
		WHERE DateT=@SelDate

	SELECT @intStartRow=@intStartRow+1
END


SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblSKU

WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @SelDate=DateT	,
		   @SelSKU= SKUNo
	FROM @tblSKU
	WHERE RowId=@intStartRow
	
	SELECT 	@CompleteCount	='0'	,
			@ScrapCount		='0'	,
			@ProdCount		='0'	,
			@ScheduleCount	='0'		
	
	SELECT @CompleteCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Completed'
		AND DateT=@SelDate
		AND SKUNO=@SelSKU

	SELECT @ScrapCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Scrap'
		AND DateT=@SelDate
		AND SKUNO=@SelSKU

	SELECT @ProdCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='In Progress'
		AND DateT=@SelDate
		AND SKUNO=@SelSKU

	SELECT @ScheduleCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Scheduled'
		AND DateT=@SelDate
		AND SKUNO=@SelSKU

	INSERT INTO @tblProductionCount(  DateT	,SKUNo, Complete,Scrap	,InProduction,Scheduled)
		VALUES (@SelDate,@SelSKU,@CompleteCount,@ScrapCount,@ProdCount,@ScheduleCount)

	SELECT @intStartRow=@intStartRow +1
END

SELECT * FROM @tblProductionCount
GO
