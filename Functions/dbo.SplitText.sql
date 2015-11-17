SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SplitText](@text varchar(8000))
   RETURNS @words TABLE (
      pos smallint primary key,
      value varchar(8000)
   )
AS
BEGIN
   DECLARE
      @pos smallint,
      @i smallint,
      @j smallint,
      @s varchar(8000)

   SET @pos = 1
   WHILE @pos <= LEN(@text) 
   BEGIN 
      SET @i = CHARINDEX(',', @text, @pos)
      SET @j = CHARINDEX(',', @text, @pos)
      IF @i > 0 OR @j > 0
      BEGIN
         IF @i = 0 OR (@j > 0 AND @j < @i)
            SET @i = @j

         IF @i > @pos
         BEGIN
            -- @i now holds the earliest delimiter in the string
            SET @s = SUBSTRING(@text, @pos, @i - @pos)

            INSERT INTO @words
            VALUES (@pos, @s)
         END 
         SET @pos = @i + 1

         WHILE @pos < LEN(@text) 
            AND SUBSTRING(@text, @pos, 1) IN (' ', ',')
            SET @pos = @pos + 1 
      END 
      ELSE 
      BEGIN 
         INSERT INTO @words 
         VALUES (@pos, SUBSTRING(@text, @pos, LEN(@text) - @pos + 1))

         SET @pos = LEN(@text) + 1 
      END 
   END 
   RETURN 
END
GO
