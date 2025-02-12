
## [Case Study 1 : Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)

<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image" width="450" height="450">

# Danny's Pizza Case Study - SQL Challenge

This repository contains the solutions to the **Danny's Pizza** case study from the 8-week SQL challenge. The aim of the project was to analyze the sales and customer data to generate insights about customer behavior and product performance.

## Tasks and Solutions

### Task 1: Total Revenue by Customer
**Question:** What is the total revenue generated by each customer?

```sql
SELECT
  s.customer_id,
  SUM(m.price) AS total_price
FROM dannys_diner.sales AS s 
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY 1;
```

**Output:**
| customer_id | total_price |
| ---         | ---        |
| B           | 74         |
| C           | 36         |
| A           | 76         |

**Explanation:**  
This query calculates the total revenue per customer by summing the prices of the products they've purchased. We join the `sales` table with the `menu` to access product prices, grouping the result by customer ID.

---

### Task 2: Total Days Each Customer Ordered
**Question:** How many distinct days did each customer place an order?

```sql
SELECT
  s.customer_id,
  COUNT(DISTINCT s.order_date) AS total_days
FROM dannys_diner.sales s
GROUP BY s.customer_id;
```

**Output:**
| customer_id | total_days |
| ---         | ---        |
| A           | 4          |
| B           | 6          |
| C           | 2          |

**Explanation:**  
Here, we're counting how many distinct days each customer made an order. We use COUNT(DISTINCT s.order_date) to get the number of unique order dates for every customer.

---

### Task 3: First Item Purchased by Each Customer
**Question:** What was the first item purchased by each customer?

```sql
WITH first_order AS (
  SELECT s.customer_id,
         m.product_name,
         ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) as rn
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id,
       product_name
FROM first_order
WHERE rn = 1;
```

**Output:**
| customer_id | product_name |
| ---         | ---         |
| A           | curry       |
| B           | curry       |
| C           | ramen       |

**Explanation:**  
To find the first item purchased by each customer, we use ROW_NUMBER() to rank each item by order date and then select the first item for each customer. This way, we ensure that we get the earliest purchase.

---

### Task 4: Most Purchased Item and Its Frequency
**Question:** What is the most purchased item on the menu, and how many times was it purchased?

```sql
SELECT m.product_name as most_purchased,
       count(s.product_id) as frequency
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

**Output:**
| most_purchased | frequency |
| ---            | ---      |
| ramen          | 8        |

**Explanation:**  
This query counts how many times each item was purchased, orders the items by frequency, and selects the most purchased one. It gives us an insight into the most popular item on the menu.

---

### Task 5: Most Purchased Item by Customer
**Question:** What is the most purchased item by each customer?

```sql
WITH ranked_items AS (
  SELECT
    s.customer_id,
    m.product_name AS most_purchased_item,
    COUNT(s.product_id) AS frequency,
    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rn
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT
  customer_id,
  most_purchased_item,
  frequency
FROM ranked_items
WHERE rn = 1;
```

**Output:**
| customer_id | most_purchased_item | frequency |
| ---         | ---                | ---      |
| A           | ramen              | 3        |
| B           | ramen              | 2        |
| C           | ramen              | 3        |

**Explanation:**  
Here, we rank items for each customer based on how often they bought them and select the most purchased item for each one. This helps us understand each customer’s favorite item.

---

### Task 6: First Purchase After Membership
**Question:** What was the first item purchased after a customer became a member?

```sql
WITH first_purchase AS (
  SELECT
    s.customer_id,
    m.product_name,
    s.order_date,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn
  FROM dannys_diner.sales AS s
  INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
  INNER JOIN dannys_diner.members AS mem ON s.customer_id = mem.customer_id
  WHERE s.order_date >= mem.join_date
)
SELECT customer_id, product_name, order_date
FROM first_purchase
WHERE rn = 1;
```

**Output:**
| customer_id | product_name | order_date |
| ---         | ---         | ---        |
| A           | curry       | 2021-01-07 |
| B           | sushi       | 2021-01-11 |

**Explanation:**  
This query finds the first purchase made by each customer after joining the membership. By filtering for purchases made after their join date, we get the first item they bought once they became a member.

---

### Task 7: Last Purchase Before Membership
**Question:** Which item was purchased just before the customer became a member?

```sql
WITH last_purchase AS (
  SELECT
    s.customer_id,
    m.product_name,
    s.order_date,
    ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rn
  FROM dannys_diner.sales AS s
  INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
  INNER JOIN dannys_diner.members AS mem ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
)
SELECT customer_id, product_name, order_date
FROM last_purchase
WHERE rn = 1;
```

**Output:**
| customer_id | product_name | order_date |
| ---         | ---         | ---        |
| A           | sushi       | 2021-01-01 |
| B           | sushi       | 2021-01-04 |

**Explanation:**  
To identify the last purchase before membership, we rank purchases in descending order by date and filter to find the most recent purchase made before the customer became a member.

---

### Task 8: Items Purchased Before Membership
**Question:** What was the total number of items and the amount spent before customers became members?

```sql
WITH items_purchased AS (
  SELECT
    s.customer_id,
    COUNT(s.product_id) as total_items,
    SUM(m.price) as amount_spent
  FROM dannys_diner.sales AS s
  INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
  INNER JOIN dannys_diner.members AS mem ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
  GROUP BY s.customer_id
)
SELECT customer_id, total_items, amount_spent
FROM items_purchased;
```

**Output:**
| customer_id | total_items | amount_spent |
| ---         | ---         | ---          |
| B           | 3           | 40           |
| A           | 2           | 25           |

**Explanation:**  
Here, we calculate the total number of items and amount spent by each customer before they became a member. It’s a useful way to measure customer activity before joining the membership program.

---

### Task 9: Total Points by Customer
**Question:** What is the total number of points earned by each customer?

```sql
SELECT
  s.customer_id,
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN m.price * 20  
    ELSE m.price * 10                               
  END) AS total_points
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

