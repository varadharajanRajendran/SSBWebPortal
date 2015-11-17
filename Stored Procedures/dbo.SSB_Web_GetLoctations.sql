SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_Web_GetLoctations]
		@MachineName	nvarchar(255)
AS
 

DECLARE @Locations as Table ( RowID			int IDENTITY	,							  
							  ParentLocPK	nvarchar(255)	,
							  LocPath		nvarchar(255)	,
							  LocType		nvarchar(255)	,
							  LocAlias		nvarchar(255)	,
							  LocPK			int				)

 DECLARE @intStartRow		int					,
         @intEndRow			int					,
         @intelProc			int					,				
		 @SelParentLocPK	nvarchar(255)		,
		 @selLocPK			nvarchar(255)		,
		 @TempLocID			nvarchar(255)		,
		 @SelLocID			nvarchar(255)		

INSERT INTO @Locations (ParentLocPK,LocPath,LocAlias,LocPK,LocType)
	SELECT [ParentLocPK]							,
		   Replace([LocPath],'WPB.CML01.' + @MachineName +'01.','')	,
		   [LocAlias]								,
		   [LocPK]
		   ,'Rack'
	  FROM [SitMesDB].[dbo].[MMLocations]
  WHERE LocPath like 'WPB.CML01.' + @MachineName + '01.%'


SELECT		@intStartRow=	min(RowId)	,
			@intEndRow	=	max(RowId)	
FROM	@Locations
    

WHILE	@intStartRow <=	@intEndRow	
	 BEGIN
		SELECT  @SelParentLocPK	=  ParentLocPK	,
				@selLocPK		=  LocPK
		FROM  @Locations
		WHERE RowID=@intStartRow

		SELECT @TempLocID= [LocID]
		FROM [SitMesDB].[dbo].[MMLocations]
		Where LocPK=@SelParentLocPK
		
		SELECT @SelLocID=REPLACE(@TempLocID,@MachineName + '01','')
		

		UPDATE @Locations
			SET ParentLocPK=@SelLocID
			WHERE RowID=@intStartRow

		SELECT @intStartRow=@intStartRow+1

	 END

	 SELECT ParentLocPK as [LocationGroup],
			LocPath as [Locations],
			LocType as [LcationType],
			LocAlias as [PLCValue],
			LocPK as [PK]
	 FROM @Locations
	 WHERE ParentLocPK <>''
GO
