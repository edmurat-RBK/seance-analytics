INSERT INTO mouse_dragged(session_uuid, game_uuid, x_start_position, y_start_position, x_end_position, y_end_position, start_camera)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    {xStartPosition},
    {yStartPosition},
    {xEndPosition},
    {yEndPosition},
    {startCamera}
);