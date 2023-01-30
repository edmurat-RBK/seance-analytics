INSERT INTO mouse_clicked(session_uuid, game_uuid, x_position, y_position, camera)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {xPosition},
    {yPosition},
    "{camera}"
);