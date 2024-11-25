create table actors (
	actor text,
	actorid text,
	films films[],
	quality_class quality_class,
	is_active bool,
	years_since_last_film int,
	current_year int
)
;
