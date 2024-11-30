-- Get records that were current at end of last year
with last_year_scd as (
	select *
	from actors_history_scd 
	where current_year = 2020 and end_year = 2020
)
-- Get historical records that ended before last year
, historical_scd as (
	select actor
		, "quality_class" 
		, is_active
		, start_year 
		, end_year 
from actors_history_scd 
where current_year  = 2020 and end_year < 2020
)

-- Get this year's current data
, this_year_data as (
	select *
	from actors
	where current_year = 2021
)
-- Get records where attributes haven't changed since last year
, unchanged_records as (
	select ts.actor
		, ts.quality_class
		, ts.is_active
		, ls.start_year
		, ts.current_year as end_year
	from this_year_data ts join last_year_scd ls
								on ls.actor = ts.actor
		where ts.quality_class = ls.quality_class and ts.is_active = ls.is_active
)
-- Create array of old and new records for changed attributes
, changed_records as (
	select ts.actor
		, unnest(
			array[
					row(
						ls.quality_class
						, ls.is_active
						, ls.start_year
						, ls.end_year
					)::actor_scd_type
					, row(
						ts.quality_class
						, ts.is_active
						, ts.current_year
						, ts.current_year
					)::actor_scd_type
				]
		) as records
from this_year_data ts left join last_year_scd ls
on ls.actor = ts.actor
where( ts.quality_class <> ls.quality_class or ts.is_active <> ls.is_active )
)
-- Expand the array of changed records into rows
, unnested_changed_records as (
	select actor
		,(records::actor_scd_type).quality_class
		,(records::actor_scd_type).is_active
		,(records::actor_scd_type).start_year
		,(records::actor_scd_type).end_year
from changed_records
)
-- Get records for new actors this year
, new_records as (
	select ts.actor
		, ts.quality_class
		, ts.is_active
		, ts.current_year as start_year
		, ts.current_year as end_year
from this_year_data ts
left join last_year_scd ls
on ts.actor = ls.actor
where ls.actor is null
)

-- Combine all records into final SCD table
select *, 2021 as current_year
from(
		select *
		from historical_scd

		union all

		select *
		from unchanged_records

		union all
		select *
		from unnested_changed_records

		union all
		select *
		from new_records
	) a
;