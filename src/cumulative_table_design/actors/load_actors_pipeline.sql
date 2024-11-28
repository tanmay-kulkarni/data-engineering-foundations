insert into actors
with years as (
	select *
	from generate_series(1970, 2022) as current_year
)
,

-- first movie year for every actor
actor_first_movie_year AS (
    SELECT
        actor,
        actorid,
        MIN(year) AS first_movie_year
    FROM actor_films af 
    GROUP BY actor,actorid 
)
,
-- generates all possible combinations of actors and films from their first film onwards
actors_and_film_stats AS (
    SELECT *
    FROM actor_first_movie_year p JOIN years y
    ON p.first_movie_year <= y.current_year
)
,
windowed AS (
    SELECT
        pas.actor,
        pas.actorid,
        pas.current_year,
        ARRAY_REMOVE(
            ARRAY_AGG(
                CASE
                    WHEN ps.year IS NOT NULL
                        THEN ROW(
                            ps."year",
                            ps.film,
                            ps.votes,
                            ps.rating,
                            ps.filmid
                        )::films
                end)
            OVER (PARTITION BY pas.actor ORDER BY COALESCE(pas.current_year, ps.year)),
            NULL
        ) AS films
    FROM actors_and_film_stats pas LEFT JOIN actor_films ps -- this could do with some less confusing names
        ON pas.actor = ps.actor
        AND pas.current_year = ps.year
    ORDER BY pas.actor, pas.current_year
)


select  w.actor,
        w.actorid,
        films,
	    CASE
        WHEN (films[CARDINALITY(films)]::films).rating > 8 THEN 'star'
        WHEN (films[CARDINALITY(films)]::films).rating > 7 and (films[CARDINALITY(films)]::films).rating < 8 THEN 'good'
        WHEN (films[CARDINALITY(films)]::films).rating > 6 and (films[CARDINALITY(films)]::films).rating <7 THEN 'average'
        ELSE 'bad'
    END::quality_class AS quality_class,
    w.current_year - (films[CARDINALITY(films)]::films).year as years_since_last_film,
    w.current_year,
    (films[CARDINALITY(films)]::films).year = w.current_year AS is_active
from windowed w

select *
from actors
;
