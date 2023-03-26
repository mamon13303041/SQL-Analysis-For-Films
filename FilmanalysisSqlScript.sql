#part 1
#Q1. Find the total number of rows in each table of the schema?
select table_name as 'table', 
    table_rows as 'rows'
from information_schema.tables
where  TABLE_SCHEMA = 'filmanalysis'

#Q2. Which columns in the movie table have null values?
SELECT count(*)
FROM `filmanalysis`.`movie`
where title is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where year is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where relase_date is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where country is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where worldwide_gross_earn is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where language is null
Union all
SELECT count(*) 
FROM `filmanalysis`.`movie`
where production_company is null;

#Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

select month(relase_date),count(ID) as number_movies
FROM `filmanalysis`.`movie`
GROUP BY  month(relase_date) order by number_movies DESC;

#Q4. How many movies were produced in the Germany or USA in the year 2017??
select count(ID) as movie_count 
from filmanalysis.movie
#used regular expression to find strings containing USA or India
WHERE  country REGEXP 'USA|Germany'
AND year = 2017;
#Q5. Find the unique list of the genres present in the data set?

select DISTINCT genre
from filmanalysis.genre;

#Q6.Which genre had the highest number of movies produced overall?
select genre,
count(movie.ID) as number_of_movies
from filmanalysis.genre
inner join filmanalysis.movie
on genre.movie_id=movie.ID
group by genre
order by  number_of_movies desc
limit 1;
#Q7. How many movies belong to only one genre?
with one_ as (select movie_id,
count(distinct genre) as one_genre
from filmanalysis.genre
group by movie_id
having one_genre=1)

select count(*) as one_genre
from one_;

#Q8.What is the average duration of movies in each genre? 
SELECT genre, round((movie.duration),2) as movie_avglength
FROM filmanalysis.movie, filmanalysis.genre
WHERE movie.ID = genre.movie_id
GROUP BY genre
order by movie_avglength desc;

#Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

WITH genre_rank
     AS (SELECT  genre,
                 Count(DISTINCT movie_id) AS movie_count,
                 Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank_info
		FROM 	 filmanalysis.genre
		GROUP BY genre
         )
SELECT *
FROM   genre_rank
WHERE  genre = 'Thriller';

#Part 2
#Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
select min(avg_rating) as minimum_rating,
max(avg_rating) as maximum_rating,
min(total_votes) as minimum_total_votes,
max(total_votes) as maximum_total_votes,
min(median_rating) as minimum_median_rating,
max(median_rating) as maximum_media_rating
from filmanalysis.ratings;

#Q11. Which are the top 10 movies based on average rating?
select title,
avg_rating, 
Rank() OVER(ORDER BY avg_rating DESC) AS movie_rank_info 
from filmanalysis.ratings
Inner join filmanalysis.movie on movie.ID=ratings.movie_id
limit 10;
#Q12. Summarise the ratings table based on the movie counts by median ratings.

SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   filmanalysis.ratings
GROUP  BY median_rating
ORDER  BY median_rating;

# Q13 Which production house has produced the most number of hit movies (average rating > 8)??
With ranking as(select production_company,
Count(movie_id) AS movie_count,
Rank() OVER(ORDER BY Count(movie_id) DESC) 	AS production_company_rank
from filmanalysis.ratings
inner join filmanalysis.movie 
on movie.ID=ratings.movie_id
where avg_rating>8
group by production_company)

select *
from ranking
where production_company_rank=1
limit 1; 

# Q14. How many movies released in each genre during june 2017 in the Germany had more than 1000 votes?
select genre,
count(movie.ID) as movie_counts
from filmanalysis.genre
inner join filmanalysis.movie
on movie.ID=genre.movie_id
inner join filmanalysis.ratings
on movie.ID=ratings.movie_id
where month(relase_date)=6
and year(relase_date)=2017
and country='Germany'
and total_votes>1000
group by genre
ORDER  BY movie_counts DESC;
# Q.15 Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
SELECT title, avg_rating, genre
FROM   filmanalysis.genre
INNER JOIN filmanalysis.movie
ON genre.movie_id = movie.ID
INNER JOIN filmanalysis.ratings 
ON movie.ID = genre.movie_id
WHERE  title LIKE 'The%'
AND avg_rating > 8
ORDER  BY avg_rating DESC; 

