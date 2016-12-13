-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE tournament;
CREATE DATABASE tournament;

\c tournament;

CREATE TABLE player (
    id serial primary key,
    name varchar not null
);

CREATE TABLE match (
    id serial primary key,
    winner int not null references player(id),
    loser int not null references player(id),
    CHECK (winner <> loser)
);

CREATE VIEW vw_player_standings AS (
    SELECT
    player.id,
    player.name,
    COUNT(winning_matches.winner) AS wins,
    COUNT(match.id) AS matches,
    ROW_NUMBER() OVER (ORDER BY COUNT(winning_matches.winner) DESC, name) as rank
    FROM player
    LEFT JOIN match ON (player.id = match.winner OR player.id = match.loser)
    LEFT JOIN match AS winning_matches ON (player.id = winning_matches.winner)
    GROUP BY player.id, name
    ORDER BY wins DESC, name
);

CREATE VIEW vw_swiss_matching AS (
    SELECT
    player1.id AS id1,
    player1.name AS name1,
    player2.id AS id2,
    player2.name AS name2
    FROM vw_player_standings AS player1,
    vw_player_standings AS player2
    WHERE player1.rank = player2.rank - 1
    AND player2.rank % 2 = 0
);
