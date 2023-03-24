SELECT
	BIN_TO_UUID(event_uuid),
    event_time,
    event_name,
    game_time,
    BIN_TO_UUID(user_uuid),
    BIN_TO_UUID(game_uuid)
FROM game_event
WHERE event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
ORDER BY event_time DESC