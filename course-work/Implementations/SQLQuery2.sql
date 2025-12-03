CREATE PROCEDURE dbo.CreateOrder
    @UserID    INT,
    @ListingID INT,
    @Quantity  INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Price       DECIMAL(10,2);
    DECLARE @TotalAmount DECIMAL(10,2);

    -- Взимаме цената на обявата
    SELECT @Price = Price
    FROM Listing
    WHERE ListingID = @ListingID;

    IF @Price IS NULL
    BEGIN
        RAISERROR ('Listing not found.', 16, 1);
        RETURN;
    END

    SET @TotalAmount = @Price * @Quantity;

    -- Създаваме поръчката
    INSERT INTO [Order] (UserID, ListingID, OrderDate, Status, TotalAmount, Quantity, DeliveryType)
    VALUES (@UserID, @ListingID, SYSDATETIME(), 'New', @TotalAmount, @Quantity, NULL);

    -- Връщаме новото OrderID
    SELECT SCOPE_IDENTITY() AS NewOrderID;
END;
