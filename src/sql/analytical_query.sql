/*
This query calculates player improvement by comparing their first season points
vs latest season points, ordered by the highest improvement factor
*/
select
    player_name,
    season_stats[1].pts as first_season,
    season_stats[cardinality(season_stats)].pts as latest_season,
    (season_stats[cardinality(season_stats)].pts) / (
        case when season_stats[1].pts = 0 then 1 else season_stats[1].pts end
    ) as times_improvement
from players p
where current_season = 2001
order by 4 desc
