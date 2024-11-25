create type season_stats as (
        season INT,
        gp INT,
        pts real,
        reb real,
        ast real
)
;


create type scoring_class as ENUM ('star', 'good', 'average', 'bad')
;