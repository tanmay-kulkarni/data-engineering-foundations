with with_previous as (
select
	actor,
	actorid,
	quality_class,
	is_active,
	lag("quality_class", 1) over(partition by actorid order by current_year) as previous_quality_class,
	lag("is_active", 1) over(partition by actorid order by current_year) as previous_is_active,
	current_year
from
	actors a
where current_year <= 2020
)
,
with_indicators as (
	select *,
			case when quality_class <> previous_quality_class then 1
			when is_active <> previous_is_active then 1
			else 0
			end as change_indicator			
	from with_previous
) 
,
with_streaks as (
	select *,
			sum(change_indicator) over(partition by actor order by current_year) as streak_identifier
	from with_indicators
)

select
	actor,
	quality_class,
	is_active,
	2020 as current_year,
	min(current_year) as start_year,
	max(current_year) as end_year
from
	with_streaks
group by
	actor,
	streak_identifier,
	is_active,
	quality_class
order by actor, streak_identifier
;