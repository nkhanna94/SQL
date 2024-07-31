SELECT COUNT(
  CASE
  WHEN (device_type = 'tablet' OR device_type = 'phone') THEN 1
  END) AS mobile_views,
COUNT(
  CASE
  WHEN device_type = 'laptop' THEN 1
  END) AS laptop_views

FROM viewership;
