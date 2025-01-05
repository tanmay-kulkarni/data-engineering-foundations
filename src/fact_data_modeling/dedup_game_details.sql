-- Assigns row numbers to records grouped by game_id, team_id, and player_id
-- and filters to keep only the first occurrence of each combination,
-- effectively removing any duplicate records
with
    record_number_added as (
        select
            *,
            row_number() over (
                partition by
                    game_id,
                    team_id,
                    player_id
            ) as record_num
        from
            game_details
    )
select
    *
from
    record_number_added
where
    record_num = 1
