CREATE TABLE [dbo].[tbl_Terminals]
(
[Pk] [int] NOT NULL,
[Name] [nvarchar] (10) COLLATE Latin1_General_CI_AS NOT NULL,
[Description] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[IP] [nvarchar] (15) COLLATE Latin1_General_CI_AS NULL,
[MAC] [nvarchar] (17) COLLATE Latin1_General_CI_AS NULL,
[MinUsers] [smallint] NOT NULL,
[IsOverride] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Terminals] ADD CONSTRAINT [PK_tbl_Terminals] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
