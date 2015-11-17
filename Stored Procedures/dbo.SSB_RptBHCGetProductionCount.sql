SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptBHCGetProductionCount]
		@StartTime dateTime,
		@EndTime	dateTime	
AS

DECLARE @intStartRow	int				,
        @intEndRow		int				,
        @intelProc		int				,
        @OrderID		nvarchar(20)	,	
		@SelDate		Date			,
		@CompleteCount	int				,
		@ScrapCount		int				,
		@ProdCount		int				,
		@ScheduleCount	int				

DECLARE	@tblProductionDetails AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
									        OrderID			nvarchar(20)	,
											EntryStatus		nvarchar(20)	)

DECLARE	@tblDate AS Table				(	RowId			int	IDENTITY	,
											DateT			Date	)

DECLARE	@tblProductionCount AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
									        Complete		int				,
											Scrap			int				,
											InProduction	int				,
											Scheduled		int				)


INSERT INTO @tblProductionDetails (DateT,OrderID,EntryStatus)
	SELECT CONVERT(date, DATEADD(minute,-[actual_start_time_bias],[actual_start_time]))  as [Date],
			[pom_order_id]
		  ,pom_entry_status_id
	  FROM [SitMesDB].[dbo].[POMV_ETRY]
	 WHERE  Pom_entry_type_Id='BHC'
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
	
	SELECT 	@CompleteCount	='0'	,
			@ScrapCount		='0'	,
			@ProdCount		='0'	,
			@ScheduleCount	='0'		
	
	SELECT @CompleteCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Completed'
		AND DateT=@SelDate

	SELECT @ScrapCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Scrap'
		AND DateT=@SelDate

	SELECT @ProdCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='In Progress'
		AND DateT=@SelDate

	SELECT @ScheduleCount=COUNT(RowID)
	FROM @tblProductionDetails
	WHERE EntryStatus='Scheduled'
		AND DateT=@SelDate

	INSERT INTO @tblProductionCount(  DateT	, Complete,Scrap	,InProduction,Scheduled)
		VALUES (@SelDate,@CompleteCount,@ScrapCount,@ProdCount,@ScheduleCount)

	SELECT @intStartRow=@intStartRow +1
END

SELECT * FROM @tblProductionCount
GO
