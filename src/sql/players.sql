create table players (
        player_name text,
        height text,
        college text,
        country text,
        draft_year text,
        draft_round text,
        draft_number text,
        season_stats season_stats[],
        current_season INT,
        primary key(player_name, current_season)
);
