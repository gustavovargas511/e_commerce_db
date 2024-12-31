/****CREATE DB****/
CREATE DATABASE e_commerce_db;

-- DROP DATABASE e_commerce_db;

GO

USE e_commerce_db;

GO

/****CREATE TABLES****/

CREATE TABLE USER_TABLE (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password VARCHAR(250) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
)

GO

CREATE TABLE PRODUCT (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_name VARCHAR(250) NOT NULL,
    price DECIMAL(18,2),
    stock_quantity INT,
    created_at DATETIME DEFAULT GETDATE()
)

-- EXEC sp_rename 'PRODUCT.creted_at', 'created_at', 'COLUMN';


GO

CREATE TABLE CATEGORY (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name VARCHAR(250) NOT NULL,
    description VARCHAR(1000)
)

GO

CREATE TABLE PRODUCTS_CATEGORIES (
    product_id INT,
    category_id INT,
)

GO

/**** Testing data****/

INSERT INTO CATEGORY (category_name, description)
VALUES 
('Electronics', 'Devices and gadgets for everyday use'),
('Clothing', 'Apparel for men, women, and children'),
('Home Appliances', 'Appliances for household use'),
('Books', 'Various genres and educational materials'),
('Toys', 'Toys and games for kids and adults'),
('Sports', 'Sports equipment and accessories'),
('Beauty', 'Cosmetics and personal care products'),
('Groceries', 'Everyday essentials and food items'),
('Furniture', 'Indoor and outdoor furniture'),
('Automotive', 'Car accessories and tools');

GO

INSERT INTO PRODUCT (product_name, price, stock_quantity)
VALUES 
-- Electronics
('Smartphone', 699.99, 50),
('Laptop', 1199.99, 30),
('Tablet', 499.99, 25),
('Smartwatch', 199.99, 100),
('Bluetooth Headphones', 99.99, 75),
('Camera', 899.99, 15),
('Portable Speaker', 49.99, 120),
('External Hard Drive', 79.99, 40),

-- Clothing
('Men''s T-Shirt', 19.99, 200),
('Women''s Dress', 49.99, 150),
('Kids'' Sneakers', 29.99, 100),
('Winter Jacket', 89.99, 50),
('Baseball Cap', 14.99, 300),

-- Home Appliances
('Microwave Oven', 99.99, 20),
('Vacuum Cleaner', 129.99, 30),
('Refrigerator', 499.99, 10),
('Dishwasher', 399.99, 8),
('Washing Machine', 599.99, 5),

-- Books
('Fiction Novel', 14.99, 80),
('Non-fiction Biography', 24.99, 60),
('Children''s Book', 9.99, 120),
('Self-help Book', 19.99, 40),
('Educational Textbook', 59.99, 30),

-- Toys
('Action Figure', 14.99, 90),
('Board Game', 29.99, 40),
('Dollhouse', 49.99, 20),
('Toy Car', 9.99, 200),
('Puzzle', 19.99, 80),

-- Sports
('Basketball', 29.99, 50),
('Tennis Racket', 99.99, 25),
('Yoga Mat', 19.99, 80),
('Running Shoes', 79.99, 100),

-- Beauty
('Lipstick', 9.99, 300),
('Moisturizer', 19.99, 150),
('Shampoo', 14.99, 200),

-- Automotive
('Car Wax', 14.99, 100),
('Tire Inflator', 29.99, 40);


GO

INSERT INTO PRODUCTS_CATEGORIES (product_id, category_id)
VALUES 
-- Electronics
(1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1),

-- Clothing
(9, 2), (10, 2), (11, 2), (12, 2), (13, 2),

-- Home Appliances
(14, 3), (15, 3), (16, 3), (17, 3), (18, 3),

-- Books
(19, 4), (20, 4), (21, 4), (22, 4), (23, 4),

-- Toys
(24, 5), (25, 5), (26, 5), (27, 5), (28, 5),

-- Sports
(29, 6), (30, 6), (31, 6), (32, 6),

-- Beauty
(33, 7), (34, 7), (35, 7),

