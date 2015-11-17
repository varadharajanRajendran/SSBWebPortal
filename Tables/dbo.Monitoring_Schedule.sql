CREATE TABLE [dbo].[Monitoring_Schedule]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ScheduleDate] [date] NULL,
[StartTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[ProcessID] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Step] [nchar] (10) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
