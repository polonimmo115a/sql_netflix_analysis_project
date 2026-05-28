drop table if exists netflix;
create table netflix(
          show_id varchar(10),
          type varchar(10),
          title varchar(150),
          director varchar(210),
          casts varchar(1000),
          country varchar(150),
          date_added varchar(50),
          release_year int8,
          rating varchar(10),
          duration varchar(20),		  
          listed_in varchar(100),
          description varchar(500)


);
select * from netflix
--- row count(total content)
select count(*) as total_content
from netflix
---finding the distinct type of content
select distinct type from netflix
---15 business problem
1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
--1. Count the number of Movies vs TV Shows
select count(*) as no_of_count,type
from netflix
group by type
--2. Find the most common rating for movies and TV shows
with ratingcount as(
select type,rating,count(*) as count_rating
from netflix
group by 1,2
),
rankedrating as (
select type,rating,count_rating,rank() over(partition by type order by count_rating desc) as rank
from ratingcount
)
select type,rating as most_frequent_rating
from rankedrating
where rank=1

--3. List all movies released in a specific year (e.g., 2020)
select type,release_year
from netflix 
where type='Movie' and release_year=2020
--4. Find the top 5 countries with the most content on Netflix
select unnest(string_to_array(country,',')) as new_country,count(*) as no_of_content
from netflix
group by 1
order by 2 desc
limit 5
--5. Identify the longest movie
SELECT duration	
FROM netflix
WHERE type = 'Movie' and duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
limit 1

--6. Find content added in the last 5 years
select to_date(date_added,'month dd,yyyy') as new_date_added,show_id,type,title from netflix
where to_date(date_added,'month dd,yyyy')>=current_date-interval '5 years'
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select *
from ( select *,unnest(string_to_array(director,',')) as director_name from netflix ) 
where director_name='Rajiv Chilaka'
--8. List all TV shows with more than 5 seasons
select * from netflix
where type='TV Show' and split_part(duration,' ',1)::int>5
--9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as genre,
count(*) as no_of_content
from netflix 
group by 1
--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
select extract(year from to_date(date_added,'month dd,yyyy')),count(*),
count(*)::numeric/(select count(*) from netflix where country='India')::numeric * 100 as avg_content 
from netflix 
where country='India'
group by 1
order by 3 desc
limit 5
--11. List all movies that are documentaries
select listed_in from netflix
where listed_in like'%Documentaries%'
--12. Find all content without a director
select * from netflix
where director is null
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select count(*) as no_of_movies_appeared from netflix
where casts like '%Salman Khan%'
and release_year>extract(year from current_date)-10
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select unnest(string_to_array(casts,',')) as actors, count(*) as no_of_movies
from netflix
where country='India'
group by 1
order by 2 desc
limit 10
--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
select category,type,count(*) as no_of_items  from (
select *,case when description like '%kill%' or description like '%violence%' then 'Bad'
else 'Good' end as category from netflix)
group by 1,2
order by 3 desc


