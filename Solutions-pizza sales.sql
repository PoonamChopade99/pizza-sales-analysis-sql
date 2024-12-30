-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_order_count
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(o.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(o.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS name_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_count_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(o.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;





-- Calculate the percentage contribution of each pizza type to total revenue.

WITH TotalRevenue AS (
    SELECT 
        ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
    FROM 
        order_details AS o
    JOIN 
        pizzas AS p ON o.pizza_id = p.pizza_id
)
select pt.category,
concat(
round(sum(o.quantity * p.price)/
 (SELECT total_revenue from TotalRevenue)*100,2),'%')as revenue
from pizza_types pt join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details o
on p.pizza_id = o.pizza_id
group by pt.category order by revenue desc;




-- Analyze the cumulative revenue generated over time.

WITH sales AS (
    SELECT 
        o.order_date, 
        SUM(od.quantity * p.price) AS total_revenue
    FROM 
        order_details AS od
    JOIN 
        pizzas AS p ON od.pizza_id = p.pizza_id
    JOIN 
        orders AS o ON o.order_id = od.order_id
    GROUP BY 
        o.order_date
)

SELECT 
    s.order_date,
    SUM(s.total_revenue) OVER (ORDER BY s.order_date) AS cumulative_revenue
FROM 
    sales AS s
ORDER BY 
    s.order_date;




-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH PizzaRevenue AS (
    SELECT 
        pt.category as category,
        pt.name as name,
        SUM(o.quantity * p.price) AS total_revenue
    FROM 
        order_details AS o
    JOIN 
        pizzas AS p ON o.pizza_id = p.pizza_id
    JOIN 
        pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY 
        pt.category, pt.name
),


RankedPizzas AS (
    SELECT 
        category,
        name,
        total_revenue,
        rank() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS rn
    FROM 
        PizzaRevenue
)
SELECT name,total_revenue
FROM RankedPizzas
WHERE rn <= 3
ORDER BY category, rn;









