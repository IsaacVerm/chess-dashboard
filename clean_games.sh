#!/bin/bash

# Clean game results
# Usage: ./clean_games.sh

echo "date,opponent,result" > data/games.csv

jq -r '
  def timestamp_to_date: . / 1000 | strftime("%Y-%m-%d");
  def get_opponent: if .players.white.user.name == "indexinator" then .players.black.user.name else .players.white.user.name end;
  def get_result: 
    if .winner then
      if (.players.white.user.name == "indexinator" and .winner == "white") or 
         (.players.black.user.name == "indexinator" and .winner == "black") then 1
      else 0 end
    else 0.5 end;
  
  (.createdAt | timestamp_to_date) + "," + get_opponent + "," + (get_result | tostring)
' data/raw_games.ndjson >> data/games.csv