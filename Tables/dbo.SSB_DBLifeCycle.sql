CREATE TABLE [dbo].[SSB_DBLifeCycle]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_DBLifeCycle] ADD CONSTRAINT [PK_SSB_DBLifeCycle] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
