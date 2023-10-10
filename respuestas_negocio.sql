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
