create table players (
        player_name text,
        height text,
        college text,
        country text,
        draft_year text,
        draft_round text,
        draft_number text,
        season_stats season_stats[],
        scoring_class scoring_class,
        years_since_last_season INT,
        current_season INT,
        primary key(player_name, current_season)
);
