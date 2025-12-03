EXEC dbo.CreateOrder @UserID = 1, @ListingID = 1, @Quantity = 2;

CREATE FUNCTION dbo.fn_GetUserTotalSpent (@UserID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);

    SELECT @Total = ISNULL(SUM(p.Amount), 0)
    FROM Payment p
    INNER JOIN [Order] o ON p.OrderID = o.OrderID
    WHERE o.UserID = @UserID
      AND p.Status = 'Completed';

    RETURN @Total;
END;
