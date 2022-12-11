INSERT INTO chapter_revealed(game_uuid,chapter_index,chapter_uuid)
VALUES (
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    UUID_TO_BIN("{chapterUuid}")
);