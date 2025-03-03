use imdb;
#1. Count the total number of records in each table of the database.
select (select count(movie_id) from genre) as genre_count,
(select count(name_id) from director_mapping) as director_mapping_count,
(select count(id) from movie) as movie_count,
(select count(id) from names)as name_count,
(select count(movie_id)from ratings) as ratings_count,
count(name_id) as role_mapping_count
from role_mapping;

#2. Identify which columns in the movie table contain null values.
select 'id' as null_column_name,count(*) as null_count  from movie where id is null
union all
select 'title' ,count(*) from movie where title is null
union all
select 'year' ,count(*) from movie where year is null
union all
select 'date_published' ,count(*) from movie where date_published is null
union all
select 'duration' ,count(*) from movie where duration is null
union all
select 'country' ,count(*) from movie where country is null
union all 
select 'worlwide_gross_income' ,count(*) from movie where worlwide_gross_income is null
union all
select 'languages' ,count(*) from movie where languages is null
union all
select 'production_company' ,count(*) from movie where production_company is null;

#3. Determine the total number of movies released each year, and analyze how the trend changes month-wise.
select year,count(id)
from movie
group by year;
select month(date_published) as month_of, count(title)
from movie
group by month_of
order by month_of;

#4. How many movies were produced in either the USA or India in the year 2019?
select year, count(title) as total_movies
from movie
where  country in ('usa','india')and year=2019;

#5. List the unique genres in the dataset, and count how many movies belong exclusively to onegenre.
select distinct genre,count(movie_id) as total_movies
from(select genre.genre ,mov.movie_id as movie_id
from(
select movie_id,count(movie_id) as new
from genre
group by movie_id) as mov
join genre
on genre.movie_id=mov.movie_id
where new=1) as tew
group by genre;

#6. Which genre has the highest total number of movies produced?
select g.genre,count(m.title) as no_of_movies
from genre g
join movie m
on g.movie_id=m.id
group by g.genre
order by no_of_movies desc
limit 1;

#7. Calculate the average movie duration for each genre.
select genre,avg(duration) as avg_duration
from (
select genre.genre, movie.duration
from movie
left join genre
on movie.id=genre.movie_id
) as mov
group by genre;

#8. Identify actors or actresses who have appeared in more than three movies with an average rating below 5.
select actor_name, count(movie_id) as count_of_movies
from (
select n.name as actor_name,rm.name_id as actor_id,r.movie_id as movie_id,r.avg_rating as average_rating,rm.category
from role_mapping rm 
join ratings r on rm.movie_id=r.movie_id
join names n on rm.name_id=n.id
where r.avg_rating < 5) as newtab
group by actor_name
having count_of_movies >3
order by count_of_movies desc;

#9. Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.
select min(avg_rating) as min_value_of_avg_rating,
min(total_votes) as min_value_of_total_votes,min(median_rating) as min_value_of_median_rating,
max(avg_rating) as max_value_of_avg_rating,max(total_votes) as max_value_of_total_votes,
max(median_rating) as max_value_of_median_rating from ratings;

#10. Which are the top 10 movies based on their average rating?
select movie.title, ratings. avg_rating
from movie
join ratings
on movie.id= ratings.movie_id order by avg_rating desc limit 10;

#11. Summarize the ratings table by grouping movies based on their median ratings.
select median_rating,count(movie_id) as total_movies, avg(avg_rating) as average
from ratings
group by median_rating
order by median_rating asc;

#12. How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?
select g.genre,count(movies.id)as movie_count
from(
select m.id,m.title
from movie m
join ratings r
on m.id=r.movie_id
where m.date_published between '2017-03-01' and '2017-03-31' and m.country='usa' and r.total_votes>'1000')as movies
join genre g
on g.movie_id=movies.id
group by g.genre
order by g.genre;

#13. Find movies from each genre that begin with the word “The” and have an average rating greater than 8.
select m.title,g.genre,r.avg_rating
from movie m
join genre g 
on g.movie_id=m.id
join ratings r
on r.movie_id=m.id
where r.avg_rating >8 and m.title like 'the%'
order by g.genre asc;

#14. Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?
select count(m.title) as Total_movies
from movie m
join ratings r
on m.id=r.movie_id
where m.date_published between '2018-04-01'and'2019-04-01' and r.median_rating=8;

#15. Do German movies receive more votes on average than Italian movies?
select 'german' as language, avg(german_vote.total_votes) as average
from(select movie.languages,ratings.total_votes
from movie
join ratings
on movie.id=ratings.movie_id
where languages like '%german%') as german_vote
union
select 'italian', avg(italian_vote.total_votes)
from(
select movie.languages,ratings.total_votes
from movie
join ratings
on movie.id=ratings.movie_id
where languages like '%italian%') as italian_vote;

#16. Identify the columns in the names table that contain null values.
select 'id' as null_column_name,count(*) as null_count  from names where id is null
union all
select 'name' ,count(*) from names where name is null
union all
select 'height' ,count(*) from names where height is null
union all
select 'date_of_birth' ,count(*) from names where date_of_birth is null
union all
select 'known_for movies' ,count(*) from names where known_for_movies is null;

#17. Who are the top two actors whose movies have a median rating of 8 or higher?
select rm.name_id,n.name,rm.category,count(r.median_rating) as rating_count
from role_mapping rm
join ratings r on r.movie_id=rm.movie_id
join names n on rm.name_id=n.id
where rm.category = 'actor' and r.median_rating >=8 
group by rm.name_id
order by rating_count desc
limit 2;


#18. Which are the top three production companies based on the total number of votes their movies received?
select m.production_company,sum(r.total_votes) as votes_total
from movie m
join ratings r
on m.id=r.movie_id
group by m.production_company
order by votes_total desc
limit 3;
#19. How many directors have worked on more than three movies?
select count(name_id) as director_count
from(select distinct name_id,count(movie_id) as new
from director_mapping
group by name_id) as newt
where new > 3;

#20. Calculate the average height of actors and actresses separately.
select rm.category,avg(n.height) as average_height
from names n
join role_mapping rm
on rm.name_id=n.id
group by rm.category;

#21. List the 10 oldest movies in the dataset along with their title, country, and director.
select movie.date_published, movie.title, movie.country, director_mapping.name_id as director 
from movie
join director_mapping
on movie.id=director_mapping.movie_id 
order by movie.date_published asc 
limit 10;

#22. List the top 5 movies with the highest total votes, along with their genres.
select votes.title, group_concat( genre.genre separator ',') as genre,votes.total_votes 
from(select movie.title,ratings.movie_id, ratings.total_votes
from movie
inner join ratings
on movie.id=ratings.movie_id 
order by ratings.total_votes desc 
limit 5) as votes
join genre
on votes.movie_id=genre.movie_id
group by votes.title,votes.total_votes;

#23. Identify the movie with the longest duration, along with its genre and production company.
select m.title,m.duration, group_concat(g.genre separator ',') as genre, m.production_company
from movie m
inner join genre g
on m.id=g.movie_id
group by m.id
order by m.duration desc
limit 1;

#24. Determine the total number of votes for each movie released in 2018.
select m.title,r.total_votes, year(m.date_published) as published_year
from ratings r
join movie m
on m.id=r.movie_id
where m.date_published between '2018-01-01' and '2018-12-31'
order by total_votes desc;

#25. What is the most common language in which movies were produced?
select languages, count(languages) as language_count
from movie
group by languages
order by language_count desc
limit 1;