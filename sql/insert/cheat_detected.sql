INSERT INTO cheat_detected(session_uuid, game_uuid, chapter_index, turn_index, cheat_type)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex},
    IF(
        "{cheatType}"="Noone",
        NULL,
        "{cheatType}"
    )
);