/*
=========================================================
PROJECT: Logistics Network Performance Analytics
DATABASE: PostgreSQL
PHASE: Business KPIs

OBJECTIVE:
Understand the overall logistics operations through
high-level KPIs before diving into business analysis.

Author : Meet Shah
=========================================================
*/


/* -----------------------------------------------------------------
Which customers generate the highest shipment revenue, and what 
percentage of the company's total revenue does each contribute?

Objective:
Identify high-value customers for strategic planning.
*/ -----------------------------------------------------------------
SELECT 
	c.customer_name,
	COUNT(l.load_id) AS total_shipments,
	ROUND(SUM(l.revenue),2) AS total_revenue,
	ROUND(SUM(l.revenue) * 100.0/(SELECT SUM(revenue) FROM loads),2) AS revenue_percentage
	FROM customers c
	JOIN loads l
	ON c.customer_id = l.customer_id
	GROUP BY c.customer_name
	ORDER BY total_revenue DESC
	LIMIT 10;
	
/* -----------------------------------------------------------------
Which transportation routes generate the highest revenue per mile, 
and which routes are the most profitable for the business?

Objective:
Calculating Revenue per Mile helps identify the most efficient lanes, 
which can guide pricing decisions, route optimization, and resource allocation.
*/ -----------------------------------------------------------------
SELECT
    r.origin_city,
    r.destination_city,
    COUNT(l.load_id) AS total_shipments,
    ROUND(SUM(l.revenue), 2) AS total_revenue,
    ROUND(AVG(r.typical_distance_miles), 2) AS average_distance,
    ROUND(
        SUM(l.revenue) / SUM(r.typical_distance_miles),
        2
    ) AS revenue_per_mile

FROM routes r
JOIN loads l
ON r.route_id = l.route_id
GROUP BY
    r.origin_city,
    r.destination_city
ORDER BY revenue_per_mile DESC
LIMIT 10;

/* -----------------------------------------------------------------
Which drivers demonstrate the strongest overall operational
performance based on completed trips, revenue generated,
fuel efficiency, and on-time delivery rate?

Objective:
Identify high-performing drivers to support recognition,
training, and operational planning.
*/ -----------------------------------------------------------------
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    COUNT(t.trip_id) AS total_trips,
    ROUND(SUM(l.revenue),2) AS total_revenue,
    ROUND(AVG(t.average_mpg),2) AS average_mpg,
    ROUND(AVG(dm.on_time_delivery_rate),2) AS on_time_percentage
FROM drivers d
JOIN trips t
ON d.driver_id = t.driver_id
JOIN loads l
ON t.load_id = l.load_id
JOIN driver_monthly_metrics dm
ON d.driver_id = dm.driver_id
GROUP BY
    d.driver_id,
    driver_name
ORDER BY
    total_revenue DESC,
    on_time_percentage DESC
LIMIT 10;
