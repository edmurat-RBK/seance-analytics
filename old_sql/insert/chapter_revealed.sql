INSERT INTO chapter_revealed(game_uuid,chapter_index,chapter_uuid)
VALUES (
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    (
        SELECT uuid
        FROM chapter
        WHERE name = "{chapterName}"
    )
);