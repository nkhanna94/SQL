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


What is the number and percentage of customer plans after their initial free trial?
What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
How many customers have upgraded to an annual plan in 2020?
How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
