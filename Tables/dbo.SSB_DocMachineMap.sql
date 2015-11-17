CREATE TABLE [dbo].[SSB_DocMachineMap]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[DocumentPK] [int] NULL,
[MacinePK] [int] NULL,
[ModifiedDataTime] [datetime] NULL,
[ModifiedBy] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[CreatedDataTime] [datetime] NULL,
[CreatedBy] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_DocMachineMap] ADD CONSTRAINT [PK_SSB_DocMachineMap] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
