create table actors (
	actor text,
	actorid text,
	films films[],
	quality_class quality_class,
	years_since_last_film int,
	current_year int
	is_active bool,
)
;

create table actors_history_scd (
	actor text,
	quality_class quality_class,
	is_active boolean,
	current_year int,
	start_year int,
	end_year int,
	primary key (actor, start_year)
)
;