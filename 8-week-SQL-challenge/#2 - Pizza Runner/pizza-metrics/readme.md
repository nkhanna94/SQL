# A. Pizza Metrics

Below are the SQL solutions and insights for the **Pizza Metrics** sub-case study of **Case Study 2: Pizza Runner**. The focus is on analyzing pizza orders, customer preferences, and delivery performance.

---

## Questions and Solutions

### 1. How many pizzas were ordered?
```sql
SELECT COUNT(order_id) 
FROM customer_orders;
```
**Output:**  
| total_pizzas_ordered |  
|-----------------------|  
| 14                    |  

**Explanation:**  
This query counts all the `order_id` values in the `customer_orders` table, representing the total number of pizzas ordered.

---

### 2. How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS total_unique_orders 
FROM customer_orders;
```
**Output:**  
| total_unique_orders |  
|---------------------|  
| 10                  |  

**Explanation:**  
The `DISTINCT` clause ensures only unique `order_id` values are counted, representing individual customer orders.

---

### 3. How many successful orders were delivered by each runner?
```sql
SELECT runner_id, 
       COUNT(DISTINCT order_id) AS total_orders_delivered 
FROM runner_orders_temp 
WHERE pickup_time IS NOT NULL 
GROUP BY runner_id;
```
**Output:**  
| runner_id | total_orders_delivered |  
|-----------|------------------------|  
| 1         | 4                      |  
| 2         | 3                      |  
| 3         | 1                      |  

**Explanation:**  
The `pickup_time IS NOT NULL` condition filters only successful deliveries, while grouping by `runner_id` counts each runner's successful deliveries.

---

### 4. How many of each type of pizza was delivered?
```sql
SELECT pizza_name, 
       COUNT(ct.pizza_id) AS typesof_pizza_delivered 
FROM runner_orders_temp AS rt 
JOIN customer_orders_temp AS ct ON ct.order_id = rt.order_id 
JOIN pizza_names AS pn ON pn.pizza_id = ct.pizza_id 
WHERE pickup_time IS NOT NULL 
GROUP BY pizza_name;
```
**Output:**  
| pizza_name  | typesof_pizza_delivered |  
|-------------|--------------------------|  
| Meatlovers  | 9                        |  
| Vegetarian  | 3                        |  

**Explanation:**  
The query joins relevant tables and filters successful deliveries (`pickup_time IS NOT NULL`) to count the delivered pizzas of each type.

---

### 5. How many Vegetarian and Meatlovers pizzas were ordered by each customer?
```sql
SELECT ct.customer_id, 
       pn.pizza_name, 
       COUNT(customer_id) AS pizza_count 
FROM customer_orders_temp AS ct 
JOIN pizza_names AS pn ON pn.pizza_id = ct.pizza_id 
WHERE pizza_name IN ('Meatlovers', 'Vegetarian') 
GROUP BY ct.customer_id, pn.pizza_name 
ORDER BY ct.customer_id;
```
**Output:**  
| customer_id | pizza_name  | pizza_count |  
|-------------|-------------|-------------|  
| 101         | Meatlovers  | 2           |  
| 101         | Vegetarian  | 1           |  
| 102         | Meatlovers  | 2           |  
| 102         | Vegetarian  | 1           |  
| 103         | Meatlovers  | 3           |  
| 103         | Vegetarian  | 1           |  
| 104         | Meatlovers  | 3           |  
| 105         | Vegetarian  | 1           |  

**Explanation:**  
The query groups data by `customer_id` and `pizza_name` to count the number of Vegetarian and Meatlovers pizzas ordered by each customer.

---

### 6. What was the maximum number of pizzas delivered in a single order?
```sql
SELECT order_id, 
       COUNT(pizza_id) AS pizza_count 
FROM customer_orders_temp 
JOIN runner_orders_temp USING (order_id) 
WHERE pickup_time IS NOT NULL 
GROUP BY order_id 
ORDER BY pizza_count DESC 
LIMIT 1;
```
**Output:**  
| order_id | pizza_count |  
|----------|-------------|  
| 4        | 3           |  

**Explanation:**  
The query identifies the `order_id` with the highest number of pizzas delivered using `GROUP BY` and orders the results in descending order. The `LIMIT 1` ensures only the top result is shown.

---

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT customer_id,
       SUM(CASE 
           WHEN exclusions IS NULL
           AND extras IS NULL
           THEN 1 ELSE 0 
           END) AS no_change,
       SUM(CASE 
           WHEN exclusions IS NOT NULL
           OR extras IS NOT NULL
           THEN 1 ELSE 0 
           END) AS atleast_one_change
FROM customer_orders_temp 
JOIN runner_orders_temp USING (order_id)
WHERE pickup_time IS NOT NULL
GROUP BY 1;
```
**Output:**  
| customer_id | no_change | atleast_one_change |  
|-------------|-----------|--------------------|  
| 101         | 2         | 0                  |  
| 103         | 0         | 3                  |  
| 104         | 1         | 2                  |  
| 105         | 0         | 1                  |  
| 102         | 3         | 0                  |  

**Explanation:**  
This query uses `CASE` statements to classify pizzas as either having no changes (`exclusions` and `extras` are `NULL`) or having at least one change (`exclusions` or `extras` are `NOT NULL`). The results are grouped by `customer_id`.

---

### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT SUM(CASE 
           WHEN exclusions IS NOT NULL
           AND extras IS NOT NULL
           THEN 1 ELSE 0 
           END) AS atleast_one_change
FROM customer_orders_temp 
JOIN runner_orders_temp USING (order_id)
WHERE pickup_time IS NOT NULL;
```
**Output:**  
| atleast_one_change |  
|--------------------|  
| 1                  |  

**Explanation:**  
The query counts the pizzas that had both `exclusions` and `extras` by checking if both columns are `NOT NULL` in delivered orders (`pickup_time IS NOT NULL`).

---

### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT EXTRACT(hour FROM order_time) AS hour,
       COUNT(*) AS pizzas_ordered
FROM customer_orders_temp 
GROUP BY 1;
```
**Output:**  
| hour | pizzas_ordered |  
|------|----------------|  
| 18   | 3              |  
| 23   | 3              |  
| 21   | 3              |  
| 11   | 1              |  
| 19   | 1              |  
| 13   | 3              |  

**Explanation:**  
Using the `EXTRACT` function, this query retrieves the hour from the `order_time` column and counts the total pizzas ordered in each hour.

---

### 10. What was the volume of orders for each day of the week?
```sql
SELECT TO_CHAR(order_time, 'Day') AS "Day of the week",
       COUNT(*) AS pizzas_ordered,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS net_volume
FROM customer_orders_temp 
GROUP BY 1
ORDER BY 2 DESC;
```
**Output:**  
| Day of the week | pizzas_ordered | net_volume |  
|-----------------|----------------|------------|  
| Saturday        | 5              | 35.71      |  
| Wednesday       | 5              | 35.71      |  
| Thursday        | 3              | 21.43      |  
| Friday          | 1              | 7.14       |  

**Explanation:**  
This query groups orders by the day of the week using the `TO_CHAR` function. It calculates the percentage of orders (`net_volume`) for each day by dividing the day's orders by the total orders, multiplied by 100. The result is sorted in descending order of pizzas ordered.

---
