USE [APIDB]
GO
/****** Object:  UserDefinedFunction [dbo].[IsPrime]    Script Date: 12/22/2018 2:59:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsPrime](@NumberToTest INT)
RETURNS BIT
AS
     BEGIN

         -- Declare the return variable here

         DECLARE @IsPrime BIT, @Divider INT;

         -- To speed things up, we will only attempt dividing by odd numbers
         -- We first take care of all evens, except 2

         IF(@NumberToTest % 2 = 0
            AND @NumberToTest > 2)
             SET @IsPrime = 0;
             ELSE
         SET @IsPrime = 1; -- By default, declare the number a prime
         -- We then use a loop to attempt to disprove the number is a prime

         SET @Divider = 3; -- Start with the first odd superior to 1
         -- We loop up through the odds until the square root of the number to test
         -- or until we disprove the number is a prime

         WHILE(@Divider <= FLOOR(SQRT(@NumberToTest)))
              AND (@IsPrime = 1)
             BEGIN

                 -- Simply use a modulo

                 IF @NumberToTest % @Divider = 0
                     SET @IsPrime = 0;

                 -- We only consider odds, therefore the step is 2

                 SET @Divider = @Divider + 2;
             END;

         -- Return the result of the function

         RETURN @IsPrime;
     END
GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 12/22/2018 2:59:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[SplitString] 
    (
        @str nvarchar(4000), 
        @separator char(1)
    )
    returns table
    AS
    return (
        with tokens(p, a, b) AS (
            select 
                1, 
                1, 
                charindex(@separator, @str)
            union all
            select
                p + 1, 
                b + 1, 
                charindex(@separator, @str, b + 1)
            from tokens
            where b > 0
        )
        select
            p RecordNo,
            LTRIM(RTRIM(substring(
                @str, 
                a, 
                case when b > 0 then b-a ELSE 4000 end))) 
            AS Value
        from tokens
      )
GO
/****** Object:  Table [dbo].[Cards]    Script Date: 12/22/2018 2:59:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cards](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CardNumber] [varchar](50) NOT NULL,
	[ExpiryDate] [date] NOT NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Cards] ON 

INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (1, N'4111-1111-1111-1111', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (3, N'5500-0000-0000-0004', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (4, N'3400-0000-0000-009', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (5, N'3700-0000-0000-009', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (6, N'3528-0000-0000-0009', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (7, N'3589-0000-0000-0009', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (8, N'7400-0000-0000-009', CAST(N'2022-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (9, N'4111-1111-1111-1112', CAST(N'2024-12-12' AS Date))
INSERT [dbo].[Cards] ([ID], [CardNumber], [ExpiryDate]) VALUES (10, N'5500-0000-0000-0005', CAST(N'2017-12-12' AS Date))
SET IDENTITY_INSERT [dbo].[Cards] OFF
/****** Object:  StoredProcedure [dbo].[CardValidationRule]    Script Date: 12/22/2018 2:59:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CardValidationRule]
	-- Add the parameters for the stored procedure here
	@CardNumber VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @First4Digit NVARCHAR(4)
	DECLARE @ValidationResult TABLE
	(
		Result VARCHAR(200),
		CardType VARCHAR(200)
	)
	DECLARE @FoundCardNumber NVARCHAR(50)
	DECLARE @Expire DATE
	SELECT @FoundCardNumber=CardNumber,@Expire=ExpiryDate FROM Cards WHERE CardNumber=@CardNumber
	SELECT TOP 1 @First4Digit=Value FROM [dbo].[SplitString](@CardNumber,'-')
	
	IF @FoundCardNumber IS NULL
		BEGIN
		IF (SELECT LEFT(@First4Digit, 1)) = 4
				INSERT @ValidationResult VALUES ('Does not exist','Visa')
			ELSE IF (SELECT LEFT(@First4Digit, 1)) = 5
				INSERT @ValidationResult VALUES ('Does not exist','MasterCard')
			ELSE IF (SELECT LEFT(@First4Digit, 2)) IN (34,37)
				BEGIN
					IF LEN(@CardNumber) <> 18
						INSERT @ValidationResult VALUES ('Invalid/Does not exist','Amex')
					ELSE
						INSERT @ValidationResult VALUES ('Does not exist','Amex')
				END
			ELSE IF (SELECT LEFT(@First4Digit, 4)) IN (3528,3589)
				INSERT @ValidationResult VALUES ('Does not exist','JCB')
			ELSE 
				INSERT @ValidationResult VALUES ('Does not exist','Unknown')
		END
	ELSE
		BEGIN
			
			
			IF (SELECT LEFT(@First4Digit, 1)) = 4
				INSERT @ValidationResult VALUES (IIF(DAY(EOMONTH(DATEFROMPARTS(YEAR(@Expire),2,1))) = 29,'Valid','Invalid')  ,'Visa')
			ELSE IF (SELECT LEFT(@First4Digit, 1)) = 5
				INSERT @ValidationResult VALUES (IIF([dbo].[IsPrime](YEAR(@Expire)) = 1,'Valid','Invalid'),'MasterCard')
			ELSE IF (SELECT LEFT(@First4Digit, 2)) IN (34,37)
				
				BEGIN
					IF LEN(@CardNumber) <> 18
						INSERT @ValidationResult VALUES ('Invalid','Amex')
					ELSE
						INSERT @ValidationResult VALUES ('Valid','Amex')
				END
	
			ELSE IF (SELECT LEFT(@First4Digit, 4)) IN (3528,3589)
				INSERT @ValidationResult VALUES ('Valid','JCB')
			ELSE 
				INSERT @ValidationResult VALUES ('Invalid','Unknown')
		END
		
	SELECT Result,CardType FROM @ValidationResult  

END
GO
