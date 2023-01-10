INSERT INTO card_drew(session_uuid, game_uuid, chapter_index, turn_index, card_index, card_uuid)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {chapterIndex},
    {turnIndex},
    {cardIndex},
    (
        SELECT card_uuid
        FROM card
        WHERE card_name = "{cardName}"
    )
);