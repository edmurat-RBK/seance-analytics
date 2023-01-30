INSERT INTO reward_picked(session_uuid, game_uuid, chapter_index, card_uuid)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    (
        SELECT uuid
        FROM card
        WHERE name = "{cardName}"
    )
);