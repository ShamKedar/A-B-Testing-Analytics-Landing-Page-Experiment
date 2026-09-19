use ab_testing;

-- Q.1 What is the conversion rate for the control and treatment groups?
SELECT 
    group_name,
    COUNT(*) AS Total_Users,
    SUM(converted) AS Total_Converted_Users,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY group_name;
-- We can observe increase in conversion rate in newer version

-- Q.2 Relative_Conversion_Lift and conversion difference between groups. 
SELECT 
    ROUND(AVG(CASE
                WHEN group_name = 'control' THEN converted
            END) * 100,
            2) AS Control_Conversion_Rate,
    ROUND(AVG(CASE
                WHEN group_name = 'treatment' THEN converted
            END) * 100,
            2) AS Treatment_Conversion_Rate,
    ROUND(ABS(AVG(CASE
                        WHEN group_name = 'control' THEN converted
                    END) - AVG(CASE
                        WHEN group_name = 'treatment' THEN converted
                    END)) * 100,
            2) AS Absolute_Difference,
    ROUND(ABS(AVG(CASE
                        WHEN group_name = 'control' THEN converted
                    END) - AVG(CASE
                        WHEN group_name = 'treatment' THEN converted
                    END)) / AVG(CASE
                WHEN group_name = 'control' THEN converted
            END) * 100,
            2) AS Relative_Conversion_Lift
FROM
    ab_data;

-- Q.3 Calculate revenue generated, avg revenue and revenue per user who purchased.
SELECT 
    group_name AS `Groups`,
    COUNT(user_id) AS Total_Users,
    SUM(purchase_amount) AS Total_Revenue,
    ROUND(AVG(purchase_amount) * 100, 2) AS Average_Revenue_Include_Not_Purchased,
    COUNT(CASE
        WHEN purchase_amount > 0 THEN 1
    END) AS Purchasers,
    ROUND(AVG(CASE
                WHEN purchase_amount > 0 THEN purchase_amount
            END) * 100,
            2) Average_Revenue_Excluding_Not_Purchased
FROM
    ab_data
GROUP BY group_name;

-- Q.4 Engagement analysis by using Session duration and Pages visited.

SELECT 
    group_name,
    SUM(session_duration) AS Total_Session_Duration,
    ROUND(AVG(session_duration), 2) AS AVG_Session_Duration,
    SUM(pages_visited) AS Total_Pages_Visited,
    ROUND(AVG(pages_visited), 2) AS AVG_Pages_Visited
FROM
    ab_data
GROUP BY group_name;
-- Slightly increase in the treatment(new version)

-- Q.5 Segmentation by device, location, gender and age groups.

SELECT 
    device_type,
    group_name,
    COUNT(user_id) AS Total_Users,
    SUM(converted) AS Converted,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY device_type , group_name
ORDER BY device_type , group_name;
-- For treatment group conversion rate in all device is nearly same approx 18%
-- But highest is 18.08% with desktop and treatment.

SELECT 
    location,
    group_name,
    COUNT(user_id) AS Total_Users,
    SUM(converted) AS Converted,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY location , group_name
ORDER BY location , group_name;
-- We can see the growth by nearly 6%-7% in each country

SELECT 
    gender,
    group_name,
    COUNT(user_id) AS Total_Sales,
    SUM(converted) AS Converted,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY gender , group_name
ORDER BY gender , group_name;
-- Major conversion has been observed in Male category

SELECT 
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55-65'
    END AS Age_Group,
    group_name,
    COUNT(user_id) AS Total_Users,
    SUM(converted) AS Converted,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY Age_Group , group_name
ORDER BY Age_Group , group_name;
-- Approx growth of 5-7% in each age group 

-- Q.6 Perform time analysis

-- Month-wise users analysis
SELECT 
    DATE_FORMAT(timestamp, '%Y-%m') AS `Month`,
    group_name,
    COUNT(user_id) AS Total_Users
FROM
    ab_data
GROUP BY `month` , group_name
ORDER BY `month` , group_name;

-- Conversion analysis month-wise
SELECT 
    DATE_FORMAT(timestamp, '%Y-%m') AS `Month`,
    group_name,
    COUNT(user_id) AS Total_Users,
    SUM(converted) AS Converted,
    ROUND(AVG(converted) * 100, 2) AS Conversion_Rate
FROM
    ab_data
GROUP BY `month` , group_name
ORDER BY `month` , group_name;