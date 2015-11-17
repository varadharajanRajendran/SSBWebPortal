SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptWorkFlowAnalysis]
		@StartTime dateTime,
		@EndTime	dateTime	
AS


DECLARE	@tblOrder AS Table	(	RowId			int	IDENTITY	,
								OrderID			nvarchar(20)	,
								SKUNo			nvarchar(20)	,
								OSchedule		DateTime		,
								OInProgress		DateTime		,
								OComplete		DateTime		,
								PQSchedule		DateTime		,
								PQDownload		DateTime		,
								PQInProgress	DateTime		,
								PQComplete		DateTime		,
								PQID			nvarchar(10)	)

DECLARE @tblMESLog	As Table (	RowId			int	IDENTITY	,
								Ts				DateTime		,	
								order_id		nvarchar(20)	,
								entry_id		nvarchar(255)	,
								status_id		nvarchar(255)	,
								equip_id		nvarchar(255)	)

DECLARE @intStartRow	int				,
        @intEndRow		int				,
		@intStartEID	int				,
        @intelProc		int				,
        @OrderID		nvarchar(20)	,	
		@OSchedule		DateTime		,
		@OInProgress	DateTime		,
		@OComplete		DateTime		,
		@PQSchedule		DateTime		,
		@PQDownload		DateTime		,
		@PQInProgress	DateTime		,
		@PQComplete		DateTime		,
		@PQID			nvarchar(10)	


INSERT INTO @tblOrder (OrderID,SKUNo)
	SELECT POM_order_ID,
		   REPLACE(note,'PPR_','') 
	FROM SitMesDB.Dbo.POM_ORDER
	WHERE DATEADD(minute,-[actual_start_time_bias],[actual_start_time])>='2015-01-19 00:00:00.00'
		OR DATEADD(minute,-[actual_end_time_bias],[actual_end_time])<='2015-01-20 00:00:00.00'

INSERT INTO @tblMESLog (ts,order_id, entry_id,status_id,equip_id)
	SELECT ol.ts,
		   ol.order_id,
		   ol.entry_id, 
		   ol.status_id,
		   ol.equip_id
	FROM [SitMesDB].[dbo].[POM_STATUS_LOG] OL
		INNER JOIN @tblOrder Po on Po.OrderID=Ol.order_id collate SQL_Latin1_General_CP1_CI_AS


SELECT	@intStartRow=	min(RowId)	,
		@intEndRow	=	max(RowId)	
FROM	@tblOrder

WHILE	@intStartRow <=	@intEndRow	
BEGIN
	SELECT @OrderID=OrderID
	FROM @tblOrder
	WHERE RowId=@intStartRow

	/* Get Order Schedule , Pre-Production and Complete Status */
	SELECT Top 1 @OSchedule= [ts]
	FROM @tblMESLog
	Where order_id like @OrderID +'%'
		AND status_ID='Scheduled' 
  
	SELECT Top 1 @OInProgress= [ts]
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		AND status_ID= 'PreProduction'  

	SELECT Top 1 @OComplete	= [ts]
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		AND status_ID='Completed'

	/* Get Panel Quilter Schedule , Pre-Production and Complete Status and Machine Allocated */
	SELECT Top 1 @PQSchedule= [ts]
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		  AND entry_id like '%.PanelQuilt1'
		AND status_ID='Scheduled' 
  
	SELECT Top 1 @PQDownload= [ts]
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		  AND entry_id like '%.PanelQuilt1'
		AND status_ID= 'Downloaded PLC'  

	SELECT Top 1 @PQInProgress= [ts]
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		  AND entry_id like '%.PanelQuilt1'
		  AND status_ID= 'In Progress'

	SELECT Top 1 @PQComplete	= [ts],
				 @PQID=REPLACE(equip_id,'WPB.CML01.PQ01.','')
	FROM @tblMESLog
	Where order_id like  @OrderID +'%'
		  AND entry_id like '%.PanelQuilt1'
		  AND status_ID='Completed'

	UPDATE @tblOrder
		SET OSchedule=@OSchedule,
			OInProgress=@OInProgress,
			OComplete=@OComplete,
			PQSchedule=@PQSchedule,
			PQDownload=@PQDownload,
			PQInProgress=@PQInProgress,
			PQComplete=@PQComplete,
			PQID=@PQID
		WHERE OrderID=@OrderID

	SELECT @intStartRow=@intStartRow+1
END

SELECT * FROM @tblOrder 
GO
