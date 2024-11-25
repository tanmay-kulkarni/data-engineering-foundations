with unnested as (

	select player_name, (unnest(season_stats)::season_stats).*
	from players p 
	where current_season  = 2001 and player_name = 'Michael Jordan'
)

select player_name, gp, pts, reb, ast
from unnested
;