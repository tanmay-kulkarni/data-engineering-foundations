-- Get all distinct years from the actors table to use as cutoff points for SCD generation
insert into actors_history_scd
with snapshot_years as (
    select distinct current_year as cutoff_year
    from actors
    order by current_year
),
scd_for_each_cutoff as (
    -- For each cutoff year, get all actor states up to that point and calculate previous values
    with with_previous as (
        select
            a.actor,
            a.actorid,
            a.quality_class,
            a.is_active,
            -- Get previous values to detect changes
            lag("quality_class", 1) over(partition by actorid order by current_year) as previous_quality_class,
            lag("is_active", 1) over(partition by actorid order by current_year) as previous_is_active,
            a.current_year as snapshot_year
        from actors a
        join snapshot_years y on a.current_year <= y.cutoff_year
    ),
    -- Identify points where state changes occurred (quality class or active status changed)
    with_indicators as (
        select *,
                case when quality_class <> previous_quality_class then 1
                when is_active <> previous_is_active then 1
                else 0
                end as change_indicator           
        from with_previous
    ),
    -- Group states into streaks based on when changes occurred
    with_streaks as (
        select *,
                sum(change_indicator) over(partition by actor order by snapshot_year) as streak_identifier
        from with_indicators
    )
    -- Generate final SCD records showing validity periods for each state
    select
        actor,
        quality_class,
        is_active,
        y.cutoff_year,
        min(w.snapshot_year) as start_year,  -- When this state began
        max(w.snapshot_year) as end_year     -- When this state ended
    from with_streaks w
    cross join snapshot_years y
    where w.snapshot_year <= y.cutoff_year
    group by
        actor,
        streak_identifier,
        is_active,
        quality_class,
        y.cutoff_year
)
select * from scd_for_each_cutoff
order by actor, cutoff_year, start_year
;