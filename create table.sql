CREATE TABLE stores (
    store_id 					SERIAL PRIMARY KEY,
    store_name 					VARCHAR(255) NOT NULL,
    location 					VARCHAR(255) NOT NULL,
	size						NUMERIC(4,2)
);

CREATE TABLE employees(
	employee_id					CHAR(5)	PRIMARY KEY,
	employee_name				VARCHAR(255) NOT NULL,
	store_id					int,
	title						VARCHAR(255),
	email						VARCHAR(255),
	phone						CHAR(10),
	address						TEXT,
	entry_time					DATE,
	shifts						VARCHAR(255),
	time_off					TIMESTAMP,
	evaluation					TEXT,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE products(
    product_id 					SERIAL PRIMARY KEY,
    product_name 				VARCHAR(255) NOT NULL,
    cost_price 					DECIMAL(10, 2),
    selling_price 				DECIMAL(10, 2)
);

CREATE TABLE inventories(
	sku							CHAR(8) PRIMARY KEY,
	product_id					INT,
	store_id					INT,
	price						NUMERIC(8,2),
	quantity					INT,
	FOREIGN KEY (product_id) 	REFERENCES products,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE suppliers(
	supplier_id					SERIAL PRIMARY KEY,
	supplier_name				VARCHAR(255) NOT NULL
);

CREATE TABLE shipments(
	shipment_id					CHAR(10) PRIMARY KEY,
	store_id					INT,
	supplier_id					INT,
	product_id 					INT,
	expected_delivery			TIMESTAMP,
	actual_delivery				TIMESTAMP,
	FOREIGN KEY (store_id)		REFERENCES stores,
	FOREIGN KEY (supplier_id)	REFERENCES suppliers,
	FOREIGN KEY (product_id) 	REFERENCES products
);

CREATE TABLE supplier_evaluations(
    evaluation_id 				INT PRIMARY KEY,
    supplier_id 				INT,
    date 						DATE,
    responsiveness_rating 		INT CHECK (responsiveness_rating >= 1 AND responsiveness_rating <= 5), 
    productquality_rating 		INT CHECK (productquality_rating >= 1 AND productquality_rating <= 5),
    deliveryaccuracy_rating 	INT CHECK (deliveryaccuracy_rating >= 1 AND deliveryaccuracy_rating <= 5),
    comments 					TEXT,
    FOREIGN KEY (supplier_id) 	REFERENCES suppliers
);

CREATE TABLE customers(
  	customer_id 				SERIAL PRIMARY KEY,
  	customer_name 				VARCHAR(255),
  	email 						VARCHAR(255),
  	phone 						VARCHAR(255),
  	address 					TEXT,
  	loyalty_points 				INT DEFAULT 0,
  	total_purchases 			NUMERIC(10,2) DEFAULT 0,
  	last_purchase_date 			DATE
);

CREATE TABLE orders(
  	order_id 					SERIAL PRIMARY KEY,
  	customer_id 				INT,
	store_id					INT,
	product_id					INT,
	quantity					INT,
  	order_time 					TIMESTAMP,
  	total_amount 				NUMERIC(10,2),
	payment_method				VARCHAR(255),
	FOREIGN KEY (customer_id)	REFERENCES customers,
	FOREIGN KEY (store_id)		REFERENCES stores,
	FOREIGN KEY (product_id)	REFERENCES products
);

CREATE TABLE expenses(
    expense_id 					SERIAL PRIMARY KEY,
    store_id 					INT,
    expense_type				VARCHAR(255) NOT NULL,
    amount 						DECIMAL(10, 2) NOT NULL,
    expense_date 				DATE NOT NULL,
    FOREIGN KEY (store_id) 		REFERENCES stores
);

CREATE TABLE demand_forecast(
  	forecast_id 				SERIAL PRIMARY KEY,
	product_id					INT,
  	sku 						CHAR(8),
  	forecast_date 				DATE,
  	forecast_quantity 			INT,
  	actual_quantity 			INT,
  	previous_sales 				NUMERIC(10,2),
  	season 						VARCHAR(20),
	FOREIGN KEY (product_id) 	REFERENCES products,
	FOREIGN KEY (sku) 		 	REFERENCES inventories
);

CREATE TABLE promotions(
  	promotion_id 				SERIAL PRIMARY KEY,
  	promotion_name 				VARCHAR(255),
	store_id					INT,
  	start_time					TIMESTAMP,
  	end_time 					TIMESTAMP,
  	description 				TEXT,
  	discount_percentage 		NUMERIC(4,2),
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE promotion_effects(
  	effect_id 					SERIAL PRIMARY KEY, 
  	promotion_id 				INT,
 	sku 						CHAR(8),
  	sales_quantity 				INT,
  	revenue 					NUMERIC(10,2),
	comments					TEXT,
	FOREIGN KEY (promotion_id)	REFERENCES promotions
);

CREATE TABLE customer_satisfaction(
    survey_id     				CHAR(10) PRIMARY KEY,
    customer_id   				INT,
	store_id					INT,
    survey_date   				DATE,
    rating        				INT CHECK (rating >= 1 AND rating <= 5),
    comments     				TEXT,
    follow_up_required 			BOOLEAN,
    follow_up_date 				DATE,
    FOREIGN KEY (customer_id) 	REFERENCES customers,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE training_sessions(
    session_id    				CHAR(8) PRIMARY KEY,					
    topic         				VARCHAR(255),
    trainer       				VARCHAR(255),
    training_date 				DATE,
	training_place				VARCHAR(255),
    duration      				INT, -- Duration in hours
    effectiveness_rating 		INT CHECK (effectiveness_rating >= 1 AND effectiveness_rating <= 5)
);

CREATE TABLE employee_training(
    employee_id  				CHAR(5) PRIMARY KEY,
    session_id    				CHAR(8),
    participation_date 			DATE,
    evaluation    				TEXT,
	PRIMARY KEY (employee_id, session_id),
    FOREIGN KEY (employee_id) 	REFERENCES employees,
    FOREIGN KEY (session_id)	REFERENCES training_sessions
);

CREATE TABLE returns(
    return_id       			SERIAL PRIMARY KEY,
    order_id        			INT,
    customer_id     			INT,
    product_id      			INT,
	store_id					INT,
    return_date     			DATE,
    reason          			TEXT,
    satisfaction_level 			INT CHECK (satisfaction_level >= 1 AND satisfaction_level <= 5),
    action_taken    			VARCHAR(255),
    FOREIGN KEY (customer_id) 	REFERENCES customers,
    FOREIGN KEY (order_id) 		REFERENCES orders,
    FOREIGN KEY (product_id) 	REFERENCES products,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE exchanges(
    exchange_id       			SERIAL PRIMARY KEY,
    order_id        			INT,
    customer_id     			INT,
    product_id      			INT,
	store_id					INT,
    exchange_date     			DATE,
    reason          			TEXT,
    satisfaction_level 			INT CHECK (satisfaction_level >= 1 AND satisfaction_level <= 5),
    action_taken    			VARCHAR(255),
    FOREIGN KEY (customer_id) 	REFERENCES customers,
    FOREIGN KEY (order_id) 		REFERENCES orders,
    FOREIGN KEY (product_id) 	REFERENCES products,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE waste(
    waste_id 					INT PRIMARY KEY,
	product_id					INT,
    sku 						CHAR(8),
	store_id					INT,
    date 						DATE,
    type 						VARCHAR(255),  --- e.g., expired, damaged
    quantity 					INT,
    disposal_method 			VARCHAR(255),  --- e.g., recycling, landfill
    notes 						TEXT, 
	FOREIGN KEY	(product_id)	REFERENCES products,
    FOREIGN KEY (sku)			REFERENCES inventories,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE zones(
	zone_id						SERIAL PRIMARY KEY,
	zone_name					VARCHAR(255),  --- Specific zone/area in the store
	store_id					INT,
	FOREIGN KEY (store_id)		REFERENCES stores
);

CREATE TABLE foot_traffic(
    traffic_id 					INT PRIMARY KEY,
	zone_id 					int,
	start_time					TIMESTAMP,  --- The start time to calculate total number of customers in a specific zone in the store 
	end_time					TIMESTAMP,  --- The end time to calculate total number of customers in a specific zone in the store 
    customer_count 				INT,
	FOREIGN KEY (zone_id)		REFERENCES zones
);

CREATE TABLE product_placements(
    placement_id 				INT PRIMARY KEY,
    product_id 					INT,
    zone_id 					INT,
    start_time 					TIMESTAMP,  --- When the product was placed in this location
    end_time 					TIMESTAMP,  --- When the product was moved from this location (if applicable)
    effectiveness_rating 		INT, 
    FOREIGN KEY (product_id) 	REFERENCES products,
	FOREIGN KEY (zone_id)		REFERENCES zones
);

