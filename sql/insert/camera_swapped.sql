INSERT INTO camera_swapped(session_uuid, game_uuid, start_camera, end_camera)
VALUES (
    UUID_TO_BIN("{sessionUuid}"),
    UUID_TO_BIN("{gameUuid}"),
    "{startCamera}",
    "{endCamera}"
);