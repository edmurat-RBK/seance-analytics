SELECT
    chapter_revealed.chapter_name AS `Chapter name`,
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
FROM (
	SELECT *
    FROM game_event
    WHERE event_name = "chapter_resolve"
		AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
	) AS chapter_resolved
RIGHT JOIN (
	SELECT *
    FROM game_event
    WHERE event_name = "chapter_reveal"
		AND event_time BETWEEN "2023-03-21 14:30:00" AND "2023-03-21 19:00:00"
	) AS chapter_revealed
    ON chapter_resolved.game_uuid = chapter_revealed.game_uuid
		AND chapter_resolved.chapter_name = chapter_revealed.chapter_name
GROUP BY `Chapter name`
ORDER BY ROUND(AVG(TIMEDIFF(
			chapter_resolved.event_time,
			chapter_revealed.event_time
		)),2) DESC;