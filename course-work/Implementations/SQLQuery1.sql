-- USER
CREATE TABLE [User] (
    UserID           INT IDENTITY(1,1) PRIMARY KEY,
    Username         NVARCHAR(100) NOT NULL,
    Email            NVARCHAR(255) NOT NULL,
    PasswordHash     NVARCHAR(255) NOT NULL,
    Phone            NVARCHAR(50),
    City             NVARCHAR(100),
    RegistrationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Rating           DECIMAL(3,2) NULL,
    IsActive         BIT NOT NULL DEFAULT 1
);

-- CATEGORY
CREATE TABLE Category (
    CategoryID       INT IDENTITY(1,1) PRIMARY KEY,
    Name             NVARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL,
    Description      NVARCHAR(255)
);

ALTER TABLE Category
ADD CONSTRAINT FK_Category_Parent
FOREIGN KEY (ParentCategoryID) REFERENCES Category(CategoryID);

-- LISTING
CREATE TABLE Listing (
    ListingID    INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT NOT NULL,
    CategoryID   INT NOT NULL,
    Title        NVARCHAR(200) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    Price        DECIMAL(10,2) NOT NULL,
    CreatedAt    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Status       NVARCHAR(50) NOT NULL,
    Location     NVARCHAR(100),
    Condition    NVARCHAR(50),
    ViewsCount   INT NOT NULL DEFAULT 0,
    IsPromoted   BIT NOT NULL DEFAULT 0
);

ALTER TABLE Listing
ADD CONSTRAINT FK_Listing_User
FOREIGN KEY (UserID) REFERENCES [User](UserID);

ALTER TABLE Listing
ADD CONSTRAINT FK_Listing_Category
FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID);

-- MESSAGE
CREATE TABLE Message (
    MessageID   INT IDENTITY(1,1) PRIMARY KEY,
    SenderID    INT NOT NULL,
    ReceiverID  INT NOT NULL,
    ListingID   INT NOT NULL,
    SentAt      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Content     NVARCHAR(MAX) NOT NULL,
    IsRead      BIT NOT NULL DEFAULT 0
);

ALTER TABLE Message
ADD CONSTRAINT FK_Message_Sender
FOREIGN KEY (SenderID) REFERENCES [User](UserID);

ALTER TABLE Message
ADD CONSTRAINT FK_Message_Receiver
FOREIGN KEY (ReceiverID) REFERENCES [User](UserID);

ALTER TABLE Message
ADD CONSTRAINT FK_Message_Listing
FOREIGN KEY (ListingID) REFERENCES Listing(ListingID);

-- [ORDER]
CREATE TABLE [Order] (
    OrderID      INT IDENTITY(1,1) PRIMARY KEY,
    UserID       INT NOT NULL,       -- buyer
    ListingID    INT NOT NULL,
    OrderDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Status       NVARCHAR(50) NOT NULL,
    TotalAmount  DECIMAL(10,2) NOT NULL,
    Quantity     INT NOT NULL DEFAULT 1,
    DeliveryType NVARCHAR(100)
);

ALTER TABLE [Order]
ADD CONSTRAINT FK_Order_User
FOREIGN KEY (UserID) REFERENCES [User](UserID);

ALTER TABLE [Order]
ADD CONSTRAINT FK_Order_Listing
FOREIGN KEY (ListingID) REFERENCES Listing(ListingID);

-- PAYMENT
CREATE TABLE Payment (
    PaymentID      INT IDENTITY(1,1) PRIMARY KEY,
    OrderID        INT NOT NULL,
    PaidAt         DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Amount         DECIMAL(10,2) NOT NULL,
    Method         NVARCHAR(50) NOT NULL,
    Status         NVARCHAR(50) NOT NULL,
    TransactionRef NVARCHAR(100)
);

ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Order
FOREIGN KEY (OrderID) REFERENCES [Order](OrderID);

-- FAVORITES (M:N)
CREATE TABLE Favorite (
    UserID    INT NOT NULL,
    ListingID INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Favorite PRIMARY KEY (UserID, ListingID)
);

ALTER TABLE Favorite
ADD CONSTRAINT FK_Favorite_User
FOREIGN KEY (UserID) REFERENCES [User](UserID);

ALTER TABLE Favorite
ADD CONSTRAINT FK_Favorite_Listing
FOREIGN KEY (ListingID) REFERENCES Listing(ListingID);

