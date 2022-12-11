INSERT INTO player_turn(session_uuid, game_uuid, chapter_index, turn_index)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex}
);