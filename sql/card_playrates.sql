SELECT *
FROM (
	SELECT 
		card_drew.card_name AS `Card`,
		IF(
			card_drew.count IS NULL,
			0,
			card_drew.count
		) AS `Draw count`,
		IF(
			card_played.count IS NULL,
			0,
			card_played.count
		) AS `Play count`,
		IF(
			card_discarded.count IS NULL,
			0,
			card_discarded.count
		) AS `Discard count`,
        IF(
			card_dumped.count IS NULL,
			0,
			card_dumped.count
		) AS `Dump count`,
		
		CONCAT(ROUND(IF(
			card_drew.count IS NULL,
			0,
			IF(
				card_played.count IS NULL,
				0,
				card_played.count
			)/IF(
				card_drew.count IS NULL,
				0,
				card_drew.count
			)
		)*100,2),"%") AS `Playrate`
	FROM (
		SELECT card_name, COUNT(*) AS count
		FROM game_event
		WHERE event_name = "card_draw"
			AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
		GROUP BY card_name
	) AS card_drew
	LEFT OUTER JOIN (
		SELECT card_name, COUNT(*) AS count
		FROM game_event
		WHERE event_name = "card_play"
			AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
		GROUP BY card_name
	) AS card_played
	ON card_drew.card_name = card_played.card_name
	LEFT OUTER JOIN (
		SELECT card_name, COUNT(*) AS count
		FROM game_event
		WHERE event_name = "card_discard"
			AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
		GROUP BY card_name
	) AS card_discarded
	ON card_drew.card_name = card_discarded.card_name
	LEFT OUTER JOIN (
		SELECT card_name, COUNT(*) AS count
		FROM game_event
		WHERE event_name = "card_dump"
			AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
		GROUP BY card_name
	) AS card_dumped
	ON card_drew.card_name = card_dumped.card_name
) AS card_stats
ORDER BY `Playrate` DESC