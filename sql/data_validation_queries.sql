create database AB_Testing; -- Created database

use ab_testing; -- Accessing ab_testing database

-- Number of rows or entries
select count(*) from `ab_data`;
-- 294478

-- Column number and data types validation
describe ab_data;

-- Unique users (user_id column validation)
select count(distinct user_id) from ab_data;
-- 294478 (that means no duplicate user_id and duplicate rows)

-- Missing values validation
select * from ab_data
where (user_id is null or user_id = '')
	or (`timestamp` is null) 		-- timestamp can't becompared to empty string
	or (group_name is null or group_name = '')
    or (landing_page is null or landing_page = '')
    or (converted is null)			-- Similarly numerical is also can't ne comapred with empty string
    or (age is null)
    or (gender is null or gender = '')
    or (location is null or location = '')
    or (session_duration is null)
    or (pages_visited is null)
    or (device_type is null or device_type = '')
    or (purchase_amount is null);
-- 0 rows returned

-- Check for two groups balance (group_name)
select group_name from ab_data group by group_name;

select count(*) from ab_data where group_name = 'control';
-- 146926
select count(*) from ab_data where group_name = 'treatment';
-- 147552
-- Class balance is almost 50-50

-- verifying exposure of group to the right landing page (group_name + landing page validation)
select distinct landing_page from ab_data;

select count(landing_page) from ab_data
where group_name = 'control' and landing_page = 'old_page';
-- 146926
select count(landing_page) from ab_data
where group_name = 'treatment' and landing_page = 'new_page';
-- 147552

SELECT
    group_name,
    landing_page,
    COUNT(*) AS users
FROM ab_data
GROUP BY group_name, landing_page
ORDER BY group_name, landing_page;
-- Adding that gives the total number of rows (146926 + 147552 = 294478)
-- Also these numbers match with the number of each group i.e, there is no mismatch in data

-- Conversion(converted column) validation
select distinct converted from ab_data;

select count(converted) as `Not Converted` from ab_data
where converted = 0;
-- 250550

select count(converted) as `Converted User` from ab_data
where converted = 1;
-- 43928

select round(count(converted) / (select count(*) from ab_data)*100,2) as `Percentage of not converted` from ab_data
where converted = 0;
-- 85.08% did not get converted

-- Gender validation
select distinct gender from ab_data;

select count(gender) as Male_Count from ab_data
where gender = 'Male';
-- 144708

select count(gender) as Female_Count from ab_data
where gender = 'Female';
-- 143785

select count(gender) as Other_Count from ab_data
where gender = 'Other';
-- 5985

-- Location validation
select location , count(user_id) from ab_data 
group by location
order by count(user_id) desc;
-- US, India, UK, Pakistan, Germany, Canada, Australia
-- 88342, 59014, 44217, 29600, 29477, 29241, 14587

-- Device validation 
select device_type , count(user_id) from ab_data 
group by device_type
order by count(user_id) desc;
-- Desktop, Mobile, Tablet
-- 176692, 103093, 14693

-- Numerica column validation
SELECT 
    -- Age Statistics
    COUNT(age) AS age_count,
    AVG(age) AS age_mean,
    MIN(age) AS age_min,
    MAX(age) AS age_max,
    STDDEV(age) AS age_std,

    -- Session Duration Statistics
    COUNT(session_duration) AS session_count,
    AVG(session_duration) AS session_mean,
    MIN(session_duration) AS session_min,
    MAX(session_duration) AS session_max,
    STDDEV(session_duration) AS session_std,

    -- Pages Visited Statistics
    COUNT(pages_visited) AS pages_count,
    AVG(pages_visited) AS pages_mean,
    MIN(pages_visited) AS pages_min,
    MAX(pages_visited) AS pages_max,
    STDDEV(pages_visited) AS pages_std,
    
    -- Purchase Amount Statistics
    COUNT(purchase_amount) AS purchase_count,
    AVG(purchase_amount) AS purchase_mean,
    MIN(purchase_amount) AS purchase_min,
    MAX(purchase_amount) AS purchase_max,
    STDDEV(purchase_amount) AS purchase_std
FROM ab_data;

-- Investigating purchase amount and converted relation
select count(purchase_amount) from ab_data
where purchase_amount > 0;
-- 43928 which is similar to converted users number

select sum(purchase_amount) from ab_data
where purchase_amount = 0;
-- That means if converted = 0 then purchase_amount = 0

-- Timestamp validation
select min(`timestamp`), max(`timestamp`) from ab_data;

select datediff(max(`timestamp`), min(`timestamp`)) as days_of_data from ab_data;
-- 731
-- Does that mean experiment ran for whole two year
-- We should think about it because the other angle could be that the different time in different region
-- For example, for first quarter of 2023 in US, then 2nd in India, then 3rd in Austrilia something like that