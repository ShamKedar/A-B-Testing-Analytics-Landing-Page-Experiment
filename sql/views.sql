-- Let's create the view for repeatative calculations
CREATE VIEW view_ab_test_summary AS
    SELECT 
        group_name,
        COUNT(*) AS total_users,
        SUM(converted) AS conversions,
        AVG(converted) AS conversion_rate,
        SUM(purchase_amount) AS total_revenue,
        AVG(purchase_amount) AS revenue_per_user,
        AVG(session_duration) AS avg_session_duration,
        AVG(pages_visited) AS avg_pages_visited
    FROM
        ab_data
    GROUP BY group_name;

SELECT *
FROM view_ab_test_summary;