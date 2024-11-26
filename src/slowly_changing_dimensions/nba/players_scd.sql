create table players_scd (
	player_name text,
	scoring_class scoring_class,
	is_active boolean,
	start_season int,
	end_season int,
	current_season int,
	primary key(player_name, start_season)
)
;
