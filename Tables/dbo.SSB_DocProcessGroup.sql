CREATE TABLE [dbo].[SSB_DocProcessGroup]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[Sequence] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_DocProcessGroup] ADD CONSTRAINT [PK_SSB_DocProcessGroup] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
