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

SELECT dbo.fn_GetUserTotalSpent(1) AS TotalSpentByUser1;

CREATE TRIGGER dbo.trg_Payment_UpdateOrderStatus
ON Payment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET o.Status = 'Paid'
    FROM [Order] o
    INNER JOIN inserted i ON o.OrderID = i.OrderID
    WHERE i.Status = 'Completed';
END;

-- USERS
INSERT INTO [User] (Username, Email, PasswordHash, Phone, City, Rating, IsActive)
VALUES
('ivan89',  'ivan@example.com',  'hash1', '0888123456', 'Sofia',    4.50, 1),
('maria_p', 'maria@example.com', 'hash2', '0888123000', 'Plovdiv',  4.80, 1),
('gosho23', 'gosho@example.com', 'hash3', '0888333444', 'Varna',    3.90, 1),
('niki77',  'niki@example.com',  'hash4', '0888555666', 'Burgas',   4.20, 1),
('petya',   'petya@example.com', 'hash5', '0888999000', 'Sofia',    4.00, 0);  -- deactivated user

-- CATEGORIES
INSERT INTO Category (Name, ParentCategoryID, Description)
VALUES
('Electronics',      NULL, 'All kinds of electronics'),
('Phones',           1,    'Mobile phones and accessories'),
('Home & Garden',    NULL, 'Furniture, home items, tools'),
('Vehicles',         NULL, 'Cars, motorbikes and more');

-- LISTINGS
INSERT INTO Listing (UserID, CategoryID, Title, Description, Price, Status, Location, [Condition], ViewsCount, IsPromoted)
VALUES
(1, 2, 'iPhone 12 128GB', 'Used iPhone 12, very good condition.', 900.00,  'Active', 'Sofia',  'Used',  150, 1),
(2, 1, 'Gaming Laptop Lenovo', 'Lenovo gaming laptop with GTX graphics.', 1400.00, 'Active', 'Plovdiv', 'Used', 80, 0),
(3, 3, 'Corner Sofa', 'Large comfortable corner sofa, almost new.',       350.00,  'Active', 'Varna',   'Like New', 40, 0),
(4, 4, 'VW Golf 6 2.0 TDI', 'Well maintained VW Golf 6, 2010.',           7500.00, 'Active', 'Burgas',  'Used', 200, 1),
(1, 3, 'Dining Table', 'Wooden dining table with 4 chairs.',              220.00,  'Archived', 'Sofia', 'Used',  25, 0);

-- ORDERS
INSERT INTO [Order] (UserID, ListingID, Status, TotalAmount, Quantity, DeliveryType)
VALUES
(2, 1, 'New',      900.00,  1, 'Courier'),        -- Maria купува iPhone от Ivan
(3, 2, 'New',     1400.00,  1, 'Courier'),        -- Gosho купува лаптоп от Maria
(1, 3, 'New',      350.00,  1, 'Personal pickup'),-- Ivan купува диван от Gosho
(5, 4, 'New',     7500.00,  1, 'Courier');        -- Petya купува Golf от Niki

-- PAYMENTS
INSERT INTO Payment (OrderID, Amount, Method, Status, TransactionRef)
VALUES
(1, 900.00,  'Card',  'Completed', 'TXN-IPHONE-001'),
(2, 1400.00, 'Card',  'Pending',   'TXN-LAPTOP-002'),
(3, 350.00,  'Cash',  'Completed', 'TXN-SOFA-003'),
(4, 7500.00, 'Bank',  'Completed', 'TXN-GOLF-004');

SELECT OrderID, Status
FROM [Order];
-- MESSAGES
INSERT INTO Message (SenderID, ReceiverID, ListingID, Content)
VALUES
(2, 1, 1, 'Здравей, iPhone-ът още ли е наличен?'),
(1, 2, 1, 'Да, наличен е.'),
(3, 2, 2, 'Може ли малко коментар в цената на лаптопа?'),
(2, 3, 2, 'Мога да сваля 50 лв.'),
(1, 3, 3, 'Диванът разглобяем ли е за транспорт?');

