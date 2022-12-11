INSERT INTO player_cheated(session_uuid, game_uuid, chapter_index, turn_index, c)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex},
    "{cheatType}"
);