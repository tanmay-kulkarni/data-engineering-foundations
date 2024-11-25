/*
This SQL query creates and maintains a cumulative player statistics table by:
1. Combining existing player data (yesterday) with new season data (today)
2. Using COALESCE to retain/update player attributes
3. Handling season statistics as an array that accumulates year-over-year data

The cumulative table helps track player statistics across multiple seasons
in a single row per player, making historical analysis more efficient.

To append data for different years:
- Modify 'current_season = 1999' for existing data
- Modify 'season = 2000' for new season data to be added

Example: To add 2001 data, use:
current_season = 2000
season = 2001
*/

insert into players
with yesterday as (
    select 
        *
    from
    	players p
    where
    	current_season = 1999
),


today as (
    select
    	*
    from
    	player_seasons ps
    where
    	season = 2000
)

select
	coalesce (t.player_name,y.player_name) as player_name,
	coalesce (t.height,y.height) as height,
	coalesce (t.college,y.college) as college,
	coalesce (t.country, y.country) as country,
	coalesce (t.draft_year,y.draft_year) as draft_year,
	coalesce (t.draft_round,y.draft_round) as draft_round,
	coalesce (t.draft_number,y.draft_number) as draft_number,
	case
		when 
			y.season_stats is null then 
				array[row(t.season,t.gp,t.pts,t.reb,t.ast)::season_stats]
		when t.season is not null then 
				y.season_stats || 
				array[row(t.season,t.gp,t.pts,t.reb,t.ast)::season_stats]
		else y.season_stats
	end as season_stats,
	coalesce (t.season, y.current_season + 1) as current_season
from
	today t full outer join yesterday y
on
	t.player_name = y.player_name;