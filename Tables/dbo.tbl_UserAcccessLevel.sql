CREATE TABLE [dbo].[tbl_UserAcccessLevel]
(
[Pk] [smallint] NOT NULL IDENTITY(1, 1),
[AccessLevel] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_UserAcccessLevel] ADD CONSTRAINT [PK_tbl_UserAcccessLevel] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
