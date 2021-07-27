USE sakila;

CREATE OR REPLACE VIEW sakila.rental_prediction AS
WITH cte_rentals_0602 AS (
	SELECT film_id, i.inventory_id,
	CONVERT(DATE_FORMAT(CONVERT(rental_date, DATE), '%m'), UNSIGNED) AS rental_month,
	CONVERT(DATE_FORMAT(CONVERT(rental_date, DATE), '%Y'), UNSIGNED) AS rental_year
	FROM rental r
	JOIN inventory i
	ON r.inventory_id = i.inventory_id
	HAVING rental_month = 02 and rental_year = 2006
    ),
cte_rentals_0602_aggr AS (
	SELECT film_id, COUNT(inventory_id) as rental_count, ROUND(AVG(rental_month)) AS rental_month, ROUND(AVG(rental_year)) AS rental_year
	FROM cte_rentals_0602
	GROUP BY film_id
    ),
cte_film_rentals_0602 AS (
	SELECT f.film_id, rental_count, rental_month, rental_year, rental_duration, rental_rate, length, rating
	FROM cte_rentals_0602_aggr cr
	RIGHT JOIN film f
	ON cr.film_id = f.film_id
    ),
cte_film_category AS (
	SELECT film_id, c.name as category
    FROM film_category fc
    JOIN category c
    ON fc.category_id = c.category_id
    )
SELECT cfr.film_id, rental_count, rental_duration, rental_rate, length, rating, category,
CASE 
	WHEN rental_month = 02 THEN 1
    ELSE 0
    END AS 'rental_status'
FROM cte_film_rentals_0602 cfr
JOIN cte_film_category cfc
ON cfr.film_id = cfc.film_id
ORDER BY cfr.film_id;

SELECT *
FROM rental_prediction;
