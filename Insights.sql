------------- Supplier Performance Analysis -------------
-- Insight 1: Identify Trends in Supplier Performance Over Time
SELECT
  se.supplier_id,
  s.supplier_name AS supplier_name,
  EXTRACT(YEAR FROM se.date) AS evaluation_year,
  EXTRACT(MONTH FROM se.date) AS evaluation_month,
  ROUND(AVG(responsiveness_rating),2) AS avg_responsiveness,
  ROUND(AVG(productquality_rating),2) AS avg_productquality,
  ROUND(AVG(deliveryaccuracy_rating),2) AS avg_delivery
FROM supplier_evaluations se
INNER JOIN suppliers s ON se.supplier_id = s.supplier_id
GROUP BY se.supplier_id, s.supplier_name, EXTRACT(YEAR FROM se.date), EXTRACT(MONTH FROM se.date)
ORDER BY se.supplier_id, evaluation_year, evaluation_month;

------------- Customer Analysis -------------

-- Insight 2: Customer Loyalty and Engagement

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders, 
    AVG(o.total_amount) AS average_order_value,  
    SUM(c.loyalty_points) AS total_loyalty_points  
FROM
    customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id
ORDER BY
    total_loyalty_points DESC, total_orders DESC, average_order_value DESC;

-- Insight 3:Top Customers by purchase volume
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS number_of_orders, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
limit 20;

	
------------- Store Traffic Analysis -------------
-- Insight 4: Store Traffic Analysis
SELECT z.zone_name, SUM(ft.customer_count) AS total_customers
FROM foot_traffic ft
JOIN zones z ON ft.zone_id = z.zone_id
GROUP BY z.zone_name
ORDER BY total_customers DESC;


------------- Sales Analysis -------------

-- Insight 5:Total sales over time 
SELECT
    DATE_TRUNC('month', order_time) AS month,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY month
ORDER BY month;

-- Insight 6: Top selling products
SELECT
    p.product_name,
    SUM(o.quantity) AS total_quantity_sold,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC, total_revenue DESC
LIMIT 10;

------------- Expenses Analysis -------------

-- Insight 7: Store expenses
SELECT
    s.store_name,
    e.expense_type,
    SUM(e.amount) AS total_expense
FROM expenses e
JOIN stores s ON e.store_id = s.store_id
GROUP BY s.store_name, e.expense_type
ORDER BY s.store_name, total_expense DESC;

------------- Profitability Analysis -------------

-- Insight 8: Profitability trend by stores over time
SELECT
  "source"."store_name" AS "store_name",
  "source"."profit_month" AS "profit_month",
  "source"."total_profit" AS "total_profit"
FROM
  (
    SELECT
      "source"."store_name" AS "store_name",
      "source"."profit_month" AS "profit_month",
      "source"."total_profit" AS "total_profit"
    FROM
      (
        SELECT
          s.store_name,
          DATE_TRUNC('month', o.order_time) AS profit_month,
          SUM((p.selling_price - p.cost_price) * o.quantity) AS total_profit
        FROM
          orders o
          JOIN products p ON o.product_id = p.product_id
          JOIN stores s ON o.store_id = s.store_id
       
GROUP BY
          s.store_name,
          profit_month
       
ORDER BY
          s.store_name,
          profit_month
      ) AS "source"
  ) AS "source"
LIMIT
  1048575
  
-- Insight 9: The Most Profitable Product in Each Store
 WITH StoreProductProfits AS (
    SELECT
        s.store_name,
        p.product_name,
        SUM((p.selling_price - p.cost_price) * o.quantity) AS product_profit
    FROM
        orders o
    JOIN
        products p ON o.product_id = p.product_id
    JOIN
        stores s ON o.store_id = s.store_id
    GROUP BY
        s.store_name, p.product_name
),
MaxProfitPerStore AS (
    SELECT
        store_name,
        MAX(product_profit) AS max_profit
    FROM
        StoreProductProfits
    GROUP BY
        store_name
),
StoreProductCombined AS (
    SELECT
        REPLACE(spp.store_name, 'ABC Foodmart - ', '') || ' - ' || spp.product_name AS store_product_combined,
        spp.product_profit
    FROM
        StoreProductProfits spp
    JOIN
        MaxProfitPerStore mpps ON spp.store_name = mpps.store_name AND spp.product_profit = mpps.max_profit
)
SELECT
    store_product_combined,
    product_profit
FROM
    StoreProductCombined
ORDER BY
    product_profit DESC;

------------- Return Analysis -------------

-- Insight 10: Trend of Return Over Time
SELECT
    DATE_TRUNC('month', return_date) AS return_month,
    COUNT(*) AS return_count
FROM
    returns
GROUP BY
    DATE_TRUNC('month', return_date)

UNION ALL

SELECT
    DATE_TRUNC('month', exchange_date) AS exchange_month,
    COUNT(*) AS exchange_count
FROM
    exchanges
GROUP BY
    DATE_TRUNC('month', exchange_date);

-- Insight 11: Top 10 Returning Products
WITH SalesByProduct AS (
    SELECT
        product_id,
        COUNT(order_id) AS total_sales
    FROM
        orders
    GROUP BY
        product_id
),
ReturnsByProduct AS (
    SELECT
        product_id,
        COUNT(return_id) AS total_returns
    FROM
        returns
    GROUP BY
        product_id
),
ReturnRates AS (
    SELECT
        p.product_name,
        COALESCE(r.total_returns, 0) AS total_returns,
        COALESCE(s.total_sales, 0) AS total_sales,
        CASE
            WHEN COALESCE(s.total_sales, 0) > 0 THEN ROUND(CAST(COALESCE(r.total_returns, 0) AS DECIMAL) / s.total_sales * 100, 2)
            ELSE 0
        END AS return_percentage
    FROM
        products p
    LEFT JOIN ReturnsByProduct r ON p.product_id = r.product_id
    LEFT JOIN SalesByProduct s ON p.product_id = s.product_id
),
RankedReturnRates AS (
    SELECT
        product_name,
        total_returns,
        total_sales,
        return_percentage,
        RANK() OVER (ORDER BY return_percentage DESC, total_returns DESC) as rank
    FROM
        ReturnRates
)
SELECT
    product_name,
    total_returns,
    total_sales,
    return_percentage
FROM
    RankedReturnRates
WHERE
    rank <= 10;
	
------------- Employee Training Analysis -------------

-- Insight 12:Effectiveness of Training Sessions
SELECT
    training_date,
    AVG(effectiveness_rating) AS average_effectiveness
FROM
    training_sessions
GROUP BY
    training_date
ORDER BY
    training_date;
	
-- Insight 13:Correlation between Effectiveness and Duration
SELECT
    duration,
    AVG(effectiveness_rating) AS average_effectiveness
FROM
    training_sessions
GROUP BY
    duration
ORDER BY
    duration;
	
	