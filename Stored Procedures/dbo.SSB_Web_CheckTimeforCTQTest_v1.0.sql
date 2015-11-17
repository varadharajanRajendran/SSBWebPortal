SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_Web_CheckTimeforCTQTest_v1.0]  
   @OrderID   nvarchar(50) ,  
   @MachineID   nvarchar(255)   
AS  
  
 DECLARE   
   @PS    nvarchar(255) ,  
   @EqID    nvarchar(255) ,  
   @Freq    decimal(5,2) ,  
   @TimeDiff   decimal(5,2) ,  
   @LastSampleTime nvarchar(255) ,  
   @EntryName	nvarchar(255)	,
   @ParmCounter  int    ,  
   @EntryID   int    ,  
   @Result   int    ,  
   @MachineName  nvarchar(255) ,  
   @CTQTimeResult  int,  
   @SaveCTQResult  int  
/*  
SELECT @MachineID='Panel_Quilt',  
  @OrderID ='107931003'  
*/  

    
SELECT  @EqID   = Eq.equip_id     ,  
  @EntryID  = PoE.pom_entry_pk    ,  
  @EntryName= PoE.pom_Entry_Id,
  @MachineName = REPLACE(PS.PS,'*0001.00','')  
FROM [SitMesDB].[dbo].[BPM_EQUIPMENT] Eq  
  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] PoE ON Eq.equip_pk=PoE.equip_pk  
  INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po ON  Po.Pom_order_pk=  PoE.[pom_order_pk]  
  INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_TYPE] PT ON PT.[pom_entry_type_pk]=PoE.[pom_entry_type_pk]  
  INNER JOIN [SitMesDB].[dbo].[PDefM_PS] PS ON PS.[PS_Type]=PT.[id]  
 WHERE PS.PS_PPR='SSB_CML'  
  AND PT.[id] like '%'+ @MachineID  + '%'  
  AND Po.pom_order_id =@OrderID  
 
/*
EXEC  [SSB].[dbo].[SSB_CheckTimetoQCTest] @EntryName  
  */
   
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
  SELECT @Result= 1  
   END  
ELSE  
   BEGIN  
  SELECT @Result=0  
   END  
  
  
  
SELECT @Result as Result
GO
