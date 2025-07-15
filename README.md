# chess-dashboard

## Goal

I'm playing chess on lichess.org and I want to keep track of some key chess metrics of my chess play.
Metrics can be about anything: winning rate, average time taken for a move, average evaluation loss per move,...

## First iteration: score percentage

In a first iteration I'll focus on a single metric: score percentage.
I want to know if lately I've been playing better than I've been playing before.
To do this I calculate the score I obtained in a specific time period and the maximum score I could have obtained in the same time period. For example if I won 5 times and drew 2 times my score will be 6 (5 * 1 + 2 * 0.5) while I could have had a score of 7 if I won all all games. The score percentage in this case would be 6/7.

## Implementation

I want to create a small pipeline which fetches data from lichess.org and calculates some metrics.
This pipeline is run daily using GitHub Actions.

### 1. Fetch game results using the [Lichess API](https://lichess.org/api)
 
Use `curl` to make a GET request to the `https://lichess.org/api/games/user/indexinator` endpoint.
Keep in mind the `Content type` is `application/x-ndjson`

This endpoint will return `JSON` like this:

```
{
  "id": "Lr0wZGIA",
  "rated": true,
  "variant": "standard",
  "speed": "blitz",
  "perf": "blitz",
  "createdAt": 1744231822635,
  "lastMoveAt": 1744232244456,
  "status": "resign",
  "source": "arena",
  "players": {
    "white": {
      "user": {
        "name": "Lance5500",
        "title": "LM",
        "patron": true,
        "id": "lance5500"
      },
      "rating": 2620,
      "ratingDiff": -8,
      "analysis": {
        "inaccuracy": 3,
        "mistake": 1,
        "blunder": 3,
        "acpl": 36,
        "accuracy": 85
      }
    },
    "black": {
      "user": {
        "name": "celvic",
        "id": "celvic"
      },
      "rating": 2453,
      "ratingDiff": 8,
      "analysis": {
        "inaccuracy": 4,
        "mistake": 2,
        "blunder": 0,
        "acpl": 25,
        "accuracy": 91
      }
    }
  },
  "winner": "black",
  "opening": {
    "eco": "A52",
    "name": "Indian Defense: Budapest Defense",
    "ply": 6
  },
  "moves": "d4 Nf6 c4 e5 dxe5 Ng4 Nh3 Nxe5 e3 g6 Nf4 Bg7 Be2 O-O O-O d6 Nc3 Nbd7 Qd2 a5 b3 a4 Rb1 Nc5 b4 Ne6 Nh3 c6 Bb2 a3 Ba1 Qh4 f4 Ng4 Bxg4 Qxg4 Ne4 Qh4 Bxg7 Nxg7 Nhf2 Rd8 Nxd6 Qe7 c5 Ne8 Rfd1 Be6 e4 b6 e5 Bd5 Rbc1 bxc5 bxc5 Rab8 Rc2 Nc7 h3 Ne6 Kh2 Qh4 g3 Qe7 Qe3 Rb2 Rdd2 Rdb8 Nd1 Rb1 Rxd5 cxd5 Nc3 d4 Nd5 Qxd6 cxd6 dxe3 Nxe3 R1b2",
  "analysis": ...,
  "tournament": "kwfVwY5B",
  "clock": {
    "initial": 300,
    "increment": 0,
    "totalTime": 300
  },
  "division": {
    "middle": 25,
    "end": 77
  }
}
```

### 2. Clean game results

Use `jq` to only keep fields relevant for this dashboard:

- name of the White player: `players.white.user.name`
- name of the Black player: `players.black.user.name`
- color that won: `winner`

Simplify the data into a CSV file with these fields:

- `date`: formatted like YYYY-MM-DD, extracted from timestamp `createdAt` (e.g. 1744231822635)
- `opponent`: name of opponent, name of White player if `indexinator` was Black, name of Black player if `indexinator` was White
- `result`: 0 if `indexinator` lost, 0.5 if a draw, 1 if `indexinator` won

Please use `jq` to simplify into a CSV file if possible.

### 3. Calculate metrics

Use `awk` to calculate the following fields:

- `score_last_week`: sum of results in last week
- `max_score_last_week`: maximum potential score in last week based on number of games played
- `score_before_last_week`: sum of results before last week
- `max_score_before_last_week`: maximum potential score in games played before last week
- `score_percentage_last_week`: `score_last_week` / `max_score_last_week`
- `score_percentage_before_last_week`: `score_before_last_week` / `max_score_before_last_week`
- `date`: current day in YYYY-MM-DD format

### 4. Use GitHub Actions to run everything daily

Create Github workflow config so fetching the game results, cleaning them and calculating metrics based upon them is done daily with GitHub Actions.