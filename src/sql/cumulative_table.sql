with
    yesterday as (
        select * 
        from players p 
        where current_season = 1995
    ),
    
    today as (
        select *
        from player_seasons ps 
        where season = 1996
    )

select
    *,
    coalesce(t.player_name, y.player_name) as player_name,
    coalesce(t.height, y.height) as height,
    coalesce(t.college, y.college) as college,
    coalesce(t.draft_year, y.draft_year) as player_name,
    coalesce(t.draft_round, y.draft_round) as player_name,
    coalesce(t.draft_number, y.draft_number) as player_name,
    case
        when y.season_stats is null
        then array[row(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        when t.season is not null
        then
            y.season_stats
            || array[row(t.season, t.gp, t.pts, t.reb, t.ast)::season_stats]
        else y.season_stats
    end as season_stats,
    coalesce(t.season, y.current_season + 1) as current_season
from today t
full outer join yesterday y on t.player_name = y.player_name
;