-- FAVORITES
INSERT INTO Favorite (UserID, ListingID)
VALUES
(2, 1),   -- Maria добавя iPhone на Ivan
(3, 1),   -- Gosho също харесва iPhone
(3, 2),   -- Gosho харесва и лаптопа
(1, 3),   -- Ivan харесва дивана
(4, 1),   -- Niki харесва iPhone
(5, 4);   -- Petya харесва Golf-а (и после го купува)

-- FAVORITES
INSERT INTO Favorite (UserID, ListingID)
VALUES
(2, 1),   -- Maria добавя iPhone на Ivan
(3, 1),   -- Gosho също харесва iPhone
(3, 2),   -- Gosho харесва и лаптопа
(1, 3),   -- Ivan харесва дивана
(4, 1),   -- Niki харесва iPhone
(5, 4);   -- Petya харесва Golf-а (и после го купува)

SELECT * FROM [User];
SELECT * FROM Category;
SELECT * FROM Listing;
SELECT * FROM [Order];
SELECT * FROM Payment;
SELECT * FROM Message;
SELECT * FROM Favorite;

SELECT l.ListingID, l.Title, l.Price,
       u.Username AS Seller,
       c.Name     AS Category
FROM Listing l
JOIN [User] u   ON l.UserID = u.UserID
JOIN Category c ON l.CategoryID = c.CategoryID;


SELECT o.OrderID, o.OrderDate, o.Status,
       o.TotalAmount, o.Quantity,
       buyer.Username  AS Buyer,
       l.Title         AS ListingTitle
FROM [Order] o
JOIN [User]  buyer ON o.UserID = buyer.UserID
JOIN Listing l     ON o.ListingID = l.ListingID;

SELECT o.OrderID, o.Status AS OrderStatus,
       p.PaymentID, p.Amount, p.Status AS PaymentStatus
FROM [Order] o
LEFT JOIN Payment p ON o.OrderID = p.OrderID
ORDER BY o.OrderID;

CREATE TRIGGER dbo.trg_Payment_UpdateOrderStatus
ON Payment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE o
    SET o.Status = 'Paid'
    FROM [Order] o
    INNER JOIN inserted i ON o.OrderID = i.OrderID
    WHERE i.Status = 'Completed';
END;

UPDATE Payment
SET Status = Status
WHERE Status = 'Completed';

SELECT o.OrderID, o.Status AS OrderStatus,
       p.PaymentID, p.Amount, p.Status AS PaymentStatus
FROM [Order] o
LEFT JOIN Payment p ON o.OrderID = p.OrderID
ORDER BY o.OrderID;


EXEC dbo.CreateOrder 
    @UserID    = 1,   -- Иван купува
    @ListingID = 2,   -- Gaming Laptop Lenovo
    @Quantity  = 2;


	USE OLX_DB;
GO

IF OBJECT_ID('dbo.CreateOrder', 'P') IS NOT NULL
    DROP PROCEDURE dbo.CreateOrder;
GO

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
GO

USE OLX_DB;
GO

EXEC dbo.CreateOrder
    @UserID    = 1,   -- Иван купува
    @ListingID = 2,   -- Gaming Laptop Lenovo
    @Quantity  = 2;


	SELECT TOP 5 *
FROM [Order]
ORDER BY OrderID DESC;

SELECT dbo.fn_GetUserTotalSpent(1) AS TotalSpentByUser1;


USE OLX_DB;
GO

IF OBJECT_ID('dbo.fn_GetUserTotalSpent', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetUserTotalSpent;
GO

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
GO


USE OLX_DB;
GO

SELECT dbo.fn_GetUserTotalSpent(1) AS TotalSpentByUser1;


SELECT u.UserID,
       u.Username,
       dbo.fn_GetUserTotalSpent(u.UserID) AS TotalSpent
FROM [User] u
ORDER BY u.UserID;
