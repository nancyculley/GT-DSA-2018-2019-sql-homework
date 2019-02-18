# Use the sakila database
USE sakila;

# 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select ucase(concat(first_name,' ',last_name)) AS 'Actor Name' from actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor where first_name = "JOE";

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor where last_name like "%GEN%";

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor where last_name like "%LI%" order by last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description blob;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,  count(last_name) as 'last name count' FROM actor group by last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,  count(last_name) as 'last name count' FROM actor group by last_name having count(last_name) >1;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO' where first_name = 'HARPO';

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE ADDRESS;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, sum(amount) as 'August 2005 total'
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
where payment_date between '2005-08-01 00:00:00' and '2005-08-31 23:59:59'
group by staff.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, count(film_actor.film_id) as 'Number of actors'
FROM film
inner JOIN film_actor ON film.film_id = film_actor.film_id
group by title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(inventory.film_id) as 'Number of Hunchback Impossible'
FROM film
inner JOIN inventory ON film.film_id = inventory.film_id
where title = 'Hunchback Impossible';

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, sum(amount) as 'Total Amount Paid'
FROM customer
inner JOIN payment ON customer.customer_id = payment.customer_id
group by customer.customer_id
order by last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title as 'English films beginning with K & Q'
FROM film
where (title like "K%" or title like "Q%") and
language_id IN
(  SELECT language_id
   FROM language
   WHERE name = 'English'
  );

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select ucase(concat(first_name,' ',last_name)) AS 'Actors in Alone Trip'
FROM actor
where actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email 
FROM customer
    INNER JOIN address ON customer.address_id = address.address_id
    INNER JOIN city ON address.city_id  = city.city_id 
    INNER JOIN country ON city.country_id  = country.country_id
where country = 'Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT film.title as 'Family Movies'
FROM film
    INNER JOIN film_category ON film.film_id = film_category.film_id
    INNER JOIN category ON film_category.category_id = category.category_id 
where category.name = 'Family';

# 7e. Display the most frequently rented movies in descending order.
SELECT film.title, count(rental.rental_id) as 'Rental frequency'
FROM film
    INNER JOIN inventory ON film.film_id = inventory.film_id
    INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
group by title
order by count(rental.rental_id) desc;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(payment.amount) as 'Store business'
FROM store
    INNER JOIN staff ON store.store_id = staff.store_id
    INNER JOIN payment ON staff.staff_id = payment.staff_id
group by store.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
    INNER JOIN address ON store.address_id = address.address_id
    INNER JOIN city ON address.city_id = city.city_id
    INNER JOIN country ON city.country_id = country.country_id
group by store.store_id;

# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name, sum(payment.amount) as 'Total gross revenue'
FROM category
    INNER JOIN film_category ON category.category_id = film_category.category_id
    INNER JOIN inventory on film_category.film_id = inventory.film_id
    INNER JOIN rental on inventory.inventory_id = rental.inventory_id
	INNER JOIN payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_grossing as SELECT category.name, sum(payment.amount) as 'Total gross revenue'
FROM category
    INNER JOIN film_category ON category.category_id = film_category.category_id
    INNER JOIN inventory on film_category.film_id = inventory.film_id
    INNER JOIN rental on inventory.inventory_id = rental.inventory_id
	INNER JOIN payment on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

# 8b. How would you display the view that you created in 8a?
select * from top_grossing;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_grossing;
