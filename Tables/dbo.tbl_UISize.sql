CREATE TABLE [dbo].[tbl_UISize]
(
[Pk] [smallint] NOT NULL IDENTITY(1, 1),
[SizeDescription] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_UISize] ADD CONSTRAINT [PK_tbl_UISize] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
