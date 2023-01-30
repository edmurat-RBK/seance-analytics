SELECT 
    (
		SELECT name
        FROM chapter
        WHERE uuid = chapter_revealed.chapter_uuid
    ) AS `Chapter name`,
    CONCAT(ROUND(AVG(TIMEDIFF(
		chapter_resolved.event_time,
        chapter_revealed.event_time
	)),2)," secondes") AS `Average res. time`,
    CONCAT(ROUND(MIN(TIMEDIFF(
		chapter_resolved.event_time,
        chapter_revealed.event_time
	)),2)," secondes") AS `Minimal res. time`,
    CONCAT(ROUND(MAX(TIMEDIFF(
		chapter_resolved.event_time,
        chapter_revealed.event_time
	)),2)," secondes") AS `Maximal res. time`
FROM chapter_resolved
	INNER JOIN chapter_revealed
    ON chapter_resolved.game_uuid = chapter_revealed.game_uuid
		AND chapter_resolved.chapter_index = chapter_revealed.chapter_index
GROUP BY `Chapter name`
ORDER BY ROUND(AVG(TIMEDIFF(
			chapter_resolved.event_time,
			chapter_revealed.event_time
		)),2) DESC;