#!/bin/bash

# Calculate metrics
# Usage: ./calculate_metrics.sh
# This assumes there's already a file data/metrics.csv containing the header with fields in the same order as the output results

awk -F',' '
BEGIN {
    # Get current date and calculate date 7 days ago
    "date +%Y-%m-%d" | getline current_date
    "date -d \"7 days ago\" +%Y-%m-%d" | getline week_ago_date
    
    score_last_week = 0
    max_score_last_week = 0
    score_before_last_week = 0
    max_score_before_last_week = 0
}
NR > 1 {  # Skip header row
    game_date = $1
    result = $3
    
    if (game_date >= week_ago_date) {
        # Game is from last week
        score_last_week += result
        max_score_last_week += 1
    } else {
        # Game is from before last week
        score_before_last_week += result
        max_score_before_last_week += 1
    }
}
END {
    # Calculate percentages (handle division by zero)
    score_percentage_last_week = (max_score_last_week > 0) ? score_last_week / max_score_last_week : 0
    score_percentage_before_last_week = (max_score_before_last_week > 0) ? score_before_last_week / max_score_before_last_week : 0
    
    # Output results
    printf "%.1f,%d,%.1f,%d,%.3f,%.3f,%s\n", 
           score_last_week, max_score_last_week, 
           score_before_last_week, max_score_before_last_week,
           score_percentage_last_week, score_percentage_before_last_week,
           current_date
}' data/games.csv >> data/metrics.csv
