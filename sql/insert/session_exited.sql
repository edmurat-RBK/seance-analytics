INSERT INTO session_exited(session_uuid)
VALUES (
    UUID_TO_BIN("{session_uuid}")
);