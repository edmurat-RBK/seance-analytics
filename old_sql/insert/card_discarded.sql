INSERT INTO card_discarded(session_uuid, game_uuid, chapter_index, turn_index, card_index, card_uuid)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex},
    {cardIndex},
    (
        SELECT uuid
        FROM card
        WHERE name = "{cardName}"
    )
);