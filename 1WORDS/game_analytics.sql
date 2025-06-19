CREATE SCHEMA game_analytics;
USE game_analytics;

DROP TABLE IF EXISTS register;
CREATE TABLE register (
	uid INTEGER,
	reg_ts TIMESTAMP
);

DROP TABLE IF EXISTS cookie_cats;
CREATE TABLE cookie_cats (
	userid INTEGER,
	version text,
    sum_gamerounds INTEGER,
    retention_1 VARCHAR(50),
    retention_7 VARCHAR(50)
);