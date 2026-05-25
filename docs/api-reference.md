# Volleyball Life API Reference

## Base URL
`https://api-v8.volleyballlife.com`

## Authentication
Cookie-based session auth. Login via POST to auth endpoint (details TBD).

## User Schedule Endpoint

### `GET /api/me/schedule?date=2026-06-15`

Returns the authenticated user's matches and reffing assignments for a given date.

**Response shape:**
```json
{
  "userId": 98765,
  "date": "2026-06-15",
  "timezone": "America/Los_Angeles",
  "events": [
    {
      "type": "match",
      "role": "player",
      "tournamentId": 45678,
      "tournamentName": "Summer Beach Classic",
      "divisionName": "Women's Open",
      "roundName": "Day 1",
      "parentType": "pool",
      "parentName": "Pool 1",
      "matchId": 81001,
      "matchNumber": 1,
      "court": "1",
      "scheduledStartTime": "2026-06-15T16:00:00Z",
      "scheduledStartDisplay": "9:00 AM",
      "homeTeam": { "name": "Cook / Smith" },
      "awayTeam": { "name": "Nguyen / Patel" },
      "status": "Started",
      "games": [
        { "id": 91001, "number": 1, "to": 21, "cap": 23, "home": 12, "away": 10 }
      ],
      "canScore": true,
      "liveScoring": {
        "startUrl": "/matches/scoring/start",
        "updateUrl": "/matches/scoring/update",
        "keyRequired": true
      }
    }
  ]
}
```

### Event Roles
- `"player"` — user is on one of the teams
- `"ref"` — user is assigned as referee

### Match Status Values
- `null` — not started
- `"Started"` — in progress
- `"Finished"` — completed

### Parent Types
- `"pool"` — pool play match
- `"bracket"` — bracket/playoff match

## Live Scoring Endpoints

### Start scoring: `POST /matches/scoring/start`
### Update score: `POST /matches/scoring/update`