-- Automotive
(36, 10), (37, 10);


GO

ALTER TABLE PRODUCTS_CATEGORIES
ADD CONSTRAINT FK_product_categories_product_id
FOREIGN KEY (product_id)
REFERENCES PRODUCT(product_id);

GO

ALTER TABLE PRODUCTS_CATEGORIES
ADD CONSTRAINT FK_product_categories_category_id
FOREIGN KEY (category_id)
REFERENCES CATEGORY(category_id);

GO

CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    order_date DATETIME DEFAULT GETDATE(),
    total_amount DECIMAL(18,2),
    status VARCHAR(25) DEFAULT 'ACTIVE',
    user_id INT
)

GO

ALTER TABLE ORDERS
ADD CONSTRAINT FK_ORDERS_user_id
FOREIGN KEY (user_id)
REFERENCES USER_TABLE(user_id)

GO

CREATE TABLE ORDER_DETAILS (
    order_details_id INT PRIMARY key IDENTITY(1,1),
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(18,2),
)

GO

ALTER TABLE ORDER_DETAILS
ADD CONSTRAINT FK_order_details_order_id
FOREIGN KEY (order_id)
REFERENCES ORDERS(order_id)

GO

ALTER TABLE ORDER_DETAILS
ADD CONSTRAINT FK_order_details_product_id
FOREIGN KEY (product_id)
REFERENCES PRODUCT(product_id)

GO

CREATE TABLE PAYMENT (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT,
    payment_date DATETIME DEFAULT GETDATE(),
    payment_method VARCHAR(50),
    amount DECIMAL(18,2)
)

ALTER TABLE PAYMENT
ADD CONSTRAINT FK_payment_order_id
FOREIGN KEY (order_id)
REFERENCES ORDERS(order_id)

GO

CREATE TABLE REVIEW (
    review_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT,
    product_id INT,
    rating DECIMAL(18,2),
    comments varchar(1000),
    review_date DATETIME DEFAULT GETDATE()
)

GO

ALTER TABLE REVIEW
ADD CONSTRAINT FK_review_user_id
FOREIGN KEY (user_id)
REFERENCES USER_TABLE(user_id)

GO

ALTER TABLE REVIEW
ADD CONSTRAINT FK_review_product_id
FOREIGN KEY (product_id)
REFERENCES PRODUCT(product_id)

GO

CREATE TABLE E_COMMERCE_LOGS (
    log_id INT PRIMARY KEY IDENTITY(1,1),
    tablename VARCHAR(50),
    operation VARCHAR(100),
    changed_by VARCHAR(250),
    change_date DATETIME DEFAULT GETDATE()
)

GO

/****CREATE TRIGGERS****/

CREATE TRIGGER TRG_AFTER_IUD_USER
ON USER_TABLE
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO E_COMMERCE_LOGS(tablename, 
                                operation, 
                                changed_by)
    SELECT 'USER_TABLE',
            CASE
                WHEN EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED) THEN 'UPDATE'
                WHEN EXISTS (SELECT 1 FROM INSERTED) THEN 'INSERT'
                WHEN EXISTS (SELECT 1 FROM DELETED) THEN 'DELETE'
            END AS ACTION,
            SYSTEM_USER AS username;
END;

GO

CREATE TRIGGER TRG_BEFORE_I_ORDER_DETAILS
ON ORDER_DETAILS
INSTEAD OF INSERT
AS

BEGIN

DECLARE @unit_price DECIMAL(18,2);

    SELECT @unit_price = price
      FROM PRODUCT
     WHERE product_id = (SELECT product_id
                           FROM INSERTED);

    INSERT INTO ORDER_DETAILS (order_id, product_id, quantity, price)
    SELECT order_id, product_id, quantity, (quantity * @unit_price)
      FROM INSERTED;

END;

-- CREATE TRIGGER TRG_AFTER_IUD_ORDERS
-- ON ORDERS
-- AFTER INSERT, UPDATE, DELETE
-- AS

-- BEGIN


/**** Stored Procedures ****/


