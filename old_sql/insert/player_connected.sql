INSERT INTO player_connected(session_uuid, game_uuid, character_class)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    "{characterClass}"
);