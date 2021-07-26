-- queries used for the logistic regression model
USE sakila;
SELECT * FROM film;

-- testing query: do the numbers for count_rented_total sum up to the total of rentals?
SELECT SUM(count_rented_total)
FROM (
SELECT i.film_id, COUNT(rental_id) AS count_rented_total
FROM rental r
JOIN inventory i
USING (inventory_id)
GROUP BY i.film_id) t;

-- testing query: total of rentals
SELECT COUNT(rental_id)
FROM rental;

-- query for the data which will be used for the logictic regression model
-- creating a view as query doesn't run via Python
CREATE OR REPLACE VIEW data_logistic_regression AS
WITH cte AS
			(SELECT i.film_id, COUNT(rental_id) AS count_rented_total
            FROM rental r
            JOIN inventory i
            USING (inventory_id)
            GROUP BY i.film_id)
SELECT f.film_id, c.name, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, count_rented_total
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON c.category_id = fc.category_id
LEFT JOIN cte
ON cte.film_id = f.film_id;

SELECT * FROM data_logistic_regression;

SELECT * FROM rental;

-- query for the data which will be used as target for the logictic regression model
-- creating a view as query doesn't run via Python
CREATE VIEW target_logistic_regression AS
WITH cte1 AS
			(SELECT DATE_FORMAT(CONVERT(r.rental_date, DATE), '%Y-%m') AS new_rental_date,
					i.film_id
			FROM rental r
			JOIN inventory i
			USING (inventory_id)
			GROUP BY 1,2),
cte2 AS
		(SELECT new_rental_date,
				film_id,
				RANK() OVER(PARTITION BY film_id ORDER BY new_rental_date DESC) AS ranking
		FROM cte1),
cte3 AS
		(SELECT *
        FROM cte2
        WHERE ranking = 1
        AND new_rental_date = (SELECT MAX(new_rental_date) AS last_month FROM cte1))
SELECT f.film_id, c.new_rental_date
FROM film f
LEFT JOIN cte3 c
USING (film_id);