# Q16. Of the movies released between 2 February 2018 and 15 decamber 2017, how many were given a median rating of 8?
select count(ratings.movie_id) as movie_count
from filmanalysis.ratings
inner join filmanalysis.movie
on ratings.movie_id=movie.ID
where relase_date between '2017-02-22' and '2017-12-15'


#Q17. Do German movies get more votes than USA movies? 
select country,
sum(total_votes)
from filmanalysis.ratings
inner join filmanalysis.movie
on movie.ID=ratings.movie_id
where country in( 'Germany' , 'USA')
group by country;


#Q18. Comparing total votes with respect to language the movies are available in, between German and english WITH german_movies

with langauge_german as (select language,
sum(total_votes) as total_votes
from filmanalysis.ratings
inner join filmanalysis.movie
on movie.ID=ratings.movie_id
where language like '%german'
group by language)

select 'german' as language,
sum(total_votes)
from langauge_german

Union

(with langauge_english as (select language,
sum(total_votes) as total_votes
from filmanalysis.ratings
inner join filmanalysis.movie
on movie.ID=ratings.movie_id
where language like '%english'
group by language)

select 'english' as language,
sum(total_votes)
from langauge_english);

#Q19. Which columns in the names table have null values??
select 
	sum(case when name is null then 1 else 0 end) as names, 
    sum(case when height is null then 1 else 0 end) as Height, 
    sum(case when date_of_birth is null then 1 else 0 end) as birth, 
    sum(case when known_for_movies is null then 1 else 0 end) as Known_movies
    
from filmanalysis.names;
# Q20. Who are the top three directors in the top three genres whose movies have an average rating > 8?
with top_three_genre as(
select genre
from filmanalysis.genre
inner join filmanalysis.ratings
using(movie_id)
where avg_rating>8
group by genre
order by count(movie_id) desc
limit 3
),

top_three_director as(
select name as director_name,
count(genre.movie_id) as movie_count,
Rank() OVER(ORDER BY Count(genre.movie_id) DESC) AS director_rank
from filmanalysis.genre
inner join filmanalysis.director_maping
on genre.movie_id=director_maping.name_id
inner join filmanalysis.names
on names.id=director_maping.name_id
inner join filmanalysis.ratings
on ratings.movie_id=genre.movie_id,top_three_genre
WHERE avg_rating > 8
AND genre.genre IN (top_three_genre.genre)
GROUP BY names.name
)

#Q21. Who are the top two actors whose movies have a median rating >= 8?
select name as actor_name,
count(ratings.movie_id) as movie_count
from filmanalysis.names
inner join filmanalysis.role
on names.id=role.name_id
inner join filmanalysis.ratings 
on role.movie_id=ratings.movie_id
where median_rating>=8.0
order by movie_count
limit 2;
select director_name,movie_count
from top_three_director
;

# Q22. Which are the top three production houses based on the number of votes received by their movies?
select production_company,
sum(ratings.total_votes) as vote_count,
Rank() OVER(ORDER BY Sum(ratings.total_votes) DESC) AS prod_comp_rank
from filmanalysis.movie
inner join filmanalysis.ratings
on movie.ID= ratings.movie_id

group by production_company
order by vote_count DESC 
limit 3;

#Q23. Rank actors with movies released in USA based on their average ratings. Which actor is at the top of the list?
select name as actor_name,
sum(ratings.total_votes) as vote_count,
count(ratings.movie_id) as movie_count,
Round(Sum(ratings.total_votes * ratings.avg_rating) / Sum(ratings.total_votes), 2) AS actor_avg_rating,
Rank() OVER(ORDER BY Round(Sum(ratings.total_votes * ratings.avg_rating)/Sum(ratings.total_votes), 2) DESC, 
Sum(ratings.total_votes) DESC) AS actor_rank
from filmanalysis.names
inner join filmanalysis.role
on names.id=role.name_id
inner join filmanalysis.ratings
on role.movie_id=ratings.movie_id
inner join filmanalysis.movie
on role.movie_id=movie.ID
where country='USA';


