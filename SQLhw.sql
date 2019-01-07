USE sakila;

SELECT first_name, last_name
 FROM actor;
 
 SET SQL_SAFE_UPDATES = 0;

ALTER TABLE actor 
	ADD COLUMN `Actor Name` varchar(255);
    
SELECT * FROM actor;  

UPDATE actor SET `Actor Name`=CONCAT(first_name, ' ', last_name) WHERE actor_id=actor_id;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, 
       first_name, 
       last_name 
FROM   actor 
WHERE  first_name = 'Joe'; 

-- 2b Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, 
       first_name, 
       last_name 
FROM   actor 
WHERE  last_name like '%GEN%'; 

-- 2c Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, 
       first_name, 
       last_name 
FROM   actor 
WHERE  last_name like '%LI%'
ORDER BY last_name, first_name;

-- 2d Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id , country FROM country
WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named 
-- `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
SELECT * FROM actor; 

ALTER TABLE actor 
	ADD COLUMN `description` BLOB NOT NULL;
    
ALTER TABLE actor
	DROP `description`;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT * FROM actor; 

SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) FROM actor
	GROUP BY last_name
    HAVING COUNT(last_name)>1;
    
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'; 

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'; 

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address, address.address2
FROM staff LEFT JOIN address ON
address.address_id = staff.address_id; 

SELECT * FROM staff;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 

SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff LEFT JOIN payment ON
staff.staff_id = payment.staff_id
where YEAR(payment_date) = '2005' and MONTH(payment_date) = '8'
group by first_name, last_name;

--  6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT film.title, count(film_actor.actor_id)
FROM film inner join film_actor on
	film.film_id = film_actor.film_id
GROUP BY FILM.TITLE

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT title, 
(SELECT COUNT(*)  FROM inventory WHERE inventory.film_id=film.film_id) as 'Number of Copies'
FROM film
WHERE title = 'Hunchback Impossible';

--  6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer LEFT JOIN payment ON
customer.customer_id = payment.customer_id
group by first_name, last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title 
FROM  film 
WHERE  (title like 'Q%' OR title like 'K%') AND language_id = (SELECT language_id FROM language WHERE name = 'English')
ORDER BY film.title;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
 FROM actor
 WHERE actor_id IN
 (
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'Alone Trip'
   )
   );
   
   -- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer cus
WHERE address_id IN
(
  SELECT address_id
  FROM address a
  WHERE city_id IN
  (
    SELECT city_id
    FROM city 
    WHERE country_id IN
    (
    SELECT country_id
    FROM country 
    WHERE country = 'Canada'
    )
  ) 
);

SELECT customer.first_name, customer.last_name, email
FROM customer LEFT JOIN address ON customer.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id
WHERE country = 'Canada'

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title
 FROM film
 WHERE film_id IN
 (
  SELECT film_id
  FROM film_category
  WHERE film_id IN
  (
   SELECT film_id
   FROM category
   WHERE name = 'Family'
   )
   );

select * FROM category

-- 7e. Display the most frequently rented movies in descending order.

SELECT 
    (SELECT title FROM film WHERE film.film_id=inventory.film_id) AS TITLE,
    COUNT(film_id) AS TotalCount
FROM inventory
   WHERE inventory_id IN
   (
    SELECT inventory_id
    FROM rental
    WHERE rental_id IN
    (
     SELECT rental_id
     FROM payment   
   )
  )
GROUP BY title
ORDER BY TotalCount DESC
 
 -- 7f. Write a query to display how much business, in dollars, each store brought in.
 

SELECT store.store_id, SUM(payment.amount) as TotalAmount
FROM payment
  LEFT JOIN customer ON payment.customer_id = customer.customer_id
  LEFT JOIN store ON customer.store_id = store.store_id
GROUP BY store.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store LEFT JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(payment.amount) as TotalAmount 
FROM payment
  LEFT JOIN rental ON payment.rental_id = rental.rental_id
  LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
  LEFT JOIN film_category ON inventory.film_id = film_category.film_id
  LEFT JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY TotalAmount Desc LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW vTopFiveGenres AS 
SELECT category.name, SUM(payment.amount) as TotalAmount 
FROM payment
  LEFT JOIN rental ON payment.rental_id = rental.rental_id
  LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
  LEFT JOIN film_category ON inventory.film_id = film_category.film_id
  LEFT JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY TotalAmount Desc LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM vTopFiveGenres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW vTopFiveGenres;

SELECT * FROM vTopFiveGenres;