create type films as (
	film text,
	votes int,
	rating real,
	filmid text
)
;

create type quality_class as ENUM ('star', 'good', 'average', 'bad')
;
