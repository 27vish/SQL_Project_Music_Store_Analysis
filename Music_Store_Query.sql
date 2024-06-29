/* Who is the senior most employee based on job title? */

SELECT first_name ||' '|| last_name AS employee_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Which countries have the most invoices? */

SELECT billing_country, COUNT(total) AS c
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

/* What are top 3 values of total invoice? */

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Which city has the best cutomer? We would like to throw a promotion Music Festival in the city 
   we made the most money.  Write a query that returns one city that has the highest sum of invoice totals.
   Return both the city name & sum of all invoice totals. */
   
SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY  billing_city
ORDER BY invoice_total DESC;

/* Who is the best customer? The customer who has spent the most money will be declared the 
   best customer. Write the query that returns the person who has spent the most money. */

SELECT customer.customer_id, first_name, last_name, 
SUM(invoice.total) AS total_spent
FROM customer
INNER JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY total_spent DESC
LIMIT 1;

/* Write a query to return the email, first_name, last_name, & Genre
of all Rock Music listner. Return your list ordered alphabetically 
by email starting with A */

SELECT DISTINCT(email), first_name, last_name 
FROM customer
INNER JOIN invoice
ON customer.customer_id = invoice.customer_id
INNER JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id 
WHERE track_id IN (
	SELECT track_id FROM genre
	INNER JOIN track ON
    genre.genre_id = track.genre_id
    WHERE genre.name = 'Rock'
	)                           
ORDER BY email;

/* Let's invite the artist who have written the most rock music in our dataset.
   Write a quary that returns the Artist name and 
   total track count of top 10 rock bands. */

SELECT artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
INNER JOIN album
ON track.album_id = album.album_id
INNER JOIN artist
ON artist.artist_id = album.artist_id
INNER JOIN genre
ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

/* Return all the track names that have a song length longer than 
the average song length. Return the Name and Milliseconds for each track.
Order by the song length with the longest songs listed first. */

SELECT name, milliseconds 
FROM track
WHERE milliseconds > (
      SELECT AVG(milliseconds) AS avg_track_length 
	   from track)
ORDER BY milliseconds DESC;

/* Find how much amount spent by each customer on artists?
   Write a query to return customer name, artist name and total spent. */
   
WITH best_selling_artist AS(
     SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	 SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sale
	 FROM invoice_line
	 INNER JOIN track ON track.track_id = invoice_line.track_id
	 INNER JOIN album ON album.album_id = track.album_id
	 INNER JOIN artist ON artist.artist_id = album.artist_id
	 GROUP BY artist.artist_id, artist.name
	 ORDER BY total_sale DESC
	 LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, bsa.artist_id,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice AS i
INNER JOIN customer AS c ON c.customer_id = i.customer_id 
INNER JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
INNER JOIN track AS t ON t.track_id = il.track_id
INNER JOIN album AS alb ON alb.album_id = t.album_id
INNER JOIN best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name, bsa.artist_id
ORDER BY amount_spent DESC


/* We want to find out the most popular music Genre for each country.
   We determine the most popular genre as genre with the highest amount of purchases.
   Write a query that returns each country along with the top Genre. 
   For countries where the maximum number of purchases is shared return all Geners. */
   
WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNO
    FROM invoice_line
	INNER JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	INNER JOIN customer ON customer.customer_id = invoice.customer_id
	INNER JOIN track ON track.track_id = invoice_line.track_id
	INNER JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY purchases ASC, purchases DESC
)
SELECT * FROM popular_genre 
WHERE RowNo = 1;


/* Write a query that determines the customer that has spent the most on music for each country.
   Write a quey that returns the country along with the top customer and how much they spent.
   For countries where the top amount spent is shared, provide all customers who spent this time */
 
WITH customer_with_country AS
(
     SELECT customer.customer_id, first_name, last_name, billing_country, 
	 SUM(total) AS total_spending,
	 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
     FROM invoice
	 INNER JOIN customer ON customer.customer_id = invoice.customer_id
     GROUP BY customer.customer_id, first_name, last_name, billing_country
	 ORDER BY billing_country ASC, SUM(total) DESC
)
SELECT * FROM customer_with_country 
WHERE Rowno = 1;