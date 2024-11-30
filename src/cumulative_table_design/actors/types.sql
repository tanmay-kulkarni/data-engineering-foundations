create type films as (
	film text,
	votes int,
	rating real,
	filmid text
)
;

create type quality_class as ENUM ('star', 'good', 'average', 'bad')
;

create type actor_scd_type as (
	quality_class quality_class,
	is_active boolean,
	start_year INTEGER,
	end_year INTEGER
)
;