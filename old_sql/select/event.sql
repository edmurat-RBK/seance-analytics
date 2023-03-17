SELECT *
FROM (
    SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Session launched" AS `Event type` FROM session_launched
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Session exited" AS `Event type` FROM session_exited
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Game started" AS `Event type` FROM game_started
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Game stopped" AS `Event type` FROM game_stopped
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Player connected" AS `Event type` FROM player_connected
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Chapter revealed" AS `Event type` FROM chapter_revealed
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Chapter resolved" AS `Event type` FROM chapter_resolved
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Player turn" AS `Event type` FROM player_turn
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Card drew" AS `Event type` FROM card_drew
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Card played" AS `Event type` FROM card_played
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Card discarded" AS `Event type` FROM card_discarded
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Player cheated" AS `Event type` FROM player_cheated
	UNION
	SELECT BIN_TO_UUID(event_uuid) AS `Event UUID`, event_time AS `Event time`, "Player death" AS `Event type` FROM player_death
) AS `Events`
ORDER BY `Event time` DESC;