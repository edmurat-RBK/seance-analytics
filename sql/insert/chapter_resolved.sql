INSERT INTO chapter_resolved(game_uuid,chapter_uuid)
VALUES (
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex}
);