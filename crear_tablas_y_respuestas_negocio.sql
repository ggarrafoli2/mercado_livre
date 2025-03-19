-- =============================
-- CREACIÓN DE TABLAS (DDL)
-- =============================

-- Creación de la tabla Dim_Customer
CREATE TABLE Dim_Customer (
    customer_id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    birthdate DATE,
    phone VARCHAR(50),
    address TEXT,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O'))
);

-- Creación de la tabla Dim_Seller
CREATE TABLE Dim_Seller (
    seller_id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    registration_date DATE NOT NULL
);

-- Creación de la tabla Dim_Category
CREATE TABLE Dim_Category (
    category_id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    path TEXT NOT NULL
);

-- Creación de la tabla Dim_Item
CREATE TABLE Dim_Item (
    item_id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('active', 'inactive', 'sold', 'removed')),
    category_id BIGINT,
    seller_id BIGINT,
    created_at DATETIME DEFAULT GETDATE(),
    deleted_at DATETIME NULL,
    FOREIGN KEY (category_id) REFERENCES Dim_Category(category_id),
    FOREIGN KEY (seller_id) REFERENCES Dim_Seller(seller_id)
);

-- Creación de la tabla Dim_Time
CREATE TABLE Dim_Time (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    quarter INT NOT NULL,
    week_of_year INT NOT NULL,
    day_of_week INT NOT NULL,
    is_weekend BIT NOT NULL
);

-- Creación de la tabla de hechos - Fact_Sales
CREATE TABLE Fact_Sales (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    item_id BIGINT,
    seller_id BIGINT,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    date_id INT,
    FOREIGN KEY (customer_id) REFERENCES Dim_Customer(customer_id),
    FOREIGN KEY (item_id) REFERENCES Dim_Item(item_id),
    FOREIGN KEY (seller_id) REFERENCES Dim_Seller(seller_id),
    FOREIGN KEY (date_id) REFERENCES Dim_Time(date_id)
);

-- Creación de la tabla de hechos - Fact_Inventory
CREATE TABLE Fact_Inventory (
    inventory_id BIGINT PRIMARY KEY,
    item_id BIGINT,
    quantity_available INT NOT NULL,
    last_updated DATE NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Dim_Item(item_id)
);

-- Creación de la tabla de hechos - Fact_Customer_Behavior
CREATE TABLE Fact_Customer_Behavior (
    event_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    event_type VARCHAR(50) CHECK (event_type IN ('search', 'click', 'add_to_cart', 'purchase')),
    item_id BIGINT,
    event_timestamp DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Dim_Customer(customer_id),
    FOREIGN KEY (item_id) REFERENCES Dim_Item(item_id)
);

-- =============================
-- CONSULTAS ANALÍTICAS (SQL)
-- =============================

-- 1️⃣ Consulta: Usuarios que cumplen años hoy y vendieron más de 1500 unidades en enero de 2020
SELECT c.customer_id, c.name, c.email, COUNT(fs.order_id) AS total_sales
FROM Fact_Sales fs
JOIN Dim_Customer c ON fs.customer_id = c.customer_id
JOIN Dim_Time dt ON fs.date_id = dt.date_id
WHERE dt.year = 2020 AND dt.month = 1
AND c.birthdate = CONVERT(DATE, GETDATE())
GROUP BY c.customer_id, c.name, c.email
HAVING COUNT(fs.order_id) > 1500;

-- 2️⃣ Consulta: Top 5 vendedores por mes en la categoría 'Celulares' en 2020
SELECT dt.year, dt.month, s.seller_id, s.name,
       COUNT(fs.order_id) AS total_orders,
       SUM(fs.quantity) AS total_products_sold,
       SUM(fs.total_amount) AS total_revenue
FROM Fact_Sales fs
JOIN Dim_Seller s ON fs.seller_id = s.seller_id
JOIN Dim_Item i ON fs.item_id = i.item_id
JOIN Dim_Category c ON i.category_id = c.category_id
JOIN Dim_Time dt ON fs.date_id = dt.date_id
WHERE dt.year = 2020 AND c.name LIKE '%Celulares%'
GROUP BY dt.year, dt.month, s.seller_id, s.name
ORDER BY dt.year, dt.month, total_revenue DESC
LIMIT 5;

-- 3️⃣ Procedimiento Almacenado para actualizar el historial de precios y estado de los productos
CREATE PROCEDURE Update_Item_History AS
BEGIN
    INSERT INTO Fact_Item_History (item_id, price, status, updated_at)
    SELECT item_id, price, status, GETDATE()
    FROM Dim_Item;
END;

-- 4️⃣ INSIGHTS ADICIONALES --

-- 🔹 Evolución de las ventas por trimestre
SELECT dt.year, dt.quarter, SUM(fs.total_amount) AS revenue
FROM Fact_Sales fs
JOIN Dim_Time dt ON fs.date_id = dt.date_id
GROUP BY dt.year, dt.quarter
ORDER BY dt.year, dt.quarter;

-- 🔹 Comparación de conversión entre categorías
SELECT c.name AS category, COUNT(fcb.event_id) AS clicks, COUNT(fs.order_id) AS purchases,
       (COUNT(fs.order_id) * 1.0 / NULLIF(COUNT(fcb.event_id), 0)) AS conversion_rate
FROM Fact_Customer_Behavior fcb
LEFT JOIN Fact_Sales fs ON fcb.item_id = fs.item_id
JOIN Dim_Item i ON fcb.item_id = i.item_id
JOIN Dim_Category c ON i.category_id = c.category_id
WHERE fcb.event_type = 'click'
GROUP BY c.name;

-- 🔹 Análisis de crecimiento de vendedores
SELECT s.seller_id, s.name,
       SUM(CASE WHEN dt.year = 2019 THEN fs.total_amount ELSE 0 END) AS revenue_2019,
       SUM(CASE WHEN dt.year = 2020 THEN fs.total_amount ELSE 0 END) AS revenue_2020,
       (SUM(CASE WHEN dt.year = 2020 THEN fs.total_amount ELSE 0 END) -
        SUM(CASE WHEN dt.year = 2019 THEN fs.total_amount ELSE 0 END)) / NULLIF(SUM(CASE WHEN dt.year = 2019 THEN fs.total_amount ELSE 0 END), 0) AS growth_rate
FROM Fact_Sales fs
JOIN Dim_Seller s ON fs.seller_id = s.seller_id
JOIN Dim_Time dt ON fs.date_id = dt.date_id
WHERE dt.year IN (2019, 2020)
GROUP BY s.seller_id, s.name
ORDER BY growth_rate DESC;
