## **C. Ingredient Optimization**

### **1. What are the standard ingredients for each pizza?**

**Explanation:**
This query retrieves the standard ingredients (toppings) for each pizza by joining the `pizza_recipes`, `pizza_names`, and `pizza_toppings` tables. It aggregates the toppings for each pizza and lists them.

```sql
SELECT 
    pn.pizza_name, 
    string_agg(t.topping_name, ', ') AS toppings
FROM 
    pizza_recipes pr
JOIN 
    pizza_names pn ON pr.pizza_id = pn.pizza_id
JOIN 
    pizza_toppings t ON t.topping_id = ANY(string_to_array(pr.toppings, ',')::int[])
GROUP BY 
    pn.pizza_name
ORDER BY 
    pn.pizza_name;
```

**Output:**

| pizza_name | toppings |
| --- | --- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce |

---

### **2. What was the most commonly added extra?**

**Explanation:**
This query counts the frequency of each extra topping added by customers. It uses a `CTE` (Common Table Expression) to find the most added extra topping from the `customer_orders_temp` table.

```sql
WITH toppings_cte AS (
    SELECT unnest(string_to_array(extras, ',')::int[]) AS topping_id, COUNT(*) 
    FROM customer_orders_temp
    WHERE extras IS NOT NULL 
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1
)
SELECT *
FROM toppings_cte 
JOIN pizza_toppings USING (topping_id);
```

**Output:**

| topping_id | count | topping_name |
| --- | --- | --- |
| 1 | 4 | Bacon |

---

### **3. What was the most common exclusion?**

**Explanation:**
This query identifies the most commonly excluded topping from customer orders. It counts the exclusions and selects the most frequent one from the `customer_orders_temp` table.

```sql
WITH toppings_cte AS (
    SELECT unnest(string_to_array(exclusions, ',')::int[]) AS topping_id, COUNT(*) 
    FROM customer_orders_temp
    WHERE exclusions IS NOT NULL 
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1
)
SELECT *
FROM toppings_cte 
JOIN pizza_toppings USING (topping_id);
```

**Output:**

| topping_id | count | topping_name |
| --- | --- | --- |
| 4 | 4 | Cheese |

---

### **4. Generate an order item description**

**Explanation:**
This query generates a detailed description for each order item, including the pizza name, exclusions, and extras. It handles multiple exclusions and extras by using lateral joins to fetch the toppings.

```sql
SELECT co.order_id, 
    pn.pizza_name ||
    CASE WHEN exclusions IS NOT NULL THEN ' - Exclude ' || excluded_toppings
    ELSE '' END ||
    CASE WHEN extras IS NOT NULL THEN ' - Extra ' || extra_toppings
    ELSE '' END AS order_item
FROM customer_orders_temp co 
JOIN pizza_names pn USING (pizza_id)
LEFT JOIN LATERAL (
    SELECT string_agg(pt.topping_name, ', ') AS excluded_toppings
    FROM unnest(string_to_array(co.exclusions, ',')::int[]) AS e(topping_id)
    JOIN pizza_toppings pt ON e.topping_id = pt.topping_id
) e ON true
LEFT JOIN LATERAL (
    SELECT string_agg(pt.topping_name, ', ') AS extra_toppings
    FROM unnest(string_to_array(co.extras, ',')::int[]) AS x(topping_id)
    JOIN pizza_toppings pt ON x.topping_id = pt.topping_id
) x ON true
ORDER BY 1;
```

**Output:**

| order_id | order_item |
| --- | --- |
| 1 | Meatlovers |
| 2 | Meatlovers |
| 3 | Vegetarian |
| 3 | Meatlovers |
| 4 | Meatlovers - Exclude Cheese |
| 4 | Meatlovers - Exclude Cheese |
| 4 | Vegetarian - Exclude Cheese |
| 5 | Meatlovers - Extra Bacon |
| 6 | Vegetarian |
| 7 | Vegetarian - Extra Bacon |
| 8 | Meatlovers |
| 9 | Meatlovers - Exclude Cheese - Extra Bacon, Chicken |
| 10 | Meatlovers |
| 10 | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

---
