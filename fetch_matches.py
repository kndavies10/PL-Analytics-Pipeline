import requests
import json
import psycopg2
import os

API_TOKEN = os.environ["FOOTBALL_API_TOKEN"]
BASE_URL = "https://api.football-data.org/v4"

def fetch_season_matches(season: int):
    url = f"{BASE_URL}/competitions/PL/matches"
    headers = {"X-Auth-Token": API_TOKEN}
    params = {"season": season}

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

def load_matches_to_db(data):
    conn = psycopg2.connect(dbname="pl_analytics")
    cur = conn.cursor()

    for match in data["matches"]:
        cur.execute("""
            INSERT INTO matches (
                id, utc_date, matchday, status,
                home_team_id, home_team_name,
                away_team_id, away_team_name,
                home_score, away_score, winner,
                season_start_date, season_end_date
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (
            match["id"],
            match["utcDate"],
            match["matchday"],
            match["status"],
            match["homeTeam"]["id"],
            match["homeTeam"]["name"],
            match["awayTeam"]["id"],
            match["awayTeam"]["name"],
            match["score"]["fullTime"]["home"],
            match["score"]["fullTime"]["away"],
            match["score"]["winner"],
            data["matches"][0].get("season", {}).get("startDate"),
            data["matches"][0].get("season", {}).get("endDate"),
        ))

    conn.commit()
    cur.close()
    conn.close()
    print(f"Loaded {len(data['matches'])} matches into the database")

if __name__ == "__main__":
    seasons = [2023, 2024]  #2023/24, 2024/25

    for season in seasons:
        print(f"--- Fetching season {season} ---")
        data = fetch_season_matches(season)
        print(f"Fetched {len(data['matches'])} matches")
        load_matches_to_db(data)