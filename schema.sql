-- =============================================
-- PL Analytics Pipeline — Database Schema
-- =============================================

CREATE TABLE matches (
    id INTEGER PRIMARY KEY,
    utc_date TIMESTAMP,
    matchday INTEGER,
    status TEXT,
    home_team_id INTEGER,
    home_team_name TEXT,
    away_team_id INTEGER,
    away_team_name TEXT,
    home_score INTEGER,
    away_score INTEGER,
    winner TEXT,
    season_start_date DATE,
    season_end_date DATE
);