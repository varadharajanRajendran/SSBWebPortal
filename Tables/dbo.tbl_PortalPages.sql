CREATE TABLE [dbo].[tbl_PortalPages]
(
[Pk] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (30) COLLATE Latin1_General_CI_AS NOT NULL,
[URL] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NOT NULL,
[Image] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[ShopFloorAccess] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_PortalPages] ADD CONSTRAINT [PK_tbl_PortalPages] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
