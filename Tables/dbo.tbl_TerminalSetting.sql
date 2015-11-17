CREATE TABLE [dbo].[tbl_TerminalSetting]
(
[Pk] [int] NOT NULL IDENTITY(1, 1),
[Terminal] [int] NOT NULL,
[UserID] [int] NOT NULL,
[AccessLevel] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_TerminalSetting] ADD CONSTRAINT [PK_tbl_TerminalSetting] PRIMARY KEY CLUSTERED  ([Pk]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_TerminalSetting] ADD CONSTRAINT [FK_tbl_TerminalSetting_tbl_UserAcccessLevel] FOREIGN KEY ([AccessLevel]) REFERENCES [dbo].[tbl_UserAcccessLevel] ([Pk])
GO
ALTER TABLE [dbo].[tbl_TerminalSetting] ADD CONSTRAINT [FK_tbl_TerminalSetting_tbl_Terminals] FOREIGN KEY ([Terminal]) REFERENCES [dbo].[tbl_Terminals] ([Pk])
GO
ALTER TABLE [dbo].[tbl_TerminalSetting] ADD CONSTRAINT [FK_tbl_TerminalSetting_tbl_Roles] FOREIGN KEY ([UserID]) REFERENCES [dbo].[tbl_Roles] ([Pk])
GO
