# Q13 Which production house has produced the most number of hit movies (average rating > 8)??
-- With ranking as(select production_company,
-- Count(movie_id) AS movie_count,
-- Rank() OVER(ORDER BY Count(movie_id) DESC) 	AS production_company_rank
-- from filmanalysis.ratings
-- inner join filmanalysis.movie 
-- on movie.ID=ratings.movie_id
-- where avg_rating>8
-- group by production_company)

-- select *
-- from ranking
-- where production_company_rank=1
-- limit 1; 

# Q14. How many movies released in each genre during june 2017 in the Germany had more than 1000 votes?
-- select genre,
-- count(movie.ID) as movie_counts
-- from filmanalysis.genre
-- inner join filmanalysis.movie
-- on movie.ID=genre.movie_id
-- inner join filmanalysis.ratings
-- on movie.ID=ratings.movie_id
-- where month(relase_date)=6
-- and year(relase_date)=2017
-- and country='Germany'
-- and total_votes>1000
-- group by genre
-- ORDER  BY movie_counts DESC;
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