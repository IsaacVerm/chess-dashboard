#!/bin/bash

# Fetch game results from Lichess API
# Usage: ./fetch_games.sh [username] [max_games]

USERNAME=${1:-indexinator}

echo "Fetching games for user: $USERNAME"

# Create data directory if it doesn't exist
mkdir -p data

# Fetch games from Lichess API
# The API returns NDJSON (newline-delimited JSON)
curl -s "https://lichess.org/api/games/user/$USERNAME?rated=true" \
  -H "Accept: application/x-ndjson" \
  > data/raw_games.ndjson

# Check if the request was successful
if [ $? -eq 0 ]; then
    echo "Successfully fetched games data"
    echo "Number of games fetched: $(wc -l < data/raw_games.ndjson)"
else
    echo "Error fetching games data"
    exit 1
fi

# Optional: Show first game as example
echo "First game example:"
head -1 data/raw_games.ndjson | jq '.'
