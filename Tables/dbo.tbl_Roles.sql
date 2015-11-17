CREATE TABLE [dbo].[tbl_Roles]
(
[Pk] [int] NOT NULL IDENTITY(1, 1),
[Roles] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Roles] ADD CONSTRAINT [PK_tbl_Roles] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