**Output:**
| customer_id | total_points |
| ---         | ---         |
| B           | 940         |
| C           | 360         |
| A           | 860         |

**Explanation:**  
In this query, we calculate points for each customer based on their purchases. We apply a higher multiplier for sushi (20 points) and a regular multiplier for other items (10 points), which helps us track their point accumulation.

---

### Task 10: Points at End of January
**Question:** How many points do customers A and B have at the end of January after the first-week promotion?

```sql
SELECT
  s.customer_id,
  SUM(CASE
    WHEN s.order_date <= mem.join_date + INTERVAL '7 DAYS' OR m.product_name = 'sushi' THEN m.price * 20
    ELSE m.price * 10
  END) AS total_points
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
INNER JOIN dannys_diner.members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date < '2021-01-31'
GROUP BY 1;
```

**Output:**
| customer_id | total_points |
| ---         | ---         |
| A           | 1520        |
| B           | 1240        |

**Explanation:**  
This query calculates points at the end of January for customers who joined the membership program in January. During their first week, they earn double points for all items, which we account for in the calculation.

---

## Bonus Questions

### **Task 1: Join All The Things**

**Question:**: Recreate the table showing each customer's purchase history along with their membership status ('Y' or 'N') at the time of the order.
| **customer_id** | **order_date** | **product_name** | **price** | **member** |
| --- | --- | --- | --- | --- |
| A | 2021-01-01 | curry | 15 | N |
| A | 2021-01-01 | sushi | 10 | N |
| A | 2021-01-07 | curry | 15 | Y |
| A | 2021-01-10 | ramen | 12 | Y |
| A | 2021-01-11 | ramen | 12 | Y |
| A | 2021-01-11 | ramen | 12 | Y |
| B | 2021-01-01 | curry | 15 | N |
| B | 2021-01-02 | curry | 15 | N |
| B | 2021-01-04 | sushi | 10 | N |
| B | 2021-01-11 | sushi | 10 | Y |
| B | 2021-01-16 | ramen | 12 | Y |
| B | 2021-02-01 | ramen | 12 | Y |
| C | 2021-01-01 | ramen | 12 | N |
| C | 2021-01-01 | ramen | 12 | N |
| C | 2021-01-07 | ramen | 12 | N |

**Solution**:
```sql
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= mem.join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales s
INNER JOIN menu m on s.product_id = m.product_id
INNER JOIN members mem ON s.customer_id = mem.customer_id;
```
**Explanation:** This query combines sales, menu, and membership data to show each customer's order with the product name, price, and membership status (Y or N based on the join date).

### **Task 2: Rank All The Things**

**Question:**: Rank the purchases of customers who have joined the loyalty program, and mark non-members with a NULL ranking.

```sql
WITH members_cte AS (
    SELECT
        sales.customer_id,
        sales.order_date,
        menu.product_name,
        menu.price,
        CASE
            WHEN members.join_date > sales.order_date THEN 'N'
            WHEN members.join_date <= sales.order_date THEN 'Y'
            ELSE 'N'
        END AS member_status
    FROM sales
    LEFT JOIN members
    ON sales.customer_id = members.customer_id
    INNER JOIN menu
    ON sales.product_id = menu.product_id
)

SELECT
    *,
    CASE
        WHEN member_status = 'N' THEN NULL
        ELSE RANK() OVER (
            PARTITION BY customer_id, member_status
            ORDER BY order_date
        )
    END AS ranking
FROM members_cte;
```

**Output:**

| **customer_id** | **order_date** | **product_name** | **price** | **member** | **ranking** |
| --- | --- | --- | --- | --- | --- |
| A | 2021-01-01 | curry | 15 | N | null |
| A | 2021-01-01 | sushi | 10 | N | null |
| A | 2021-01-07 | curry | 15 | Y | 1 |
| A | 2021-01-10 | ramen | 12 | Y | 2 |
| A | 2021-01-11 | ramen | 12 | Y | 3 |
| A | 2021-01-11 | ramen | 12 | Y | 3 |
| B | 2021-01-01 | curry | 15 | N | null |
| B | 2021-01-02 | curry | 15 | N | null |
| B | 2021-01-04 | sushi | 10 | N | null |
| B | 2021-01-11 | sushi | 10 | Y | 1 |
| B | 2021-01-16 | ramen | 12 | Y | 2 |
| B | 2021-02-01 | ramen | 12 | Y | 3 |
| C | 2021-01-01 | ramen | 12 | N | null |
| C | 2021-01-01 | ramen | 12 | N | null |
| C | 2021-01-07 | ramen | 12 | N | null |

**Explanation:** This query ranks customer orders, but only for members. Non-members will have NULL for their ranking. The rank is determined by the order date for each customer.
