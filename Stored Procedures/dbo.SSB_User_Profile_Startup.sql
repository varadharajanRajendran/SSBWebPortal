SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  Purpose:
	Get The list of screens based on the screens configured

  Output Parameters:
	List of ASP Pages

  Input Parameters:
	@UserRole -  User Roles


  Trigger:
	From Web

  Data Read Other Inputs:  
	---

  Data Written Results:
	---

  Assumptions:
	---

  Dependencies 

	---

  Variables:
	---

  Tables Modified
	---

  Modification Change History:
  ---------------------------
  11/11/2014	Varadharajan R	C00V00 - Intial code
  
  
*/
CREATE  PROCEDURE [dbo].[SSB_User_Profile_Startup]
		@UserID				nvarchar(50),
		@ShopFloorTerminal	bit
     
AS
 

DECLARE @UserRole 	nvarchar(50)


SELECT @UserRole=Roles.[Roles]
FROM [SSBWebPortal].[dbo].[tbl_Roles] Roles  
  INNER JOIN [SSBWebPortal].[dbo].[tbl_Users] Users ON USers.[Role]=Roles.PK
 WHERE Users.[User]=@UserID	


IF @ShopFloorTerminal='True'
BEGIN
	SELECT UserProfile.[Sequence] AS [Sequence],
		   ASPPages.[Description] AS [Description],
		   ASPPages.[URL] AS [URL],
		   ASPPages.[Image] AS [Image],
		   UISize.[SizeDescription] AS [Size],
		   Access.[AccessLevel] As [AccessLevel]
	FROM [SSBWebPortal].[dbo].[tbl_PortalPageAccess]  UserProfile
		INNER JOIN [SSBWebPortal].[dbo].[tbl_PortalPages] ASPPages ON ASPPages.pk=UserProfile.[PortalPage]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_Roles]  UserRoles ON  UserRoles.[Pk]=UserProfile.[Role]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_UISize] UISize ON UISize.[pk]= UserProfile.[ObjSize]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_UserAcccessLevel] Access ON Access.[Pk]=UserProfile.[AccessLevel]
	WHERE UserRoles.[Roles]=@UserRole
		AND ASPPages.[ShopFloorAccess]='True'
END
ELSE
BEGIN
	SELECT UserProfile.[Sequence] AS [Sequence],
		   ASPPages.[Description] AS [Description],
		   ASPPages.[URL] AS [URL],
		   ASPPages.[Image] AS [Image],
		   UISize.[SizeDescription] AS [Size],
		   Access.[AccessLevel] As [AccessLevel]
	FROM [SSBWebPortal].[dbo].[tbl_PortalPageAccess]  UserProfile
		INNER JOIN [SSBWebPortal].[dbo].[tbl_PortalPages] ASPPages ON ASPPages.pk=UserProfile.[PortalPage]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_Roles]  UserRoles ON  UserRoles.[Pk]=UserProfile.[Role]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_UISize] UISize ON UISize.[pk]= UserProfile.[ObjSize]
		INNER JOIN [SSBWebPortal].[dbo].[tbl_UserAcccessLevel] Access ON Access.[Pk]=UserProfile.[AccessLevel]
	WHERE UserRoles.[Roles]=@UserRole
END

RETURN
GO
