INSERT INTO session_launched(session_uuid,device_id,dev_build)
VALUES (
    UUID_TO_BIN("{sessionUuid}"), 
    "{deviceId}", 
    {devBuild}
);