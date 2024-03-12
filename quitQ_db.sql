create database QuitQDB ; 

USE QuitQDB;

CREATE TABLE Users (
    UserId INT IDENTITY(10000,1) PRIMARY KEY,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    Address NVARCHAR(255) NOT NULL ,
    Password NVARCHAR(16) NOT NULL ,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other'))
);



CREATE TABLE Seller (
    SellerId INT IDENTITY(100,1) PRIMARY KEY,
    Seller_Email NVARCHAR(255) UNIQUE NOT NULL,
    Seller_FullName NVARCHAR(100) NOT NULL,
    Seller_PhoneNumber NVARCHAR(20)NOT NULL,
    Seller_Address NVARCHAR(255) NOT NULL ,
    Seller_Password NVARCHAR(16) NOT NULL ,
    Seller_Gender NVARCHAR(10) CHECK (Seller_Gender IN ('Male', 'Female', 'Other'))
);


CREATE TABLE Administrator (
    AdminId INT IDENTITY(1000,1) PRIMARY KEY,
    Admin_Email NVARCHAR(255) UNIQUE NOT NULL,
    Admin_FullName NVARCHAR(100) NOT NULL,
    Admin_PhoneNumber NVARCHAR(20)NOT NULL,
    Admin_Password NVARCHAR(16) NOT NULL ,
);


CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    Category_Name NVARCHAR(100) UNIQUE NOT NULL
);

insert into Categories values('Electronics');

CREATE TABLE Products (
	ProductId INT IDENTITY(1,1) PRIMARY KEY,
	Product_Name NVARCHAR(255) NOT NULL,
	Description NVARCHAR(255),
	Price DECIMAL(10, 2) NOT NULL,
	Quantity_In_Stock INT NOT NULL,
	CategoryId INT NOT NULL,
	SellerId INT NOT NULL,
	ProductUrl text,
	CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Products_Seller FOREIGN KEY (SellerId) REFERENCES Seller(SellerId) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE Cart (
    CartId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
	ProductId INT NOT NULL,
	Quantity INT NOT NULL,
	Amount DECIMAL(10,2) ,
    Created_at DATETIME DEFAULT GETDATE(),
	CONSTRAINT FK_Cart_Users FOREIGN KEY (UserId) REFERENCES Users(UserId) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_Cart_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE Orders (
    OrderId INT IDENTITY(1,1)  PRIMARY KEY,
    UserId INT NOT NULL,
	Order_Date DATETIME DEFAULT GETDATE(),
	Shipping_Address NVARCHAR(500) NOT NULL,
	Amount DECIMAL(10,2),
	Status NVARCHAR(20),
	CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(UserId) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Order_Items (
    OrderItemId INT IDENTITY(1,1)  PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Item_Total_Price DECIMAL(10, 2)  ,
	CONSTRAINT FK_Order_Items_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT FK_Order_Items_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    PaymentDate DATE DEFAULT GETDATE() NOT NULL,
    PaymentStatus NVARCHAR(50) ,
	CONSTRAINT Fk_Payments_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON UPDATE CASCADE ON DELETE CASCADE
);




-------------------------Triggers-----------------------------------------------------------------------------------------------------------------

CREATE or alter TRIGGER Update_stock_quantity
ON Order_Items
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Products
    SET Quantity_In_Stock = Quantity_In_Stock - i.Quantity
    FROM Products
    INNER JOIN inserted i ON Products.ProductId = i.ProductId;
END;


CREATE TRIGGER Order_Amount
ON Order_items
AFTER UPDATE , Delete
AS 
BEGIN
	 UPDATE Orders
	 set Amount=(SELECT SUM(Order_Items.Item_Total_Price) FROM Order_Items GROUP BY Order_Items.OrderId HAVING Order_Items.OrderId=Orders.OrderId)
END;




