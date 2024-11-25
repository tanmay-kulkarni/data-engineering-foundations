-- select * from actors where current_year = 1978;
-- This query creates a cumulative table, where each year's records are merged with the previous year's data,
-- maintaining an ongoing history of actor performances while updating their current status and metrics

insert into actors
with yesterday as (
	select *
	from actors af 
	where current_year = 1977
)
,
today as (
	select *
	from actor_films af 
	where year = 1978
)

select 
	coalesce (t.actor,y.actor) as actor,
	coalesce (t.actorid,y.actorid) as actorid,
	-- films
	case
		when 
			y.films is null then 
				array[row(t.film,t.votes,t.rating,t.filmid)::films]
		when t.year is not null then 
				y.films || 
				array[row(t.film,t.votes,t.rating,t.filmid)::films]
		else y.films
	end as films,
	
	-- quality_class
	case when t.year is not null then
	case when t.rating > 8 then 'star'
		 when t.rating > 7 and t.rating <=8 then 'good'
		 when t.rating > 6 and t.rating <=7 then 'average'
		 else 'bad'
	end::quality_class
	else y.quality_class end as quality_class,
	
	case when t.year is not null then true else false end as is_active,
	
	case when t.year is not null then 0 else 
			y.years_since_last_film + 1 end as years_since_last_film,
	
	coalesce (t.year, y.current_year + 1) as current_year

from yesterday y full outer join today t
on y.actorid = t.actorid
;