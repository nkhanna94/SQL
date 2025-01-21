## **B. Data Analysis Questions**

### **1. How many customers has Foodie-Fi ever had?**

**Explanation:**
This query counts the total number of unique customers in the dataset by selecting distinct `customer_id` values from the `subscriptions` table.

```sql
SELECT COUNT(DISTINCT customer_id) AS no_of_customers 
FROM subscriptions;
```

**Output:**

| no_of_customers |
| --- |
| 1000 |

---

### **2. What is the monthly distribution of trial plan start_date values?**

**Explanation:**
This query groups customers by the month of their `start_date` for the trial plan (`plan_id = 0`) and counts how many customers started in each month. The month names are displayed for clarity.

```sql
SELECT 
    EXTRACT(MONTH FROM start_date) AS index,
    TO_CHAR(start_date, 'Month') AS monthname,
    COUNT(*) AS no_of_customers
FROM subscriptions
WHERE plan_id = 0
GROUP BY 1, 2
ORDER BY 1;
```

**Output:**

| index | monthname  | no_of_customers |
| ---   | ---        | ---             |
| 1     | January    | 88              |
| 2     | February   | 68              |
| 3     | March      | 94              |
| 4     | April      | 81              |
| 5     | May        | 88              |
| 6     | June       | 79              |
| 7     | July       | 89              |
| 8     | August     | 88              |
| 9     | September  | 87              |
| 10    | October    | 79              |
| 11    | November   | 75              |
| 12    | December   | 84              |

---

### **3. What plan start_date values occur after the year 2020?**

**Explanation:**
This query identifies the number of customers who started each subscription plan (`plan_name`) after the year 2020. It uses a conditional `SUM` to count relevant records.

```sql
SELECT 
    plan_id, 
    plan_name,
    SUM(CASE WHEN start_date > '2020-12-31' THEN 1 ELSE 0 END) AS customer_count
FROM subscriptions 
JOIN plans USING (plan_id)
GROUP BY 1, 2
ORDER BY 1;
```

**Output:**

| plan_id | plan_name      | customer_count |
| ---     | ---            | ---            |
| 0       | trial          | 0              |
| 1       | basic monthly  | 8              |
| 2       | pro monthly    | 60             |
| 3       | pro annual     | 63             |
| 4       | churn          | 71             |

---

### **4. What is the customer count and percentage of customers who have churned?**

**Explanation:**
This query calculates the total number of customers who have churned (`plan_id = 4`) and their percentage relative to the total customer base. The percentage is rounded to one decimal place.

```sql
SELECT 
    COUNT(customer_id) AS total_churned_count,
    ROUND(100.0 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS churned_percentage
FROM subscriptions
WHERE plan_id = 4;
```

**Output:**

| total_churned_count | churned_percentage |
| ---                 | ---                |
| 307                 | 30.7               |

---

Here is the concise README file for the additional analysis questions:

---

### **5. How many customers have churned straight after their initial free trial?**

**Explanation:**
This query calculates the total number and percentage of customers who churned (`plan_id = 4`) immediately after their trial (`plan_id = 0`).

```sql
WITH temp_cte AS (
    SELECT 
        customer_id, 
        plan_id, 
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn 
    FROM subscriptions
)
SELECT 
    COUNT(*) AS total_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 2) AS percentage
FROM temp_cte
WHERE rn = 2 AND plan_id = 4;
```

**Output:**

| total_count | percentage |
| ---         | ---        |
| 92          | 9.20       |

---

### **6. What is the number and percentage of customer plans after their initial free trial?**

**Explanation:**
This query identifies the distribution of customers across subscription plans (`plan_id`) after their trial and calculates the percentage breakdown.

```sql
WITH temp_cte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS rn 
    FROM subscriptions 
    JOIN plans USING (plan_id)
)
SELECT 
    plan_id, 
    plan_name, 
    COUNT(DISTINCT customer_id), 
    ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 2) AS percentage
FROM temp_cte 
WHERE rn = 2
GROUP BY 1, 2
ORDER BY 1;
```

**Output:**

| plan_id | plan_name       | count | percentage |
| ---     | ---             | ---   | ---        |
| 1       | basic monthly   | 546   | 54.60      |
| 2       | pro monthly     | 325   | 32.50      |
| 3       | pro annual      | 37    | 3.70       |
| 4       | churn           | 92    | 9.20       |