# Q24.Find out the top five actresses in USA movies released in USA based on their average ratings? 
select name as actor_name,
sum(ratings.total_votes) as vote_count,
count(ratings.movie_id) as movie_count,
Round(Sum(ratings.total_votes * ratings.avg_rating) / Sum(ratings.total_votes), 2) AS actor_avg_rating,
Rank() OVER(ORDER BY Round(Sum(ratings.total_votes * ratings.avg_rating)/Sum(ratings.total_votes), 2) DESC, 
Sum(ratings.total_votes) DESC) AS actor_rank
from filmanalysis.names
inner join filmanalysis.role
on names.id=role.name_id
inner join filmanalysis.ratings
on role.movie_id=ratings.movie_id
inner join filmanalysis.movie
on role.movie_id=movie.ID
where country='USA'
and category='actress'
and language='english'
order by actor_rank desc;

#Q25. Which are the five highest-grossing movies of each year that belong to the top three genres? 
WITH top_genres AS
(SELECT genre 
FROM   filmanalysis.genre 
INNER JOIN filmanalysis.ratings 
ON genre.movie_id = ratings.movie_id
WHERE  avg_rating > 8
GROUP  BY genre
ORDER  BY Count(ratings.movie_id) DESC
LIMIT  3
),
movie_gross_earn AS
(SELECT genre.genre, year, title AS movie_name,
CASE
WHEN worldwide_gross_earn LIKE '€%' 
THEN Cast(Replace(worldwide_gross_earn, '€', '') AS DECIMAL(10)) / 1.07
WHEN worldwide_gross_earn LIKE 'INR%' 
THEN Cast(Replace(worldwide_gross_earn, 'INR', '') AS DECIMAL(10)) /82.0
WHEN worldwide_gross_earn LIKE 'BD%' 
THEN Cast(Replace(worldwide_gross_earn, 'BD', '') AS DECIMAL(10)) /105.20
WHEN worldwide_gross_earn LIKE '$%' 
THEN Cast(Replace(worldwide_gross_earn, '$', '') AS DECIMAL(10))
ELSE Cast(worldwide_gross_earn AS DECIMAL(10))
END worldwide_gross_earn
FROM  filmanalysis.genre 
INNER JOIN filmanalysis.movie 
ON genre.movie_id = movie.ID,top_genres
WHERE  genre.genre IN (top_genres.genre)
GROUP  BY movie_name,year
),
highest_ranked_movies AS
(SELECT *,
rank() OVER(partition BY year ORDER BY worldwide_gross_earn DESC) AS movie_rank
FROM movie_gross_earn
)
SELECT *
FROM highest_ranked_movies
WHERE  movie_rank <= 5;


#  Q26. Select thriller movies as per avg rating and classify them in the following category: 

-- 			Rating > 8: Superhit movies
-- 			Rating between 7 and 8: Hit movies
-- 			Rating between 5 and 7: One-time-watch movies
-- 			Rating < 5: Flop movies

select title as movie_title,
avg_rating,
case
when avg_rating > 8 then 'Superhit Movie'
when avg_rating between 7 and  8 then 'Hit Movie'
when avg_rating between 5 and  8 then ' One-time-watch movies'
else 'flop movie'
end
from filmanalysis.ratings
inner join filmanalysis.movie
on movie.ID=ratings.movie_id
inner join filmanalysis.genre
on movie.ID=genre.movie_id
where genre='Thriller';




# Q27. What is the genre-wise running total and moving average of the average movie duration? 
select genre,
round(avg(duration)) as average_duration,
round(sum(avg(duration)) over (order by genre rows UNBOUNDED PRECEDING),2) as running_total,
round(sum(avg(duration)) over (order by genre rows between 3 preceding and 2 following),2) as moving_average
from filmanalysis.genre
inner join filmanalysis.movie
on movie.ID=genre.movie_id
group by genre;


#Q28.  Which are the top two production houses that have produced the highest number of hits (median rating >= 7) among multilingual movies?
SELECT production_company,
Count(ratings.movie_id) AS movie_count,
Rank() over(ORDER BY Count(ratings.movie_id) DESC) 	AS production_company_rank
FROM   filmanalysis.ratings 
INNER JOIN movie 
ON ratings.movie_id = movie.ID
WHERE  production_company IS NOT NULL
AND median_rating >= 7
AND Position(',' IN language) > 0
GROUP  BY production_company
limit 2;

