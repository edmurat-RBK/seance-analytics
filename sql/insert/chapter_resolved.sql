INSERT INTO chapter_resolved(game_uuid,chapter_index)
VALUES (
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex}
);