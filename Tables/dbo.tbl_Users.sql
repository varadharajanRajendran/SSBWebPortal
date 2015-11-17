CREATE TABLE [dbo].[tbl_Users]
(
[Pk] [int] NOT NULL IDENTITY(1, 1),
[User] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Role] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Users] ADD CONSTRAINT [PK_tbl_Users] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
