# **Data Cleaning for Pizza Runner Orders**

This repository contains SQL scripts for cleaning `customer_orders` and `runner_orders` tables to ensure valid and consistent data for analysis.

### **1. Clean `customer_orders_temp` Table**

The table `customer_orders_temp` is created by:
- Replacing empty or 'null' values in `exclusions` and `extras` with `NULL`.

```sql
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id, customer_id, pizza_id,
       CASE 
           WHEN exclusions = '' OR exclusions = 'null' THEN NULL
           ELSE exclusions
       END AS exclusions,
       CASE 
           WHEN extras = '' OR extras = 'null' THEN NULL
           ELSE extras
       END AS extras,
       order_time
FROM customer_orders;
```

**Resulting Table (`customer_orders_temp`)**:

| order_id | customer_id | pizza_id | exclusions | extras | order_time          |
|----------|-------------|----------|------------|--------|---------------------|
| 1        | 101         | 1        | NULL       | NULL   | 2020-01-01 18:05:02 |
| 2        | 101         | 1        | NULL       | NULL   | 2020-01-01 19:00:52 |
| 3        | 102         | 1        | NULL       | NULL   | 2020-01-02 23:51:23 |
| 3        | 102         | 2        | NULL       | NULL   | 2020-01-02 23:51:23 |
| 4        | 103         | 1        | 4          | NULL   | 2020-01-04 13:23:46 |
| 4        | 103         | 1        | 4          | NULL   | 2020-01-04 13:23:46 |
| 4        | 103         | 2        | 4          | NULL   | 2020-01-04 13:23:46 |
| 5        | 104         | 1        | NULL       | 1      | 2020-01-08 21:00:29 |
| 6        | 101         | 2        | NULL       | NULL   | 2020-01-08 21:03:13 |
| 7        | 105         | 2        | NULL       | 1      | 2020-01-08 21:20:29 |
| 8        | 102         | 1        | NULL       | NULL   | 2020-01-09 23:54:33 |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59 |
| 10       | 104         | 1        | NULL       | NULL   | 2020-01-11 18:34:49 |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49 |

---

### **2. Clean `runner_orders_temp` Table**

The table `runner_orders_temp` is created by:
- Replacing 'null' with `NULL` in `pickup_time`, `distance`, `duration`, and `cancellation`.
- Converting `distance` and `duration` from string to `FLOAT` by removing alphabetic characters.

```sql
DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id,
       CASE WHEN pickup_time = 'null' THEN NULL ELSE pickup_time END AS pickup_time,
       CASE WHEN distance = 'null' THEN NULL ELSE CAST(REGEXP_REPLACE(distance, '[a-z]+', '') AS FLOAT) END AS distance,
       CASE WHEN duration = 'null' THEN NULL ELSE CAST(REGEXP_REPLACE(duration, '[a-z]+', '') AS FLOAT) END AS duration,
       CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL ELSE cancellation END AS cancellation
FROM runner_orders;
```

**Resulting Table (`runner_orders_temp`)**:

| order_id | runner_id | pickup_time           | distance | duration | cancellation       |
|----------|-----------|-----------------------|----------|----------|--------------------|
| 1        | 1         | 2020-01-01 18:15:34   | 20       | 32       | NULL               |
| 2        | 1         | 2020-01-01 19:10:54   | 20       | 27       | NULL               |
| 3        | 1         | 2020-01-03 00:12:37   | 13.4     | 20       | NULL               |
| 4        | 2         | 2020-01-04 13:53:03   | 23.4     | 40       | NULL               |
| 5        | 3         | 2020-01-08 21:10:57   | 10       | 15       | NULL               |
| 6        | 3         | NULL                  | NULL     | NULL     | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45   | 25       | 25       | NULL               |
| 8        | 2         | 2020-01-10 00:15:02   | 23.4     | 15       | NULL               |
| 9        | 2         | NULL                  | NULL     | NULL     | Customer Cancellation |
| 10       | 1         | 2020-01-11 18:50:20   | 10       | 10       | NULL               |

---

### **Outcome**
- Cleaned `customer_orders_temp` and `runner_orders_temp` tables are now ready for further analysis.

---
