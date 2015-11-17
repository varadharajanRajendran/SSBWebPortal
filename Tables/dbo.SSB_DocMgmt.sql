CREATE TABLE [dbo].[SSB_DocMgmt]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[FilePath] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[DocProcessGroup] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[UnitGroup] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[FileType] [nchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Status] [int] NULL,
[Comments] [nvarchar] (2000) COLLATE Latin1_General_CI_AS NULL,
[ModifiedDataTime] [datetime] NULL,
[ModifiedBy] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[CreatedDataTime] [datetime] NULL,
[CreatedBy] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_DocMgmt] ADD CONSTRAINT [PK_SSB_DocMgmt] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
