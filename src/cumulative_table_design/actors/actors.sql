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
