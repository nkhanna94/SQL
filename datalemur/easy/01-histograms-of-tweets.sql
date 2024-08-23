-- Method 1 :- CTE 
-- First, we're grouping the users by the number of tweets they posted in 2022
WITH tweets_2022 AS (
  SELECT user_id, COUNT(*) AS tweet_bucket
  FROM tweets
  WHERE EXTRACT(YEAR FROM tweet_date) = '2022'
  GROUP BY user_id
)

-- Next, we're counting how many users fall into each group,
-- basically figuring out how many users posted the same number of tweets, 
-- like how many users posted exactly 1 tweet, 2 tweets, and so on.
SELECT tweet_bucket, COUNT(*) AS user_num
FROM tweets_2022
GROUP BY tweet_bucket;


-- Method 2 :- Subquery
SELECT tweet_bucket, COUNT(*) AS user_num
FROM (
    SELECT user_id, COUNT(*) AS tweet_bucket
    FROM tweets
    WHERE EXTRACT(YEAR FROM tweet_date) = '2022'
    GROUP BY user_id
) AS tweet_counts
GROUP BY tweet_bucket;

