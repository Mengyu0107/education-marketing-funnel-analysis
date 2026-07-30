/*
Purpose: Final queries to export from MySQL Workbench as CSV files.
Suggested filenames:
- results/channel_funnel_metrics.csv
- results/customer_funnel.csv
*/

USE education_marketing_funnel;

SELECT *
FROM channel_funnel_metrics
ORDER BY reservations DESC;


SELECT *
FROM customer_funnel
ORDER BY channel_group, phone;
