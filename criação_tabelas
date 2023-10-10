CREATE TABLE Customer (
  customer_id INT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(255) NOT NULL,
  surname VARCHAR(255) NOT NULL,
  gender VARCHAR(10),
  adress VARCHAR(255),
  birth_date DATE,
  phone VARCHAR(20),
  -- Outros atributos relevantes
  -- ...
);


CREATE TABLE Item (
  item_id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category_id INT NOT NULL,
  status ENUM('active', 'inactive') DEFAULT 'active',
  withdraw_date DATE,
  -- Outros atributos relevantes
  -- ...
  FOREIGN KEY (categoria_id) REFERENCES Category(category_id)
);


CREATE TABLE Category (
  category_id INT PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  path VARCHAR(255) NOT NULL,
  -- Outros atributos relevantes
  -- ...
);



CREATE TABLE Order (
  order_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL,
  date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Outros atributos relevantes
  -- ...
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
  FOREIGN KEY (item_id) REFERENCES Item(item_id)
);


  
  
