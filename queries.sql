-- =============================================
-- PL Analytics Pipeline — Analysis Queries
-- =============================================

-- 1. ROLLING TEAM FORM
-- Calculates points earned in the last 5 games for a given team,
-- using a window function to look backward over recent rows.
WITH chelsea_matches AS (
    SELECT
        utc_date,
        CASE
            WHEN home_team_name = 'Chelsea FC' THEN away_team_name
            ELSE home_team_name
        END AS opponent,
        CASE
            WHEN (home_team_name = 'Chelsea FC' AND home_score > away_score)
              OR (away_team_name = 'Chelsea FC' AND away_score > home_score) THEN 3
            WHEN home_score = away_score THEN 1
            ELSE 0
        END AS points
    FROM matches
    WHERE home_team_name = 'Chelsea FC' OR away_team_name = 'Chelsea FC'
)
SELECT
    utc_date,
    opponent,
    points,
    SUM(points) OVER (
        ORDER BY utc_date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS rolling_5_game_points
FROM chelsea_matches
ORDER BY utc_date;


-- 2. HEAD-TO-HEAD RECORD
-- Tallies the full record between two specific teams across all meetings.
SELECT
    home_team_name,
    away_team_name,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN home_score > away_score THEN 1 ELSE 0 END) AS home_wins,
    SUM(CASE WHEN away_score > home_score THEN 1 ELSE 0 END) AS away_wins,
    SUM(CASE WHEN home_score = away_score THEN 1 ELSE 0 END) AS draws
FROM matches
WHERE (home_team_name = 'Chelsea FC' AND away_team_name = 'Arsenal FC')
   OR (home_team_name = 'Arsenal FC' AND away_team_name = 'Chelsea FC')
GROUP BY home_team_name, away_team_name;


-- 3. MANAGER-ERA PERFORMANCE SPLIT
-- Compares Chelsea's results under Pochettino (2023/24) vs. Maresca (2024/25),
-- using a date cutoff to divide matches into each manager's tenure.
SELECT
    CASE
        WHEN utc_date < '2024-07-01' THEN 'Pochettino (2023/24)'
        ELSE 'Maresca (2024/25)'
    END AS manager_era,
    COUNT(*) AS matches_played,
    SUM(CASE
        WHEN (home_team_name = 'Chelsea FC' AND home_score > away_score)
          OR (away_team_name = 'Chelsea FC' AND away_score > home_score) THEN 1
        ELSE 0
    END) AS wins,
    SUM(CASE WHEN home_score = away_score THEN 1 ELSE 0 END) AS draws,
    SUM(CASE
        WHEN (home_team_name = 'Chelsea FC' AND home_score < away_score)
          OR (away_team_name = 'Chelsea FC' AND away_score < home_score) THEN 1
        ELSE 0
    END) AS losses,
    ROUND(AVG(CASE
        WHEN home_team_name = 'Chelsea FC' THEN home_score
        ELSE away_score
    END), 2) AS avg_goals_scored
FROM matches
WHERE home_team_name = 'Chelsea FC' OR away_team_name = 'Chelsea FC'
GROUP BY manager_era;