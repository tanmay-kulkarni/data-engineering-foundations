create type vertex_type
as enum ('player', 'team', 'game')
;

create type edge_type
as enum('plays_against', 'shares_team', 'plays_in', 'plays_on')
;
