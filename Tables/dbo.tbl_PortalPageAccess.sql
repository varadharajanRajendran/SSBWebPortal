CREATE TABLE [dbo].[tbl_PortalPageAccess]
(
[Pk] [int] NOT NULL IDENTITY(1, 1),
[Role] [int] NOT NULL,
[PortalPage] [int] NOT NULL,
[Sequence] [smallint] NOT NULL,
[ObjSize] [smallint] NOT NULL,
[AccessLevel] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_PortalPageAccess] ADD CONSTRAINT [PK_tbl_PortalPageAccess] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_PortalPageAccess] ADD CONSTRAINT [FK_tbl_PortalPageAccess_tbl_UserAcccessLevel] FOREIGN KEY ([AccessLevel]) REFERENCES [dbo].[tbl_UserAcccessLevel] ([Pk])
GO
ALTER TABLE [dbo].[tbl_PortalPageAccess] ADD CONSTRAINT [FK_tbl_PortalPageAccess_tbl_Roles] FOREIGN KEY ([Role]) REFERENCES [dbo].[tbl_Roles] ([Pk])
GO
