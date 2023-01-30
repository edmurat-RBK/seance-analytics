SELECT 
	name AS `Card`,
    IF(
		table_count_drew.count IS NULL,
		0,
		table_count_drew.count
    ) AS `Draw count`,
    IF(
		table_count_play.count IS NULL,
		0,
		table_count_play.count
    ) AS `Play count`,
    IF(
		table_count_discard.count IS NULL,
		0,
		table_count_discard.count
    ) AS `Discard count`,
    
    CONCAT(ROUND(IF(
		table_count_drew.count IS NULL,
		0,
		IF(
			table_count_play.count IS NULL,
			0,
			table_count_play.count
		)/IF(
			table_count_drew.count IS NULL,
			0,
			table_count_drew.count
		)
    )*100,2),"%") AS `Playrate`
    
FROM card
	LEFT OUTER JOIN (
		SELECT card_uuid, COUNT(*) AS count
        FROM card_drew
        GROUP BY card_uuid
    ) AS table_count_drew
	ON table_count_drew.card_uuid = card.uuid
    LEFT OUTER JOIN (
		SELECT card_uuid, COUNT(*) AS count
        FROM card_played
        GROUP BY card_uuid
    ) AS table_count_play
	ON table_count_play.card_uuid = card.uuid
    LEFT OUTER JOIN (
		SELECT card_uuid, COUNT(*) AS count
        FROM card_discarded
        GROUP BY card_uuid
    ) AS table_count_discard
	ON table_count_discard.card_uuid = card.uuid