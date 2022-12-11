INSERT INTO session_launched(session_uuid,dev_build)
VALUES (
    UUID_TO_BIN("{sessionUuid}"), 
    {devBuild}
);