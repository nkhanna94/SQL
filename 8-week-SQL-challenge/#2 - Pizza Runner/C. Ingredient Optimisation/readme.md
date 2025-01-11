What are the standard ingredients for each pizza?
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
pizza_name	toppings
Meatlovers	Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
Vegetarian	Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
What was the most commonly added extra?

What was the most common exclusion?
Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
