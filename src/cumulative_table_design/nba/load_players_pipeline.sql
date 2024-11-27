INSERT INTO players

WITH years AS (
    SELECT *
    FROM GENERATE_SERIES(1996, 2022) AS current_season
)
,

-- this gives the first season for every player
p AS (
    SELECT
        player_name,
        MIN(season) AS first_season
    FROM player_seasons
    GROUP BY player_name
), 

-- generates all possible combinations of players and season_stats from their first season onwards
players_and_season_stats AS (
    SELECT *
    FROM p JOIN years y
    ON p.first_season <= y.current_season
), 

windowed AS (
    SELECT
        pas.player_name,
        pas.current_season,
        ARRAY_REMOVE(
            ARRAY_AGG(
                CASE
                    WHEN ps.season IS NOT NULL
                        THEN ROW(
                            ps.season,
                            ps.gp,
                            ps.pts,
                            ps.reb,
                            ps.ast
                        )::season_stats
                END)
            OVER (PARTITION BY pas.player_name ORDER BY COALESCE(pas.current_season, ps.season)),
            NULL
        ) AS season_stats
    FROM players_and_season_stats pas LEFT JOIN player_seasons ps -- this could do with some less confusing names
        ON pas.player_name = ps.player_name
        AND pas.current_season = ps.season
    ORDER BY pas.player_name, pas.current_season
), 

static AS (
    SELECT
        player_name,
        MAX(height) AS height,
        MAX(college) AS college,
        MAX(country) AS country,
        MAX(draft_year) AS draft_year,
        MAX(draft_round) AS draft_round,
        MAX(draft_number) AS draft_number
    FROM player_seasons
    GROUP BY player_name
)

SELECT
    w.player_name,
    s.height,
    s.college,
    s.country,
    s.draft_year,
    s.draft_round,
    s.draft_number,
    season_stats,
    CASE
        WHEN (season_stats[CARDINALITY(season_stats)]::season_stats).pts > 20 THEN 'star'
        WHEN (season_stats[CARDINALITY(season_stats)]::season_stats).pts > 15 THEN 'good'
        WHEN (season_stats[CARDINALITY(season_stats)]::season_stats).pts > 10 THEN 'average'
        ELSE 'bad'
    END::scoring_class AS scoring_class,
    w.current_season - (season_stats[CARDINALITY(season_stats)]::season_stats).season as years_since_last_season,
    w.current_season,
    (season_stats[CARDINALITY(season_stats)]::season_stats).season = w.current_season AS is_active
FROM windowed w
JOIN static s
    ON w.player_name = s.player_name;
