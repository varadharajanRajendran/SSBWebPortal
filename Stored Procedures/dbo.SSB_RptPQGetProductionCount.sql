SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptPQGetProductionCount]
		@StartTime dateTime,
		@EndTime	dateTime	
AS

DECLARE @intStartRow	int				,
        @intEndRow		int				,
		@intStartEID	int				,
        @intelProc		int				,
        @OrderID		nvarchar(20)	,	
		@SelDate		Date			,
		@SelEID			nvarchar(20)	,
		@CompleteCount	int				,
		@ScrapCount		int				,
		@ProdCount		int				,
		@ScheduleCount	int							
		/*
		,@StartTime		dateTime		,	
		@EndTime		dateTime
		*/
DECLARE	@tblProductionDetails AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
									        OrderID			nvarchar(20)	,
											EquipmentID		nvarchar(20)	,
											EntryStatus		nvarchar(20)	)

DECLARE	@tblDate AS Table				(	RowId			int	IDENTITY	,
											DateT			Date	)

DECLARE	@tblProductionCount AS Table	(	RowId			int	IDENTITY	,
									        DateT			Date			,
											MachineID		nvarchar(10)	,
									        Complete		int				,
											Scrap			int				,
											InProduction	int				,
											Scheduled		int				)
/*
SELECT 	@StartTime	='2015-01-01 00:00:00.00',	
		@EndTime	='2015-01-20 00:00:00.00'
*/

INSERT INTO @tblProductionDetails (DateT,OrderID,EquipmentID,EntryStatus)
	SELECT CONVERT(date, DATEADD(minute,-[actual_start_time_bias],[actual_start_time]))  as [Date],
		[pom_order_id],
		REPLACE([equip_long_name],'WPB.CML01.PQ01.',''),
		pom_entry_status_id
	  FROM [SitMesDB].[dbo].[POMV_ETRY]
	 WHERE  Pom_entry_type_Id='PANEL_QUILT'
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
	
	SELECT @intStartEID	=1

	WHILE @intStartEID<=3
		BEGIN
			SELECT 	@CompleteCount	='0'	,
					@ScrapCount		='0'	,
					@ProdCount		='0'	,
					@ScheduleCount	='0'	,	
					@SelEID			='PQ0' + CONVERT(nvarchar(5),@intStartEID)

			SELECT @CompleteCount=COUNT(RowID)
			FROM @tblProductionDetails
			WHERE EntryStatus='Completed'
				AND DateT=@SelDate
				AND EquipmentID=@SelEID

			SELECT @ScrapCount=COUNT(RowID)
			FROM @tblProductionDetails
			WHERE EntryStatus='Scrap'
				AND DateT=@SelDate
				AND EquipmentID=@SelEID

			SELECT @ProdCount=COUNT(RowID)
			FROM @tblProductionDetails
			WHERE EntryStatus='In Progress'
				AND DateT=@SelDate
				AND EquipmentID=@SelEID

			SELECT @ScheduleCount=COUNT(RowID)
			FROM @tblProductionDetails
			WHERE EntryStatus='Scheduled'
				AND DateT=@SelDate
				AND EquipmentID=@SelEID

			INSERT INTO @tblProductionCount(  DateT	, MachineID,Complete,Scrap	,InProduction,Scheduled)
				VALUES (@SelDate,@SelEID,@CompleteCount,@ScrapCount,@ProdCount,@ScheduleCount)

			SELECT @intStartEID=@intStartEID+1
		END
	
	SELECT @intStartRow=@intStartRow +1
END

SELECT * FROM @tblProductionCount
GO
