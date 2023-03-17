SELECT
    (
		SELECT name
        FROM chapter
        WHERE uuid = chapter_revealed.chapter_uuid
    ) AS `Chapter name`,
    COUNT(chapter_revealed.event_uuid) AS `Occurences`,
    COUNT(chapter_resolved.event_uuid) AS `Resolutions`,
    CONCAT(ROUND(AVG(TIMESTAMPDIFF(
		MICROSECOND,
        chapter_revealed.event_time,
		chapter_resolved.event_time
	)/1000000),2)," secondes") AS `Average res. time`,
    CONCAT(ROUND(MIN(TIMESTAMPDIFF(
		MICROSECOND,
		chapter_revealed.event_time,
		chapter_resolved.event_time
	)/1000000),2)," secondes") AS `Minimal res. time`,
    CONCAT(ROUND(MAX(TIMESTAMPDIFF(
		MICROSECOND,
		chapter_revealed.event_time,
		chapter_resolved.event_time
	)/1000000),2)," secondes") AS `Maximal res. time`
FROM chapter_resolved
	RIGHT JOIN chapter_revealed
    ON chapter_resolved.game_uuid = chapter_revealed.game_uuid
		AND chapter_resolved.chapter_index = chapter_revealed.chapter_index
WHERE chapter_revealed.event_time BETWEEN "2023-02-03 12:00:00" AND "2023-02-03 15:30:00"
GROUP BY `Chapter name`
ORDER BY ROUND(AVG(TIMEDIFF(
			chapter_resolved.event_time,
			chapter_revealed.event_time
		)),2) DESC;