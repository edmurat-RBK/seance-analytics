SELECT 
	BIN_TO_UUID(event_uuid) AS `Event UUID`,
    event_time AS `Event time`,
    event_type AS `Event type`
FROM (
    SELECT event_uuid, event_time, "Session launched" AS event_type FROM session_launched
	UNION
	SELECT event_uuid, event_time, "Session exited" AS event_type FROM session_exited
	UNION
	SELECT event_uuid, event_time, "Game started" AS event_type FROM game_started
	UNION
	SELECT event_uuid, event_time, "Game stopped" AS event_type FROM game_stopped
	UNION
	SELECT event_uuid, event_time, "Player connected" AS event_type FROM player_connected
	UNION
	SELECT event_uuid, event_time, "Chapter revealed" AS event_type FROM chapter_revealed
	UNION
	SELECT event_uuid, event_time, "Chapter resolved" AS event_type FROM chapter_resolved
	UNION
    SELECT event_uuid, event_time, "Reward picked" AS event_type FROM reward_picked
    UNION
	SELECT event_uuid, event_time, "Player turn" AS event_type FROM player_turn
	UNION
	SELECT event_uuid, event_time, "Card drew" AS event_type FROM card_drew
	UNION
	SELECT event_uuid, event_time, "Card played" AS event_type FROM card_played
	UNION
	SELECT event_uuid, event_time, "Card discarded" AS event_type FROM card_discarded
	UNION
	SELECT event_uuid, event_time, "Player cheated" AS event_type FROM player_cheated
    UNION
	SELECT event_uuid, event_time, "Cheat detected" AS event_type FROM cheat_detected
	UNION
	SELECT event_uuid, event_time, "Player death" AS event_type FROM player_death
) AS `Events`
WHERE event_time BETWEEN "2023-02-03 12:00:00" AND "2023-02-03 15:30:00"
ORDER BY event_time DESC;