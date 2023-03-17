INSERT INTO player_turn(session_uuid, game_uuid, chapter_index, turn_index, player_health, player_armor)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex},
    {playerHealth},
    {playerArmor}
);