---

### **7. What is the customer count and percentage breakdown of all plans at 2020-12-31?**

**Explanation:**
This query calculates the number and percentage of customers subscribed to each plan at the end of 2020.

```sql
WITH temp_cte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS rn
    FROM subscriptions
    JOIN plans USING (plan_id)
    WHERE start_date <= '2020-12-31'
),
customer_totals AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers
    FROM temp_cte
    WHERE rn = 1
)
SELECT 
    plan_id, 
    plan_name, 
    COUNT(DISTINCT customer_id) AS customer_count, 
    ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT total_customers FROM customer_totals), 2) AS percentage
FROM temp_cte
WHERE rn = 1
GROUP BY 1, 2
ORDER BY 1;
```

**Output:**

| plan_id | plan_name        | customer_count | percentage |
| ---     | ---              | ---            | ---        |
| 0       | trial            | 19             | 1.90       |
| 1       | basic monthly    | 224            | 22.40      |
| 2       | pro monthly      | 326            | 32.60      |
| 3       | pro annual       | 195            | 19.50      |
| 4       | churn            | 236            | 23.60      |

---

### **8. How many customers upgraded to an annual plan in 2020?**

**Explanation:**
This query counts the number of customers who started an annual plan (`plan_id = 3`) in 2020.

```sql
SELECT 
    COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions 
WHERE plan_id = 3 
    AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```

**Output:**

| customer_count |
| ---            |
| 195            |

---

### **9. How many days on average does it take for a customer to upgrade to an annual plan?**

**Explanation:**
This query calculates the average time taken (in days) for a customer to upgrade from a trial (`plan_id = 0`) to an annual plan (`plan_id = 3`).

```sql
SELECT 
    AVG(next_date - start_date)
FROM (
    SELECT * FROM subscriptions WHERE plan_id = 0
) t1 
JOIN (
    SELECT customer_id, start_date AS next_date FROM subscriptions WHERE plan_id = 3
) t2 ON t1.customer_id = t2.customer_id;
```

**Output:**

| avg                |
| ---                |
| 104.62 days        |

---

### **10. How is the average upgrade time distributed into 30-day periods?**

**Explanation:**
This query breaks down the upgrade time into 30-day intervals and counts the number of customers in each range.

```sql
WITH cte AS (
    SELECT * 
    FROM subscriptions 
    JOIN plans USING (plan_id)
)
SELECT 
    days, 
    COUNT(*)
FROM (
    SELECT 
        ((date_diff - 1) / 30) * 30 + 1 || ' - ' || ((date_diff - 1) / 30 + 1) * 30 || ' days' AS days
    FROM (
        SELECT 
            cte.*, 
            start_date - LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS date_diff
        FROM cte
        WHERE plan_id IN (0, 3)
    ) temp
) temp
WHERE days IS NOT NULL
GROUP BY days
ORDER BY days;
```

**Output:**

| days           | count |
| ---            | ---   |
| 1 - 30 days    | 49    |
| 31 - 60 days   | 24    |
| 61 - 90 days   | 34    |
| 91 - 120 days  | 35    |
| 121 - 150 days | 42    |
| 151 - 180 days | 36    |
| 181 - 210 days | 26    |
| 211 - 240 days | 4     |
| 241 - 270 days | 5     |
| 271 - 300 days | 1     |
| 301 - 330 days | 1     |
| 331 - 360 days | 1     |

---

### **11. How many customers downgraded from pro monthly to basic monthly in 2020?**

**Explanation:**
This query counts customers who moved from a pro monthly plan (`plan_id = 2`) to a basic monthly plan (`plan_id = 1`) in 2020.

```sql
WITH cte AS (
    SELECT * 
    FROM subscriptions 
    JOIN plans USING (plan_id)
)
SELECT 
    COUNT(DISTINCT customer_id) AS downgraded
FROM (
    SELECT 
        cte.*, 
        LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan_id
    FROM cte
) temp
WHERE next_plan_id = 1 AND plan_id = 2;
```

**Output:**

| downgraded |
| ---        |
| 0          |

--- 
