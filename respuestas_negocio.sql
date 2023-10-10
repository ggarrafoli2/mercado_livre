--A RESOLVER

--Pregunta 1:
SELECT c.*
FROM Customer c
JOIN (
  SELECT customer_id, COUNT(*) AS total_sales
  FROM Orders
  WHERE MONTH(fecha) = 1 AND YEAR(fecha) = 2020
  GROUP BY customer_id
  HAVING COUNT(*) > 1500
) AS sales ON c.customer_id = sales.customer_id
WHERE DATE_FORMAT(c.fecha_nacimiento, '%m-%d') = DATE_FORMAT(CURRENT_DATE, '%m-%d');


--Pregunta 2:
SELECT 
    MONTH(o.date) AS month,
    YEAR(o.date) AS year,
    c.first_name,
    c.surname,
    COUNT(o.id) AS sales_quantity,
    SUM(od.cantidad) AS sold_product_quantity,
    SUM(od.cantidad * od.precio_unitario) AS total_amount_transactioned
FROM 
    Orders o
JOIN 
    Order_Details od ON o.id = od.order_id
JOIN 
    Item i ON od.item_id = i.id
JOIN 
    Category c ON i.category_id = c.id
WHERE 
    c.descripcion = 'Cellphones' AND
    YEAR(o.fecha) = 2020
GROUP BY 
    YEAR(o.date), MONTH(o.date), c.first_name, c.surname
HAVING 
    ROW_NUMBER() OVER (PARTITION BY YEAR(o.date), MONTH(o.date) ORDER BY SUM(od.quantity * od.unit_price) DESC) <= 5;


--Pregunta 3:
CREATE PROCEDURE PopulateItemStatusTable
AS
BEGIN
    -- Create a temporary table to store the latest state of each item
    CREATE TABLE #LatestItemState
    (
        Item_ID INT PRIMARY KEY,
        Price DECIMAL(10,2),
        Status VARCHAR(50)
    )

    -- Insert the latest state of each item into the temporary table
    INSERT INTO #LatestItemState (ItemID, Price, Status)
    SELECT i.Item_ID, i.Price, i.Status
    FROM Item i
    INNER JOIN
    (
        SELECT Item_ID, MAX(Date) AS LatestDate
        FROM Item
        GROUP BY Item_ID
    ) t ON i.Item_ID = t.Item_ID AND i.Date = t.LatestDate

    -- Create the final table to store the end-of-day state of items
    CREATE TABLE ItemStatus
    (
        Item_ID INT PRIMARY KEY,
        Price DECIMAL(10,2),
        Status VARCHAR(50)
    )

    -- Insert the data from the temporary table into the final table
    INSERT INTO Item_Status (ItemID, Price, Status)
    SELECT Item_ID, Price, Status
    FROM #LatestItemState

    -- Drop the temporary table
    DROP TABLE #LatestItemState
END


--We can then execute the stored procedure PopulateItemStatusTable to populate the ItemStatus table 
--with the latest price and status of the items at the end of the day. 
--Please note that this script assumes the presence of a Date column in the Item table to determine the
--latest state of each item based on the maximum date.

--It is important also to adjust the data types and table/column names as per specific database schema.

