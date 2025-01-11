## B. Runner and Customer Experience

### 1. How many runners signed up for each 1-week period? (i.e., week starts 2021-01-01)
```sql
SELECT DATE_TRUNC('week', registration_date)::DATE AS week_start,
       COUNT(*) AS runners_signed_up
FROM runners
GROUP BY 1
ORDER BY 1;
```
**Output:**  
| week_start | runners_signed_up |  
|------------|-------------------|  
| 2020-12-28 | 2                 |  
| 2021-01-04 | 1                 |  
| 2021-01-11 | 1                 |  

**Explanation:**  
This query calculates the number of runners who signed up in each week, using `DATE_TRUNC` to group the `registration_date` by the start of the week.

---

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?
```sql
SELECT runner_id,
       ROUND(AVG(EXTRACT(MINUTE FROM (pickup_time::timestamp - order_time)))) AS avg_pickup_time_minutes
FROM runner_orders_temp 
JOIN customer_orders_temp USING (order_id)
WHERE distance IS NOT NULL AND pickup_time IS NOT NULL  
GROUP BY 1
ORDER BY 1;
```
**Output:**  
| runner_id | avg_pickup_time_minutes |  
|-----------|-------------------------|  
| 1         | 15                      |  
| 2         | 23                      |  
| 3         | 10                      |  

**Explanation:**  
This query calculates the average pickup time for each runner by subtracting `order_time` from `pickup_time`, then converting the result into minutes using `EXTRACT`.

---

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
SELECT 
    co.order_id,
    COUNT(co.pizza_id) AS num_pizzas,
    ROUND(CAST(EXTRACT(EPOCH FROM (ro.pickup_time::timestamp - co.order_time)) / 60 AS NUMERIC), 2) AS prep_time_minutes
FROM 
    customer_orders_temp AS co
JOIN 
    runner_orders_temp AS ro
USING (order_id)
WHERE 
    ro.pickup_time IS NOT NULL
GROUP BY 
    co.order_id, co.order_time, ro.pickup_time
ORDER BY 
    co.order_id;
```
**Output:**  
| order_id | num_pizzas | prep_time_minutes |  
|----------|------------|-------------------|  
| 1        | 1          | 10.53             |  
| 2        | 1          | 10.03             |  
| 3        | 2          | 21.23             |  
| 4        | 3          | 29.28             |  

**Explanation:**  
This query examines the relationship between the number of pizzas in an order (`num_pizzas`) and the preparation time (`prep_time_minutes`), which is derived from the difference between `order_time` and `pickup_time`.

---

### 4. What was the average distance travelled for each customer?
```sql
SELECT customer_id,
       ROUND(AVG(distance)) AS dist_travelled
FROM customer_orders_temp 
JOIN runner_orders_temp USING (order_id)
GROUP BY 1
ORDER BY 1;
```
**Output:**  
| customer_id | dist_travelled |  
|-------------|----------------|  
| 101         | 20             |  
| 102         | 17             |  
| 103         | 23             |  
| 104         | 10             |  
| 105         | 25             |  

**Explanation:**  
This query calculates the average distance traveled for each customer, aggregating the `distance` by `customer_id`.

---

### 5. What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT MAX(duration) - MIN(duration) AS difference
FROM runner_orders_temp
WHERE cancellation IS NULL;
```
**Output:**  
| difference |  
|------------|  
| 30         |  

**Explanation:**  
This query calculates the difference between the longest and shortest delivery times by subtracting the minimum `duration` from the maximum `duration` for all non-cancelled deliveries.

---

### 6. What was the average speed for each runner for each delivery, and do you notice any trend for these values?
```sql
SELECT runner_id,
       ROUND(AVG(60.0 * distance/duration)) AS avg_speed_Kmph
FROM runner_orders_temp
GROUP BY 1
ORDER BY 1; 
```
**Output:**  
| runner_id | avg_speed_kmph |  
|-----------|-----------------|  
| 1         | 46              |  
| 2         | 63              |  
| 3         | 40              |  

**Explanation:**  
This query calculates the average speed (`avg_speed_Kmph`) for each runner, using the formula `distance / duration` and multiplying by 60 to convert to kilometers per hour.

---

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT runner_id, ROUND(100.0 * SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) / count(*), 2) AS percentage
FROM runner_orders_temp
GROUP BY 1
ORDER BY 1;
```
**Output:**  
| runner_id | percentage |  
|-----------|------------|  
| 1         | 100.00     |  
| 2         | 75.00      |  
| 3         | 50.00      |  

**Explanation:**  
This query calculates the percentage of successful deliveries for each runner. It divides the number of non-cancelled deliveries by the total number of deliveries, then multiplies by 100 to get the percentage.

🚚🍕
