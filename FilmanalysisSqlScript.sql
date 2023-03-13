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
-- select min(avg_rating) as minimum_rating,
-- max(avg_rating) as maximum_rating,
-- min(total_votes) as minimum_total_votes,
-- max(total_votes) as maximum_total_votes,
-- min(median_rating) as minimum_median_rating,
-- max(median_rating) as maximum_media_rating
-- from filmanalysis.ratings;

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
 
