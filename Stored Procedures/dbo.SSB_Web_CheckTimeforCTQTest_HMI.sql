SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_Web_CheckTimeforCTQTest_HMI]  
   @EqID   nvarchar(50) ,
   @Result   nvarchar(255) OUTPUT
AS  

DECLARE   
   @PS    nvarchar(255) ,  
   @Freq    decimal(5,2) ,  
   @TimeDiff   decimal(5,2) ,  
   @LastSampleTime nvarchar(255) ,  
   @EntryName	nvarchar(255)	,
   @ParmCounter  int    ,  
   @EntryID   int    ,  
   @MachineName  nvarchar(255) ,  
   @CTQTimeResult  int,  
   @SaveCTQResult  int , 
   @TimeNow DateTime	,
   @OrderID	nvarchar(255)	,
   @EntryCount	int

 SELECT  @EntryCount=COUNT(PoE.pom_entry_pk)
		FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk  
		  INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk] 
		  INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY_STATUS] ES ON ES.Pom_entry_status_pk=PoE.Pom_entry_status_pk
		  INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]  
		 WHERE PS.PS_PPR='SSB_CML'   
		  AND Eq.equip_id =@EqID
		  AND ES.id='Completed'
		  AND DATEDIFF(SECOND, CONVERT(datetime, DATEADD(minute,-(PoE.actual_end_time_Bias),PoE.actual_end_time)), GETDATE())<=300


IF @EntryCount=0
	BEGIN
		SELECT  @EntryID=PoE.pom_entry_pk,
				@OrderID=Po.Pom_order_ID 
		FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk  
		  INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk] 
		  INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY_STATUS] ES ON ES.Pom_entry_status_pk=PoE.Pom_entry_status_pk
		  INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]  
		 WHERE PS.PS_PPR='SSB_CML'   
		  AND Eq.equip_id =@EqID
		  AND ES.id='In Progress'
	END
ELSE 
	BEGIN
		SELECT  @EntryID=PoE.pom_entry_pk,
				@OrderID=Po.Pom_order_ID  
		FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk  
		  INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]  
		  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk] 
		  INNER JOIN  [SitMesDB].[dbo].[POM_ENTRY_STATUS] ES ON ES.Pom_entry_status_pk=PoE.Pom_entry_status_pk
		  INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]  
		 WHERE PS.PS_PPR='SSB_CML'   
		  AND Eq.equip_id =@EqID
		  AND ES.id='Completed'
		  AND DATEDIFF(SECOND, CONVERT(datetime, DATEADD(minute,-(PoE.actual_end_time_Bias),PoE.actual_end_time)), GETDATE())<=300
	END
SELECT @CTQTimeResult=ISNULL(VALUE,'0')  
FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]  
WHERE name ='TimetoCTQ'  
 AND pom_entry_pk=@EntryID  
  
SELECT @SaveCTQResult=ISNULL(VALUE,'0')  
FROM [SitMesDB].[dbo].[POM_PROCESS_SEGMENT_PARAMETER]  
WHERE name ='Quality_LogStatus'  
 AND pom_entry_pk=@EntryID  
  
 IF @CTQTimeResult=1 AND  ISNULL(@SaveCTQResult, 0)=0  
   BEGIN  
  SELECT @Result=@OrderID
   END  
ELSE  
   BEGIN  
  SELECT @Result=0  
   END  
GO
