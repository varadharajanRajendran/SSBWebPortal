SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_Web_GetLoctationLotInfo]
		@MachineName	nvarchar(255),	
		@LocationID		nvarchar(255)
AS
 
SELECT REPLACE(MMLoc.[LocPath],'WPB.CML01.' + @MachineName +'.','') as [Location]	,
       MMD.[DefID]			as [Part No]			,
	   MMD.[Descript]		as [Part Description]	,
       MML.[LotID]			as [MES Lot ID]			,
       MML.[LotName]		as [Lot Name]			,
	   MML.[Descript]		as [Lot Description]	,
	   MML.[InitQuantity]	as [Iniital Quantity]	,
       MML.[Quantity]		as	[Available Quanity]	,
	   MML.[LotPK]	   
  FROM [SitMesDB].[dbo].[MMLots] as MML
	INNER JOIN [SitMesDB].[dbo].[MMLocations] as MMLoc ON MMLoc.LocPK=MML.LocPK
	INNER JOIN [SitMesDB].[dbo].[MMDefVers] as MMDV ON MML.[DefVerPK]=MMDV.[DefVerPK]
    INNER JOIN [SitMesDB].[dbo].[MMDefinitions] as MMD	on MMD.DefPK=MMDV.DefPK
  WHERE MMLoc.LocPK=@LocationID	
GO
