INSERT INTO device_register(
    device_uuid,
    device_model,
    device_name,
    operating_system,
    graphics_name,
    graphics_version,
    graphics_memory,
    processor_type,
    processor_count,
    processor_frequency,
    memory_size
)
VALUES (
    UUID_TO_BIN("{deviceUuid}"),
    "{deviceModel}",
    "{deviceName}",
    "{operatingSystem}",
    "{graphicsName}",
    "{graphicsVersion}",
    {graphicsMemory},
    "{processorType}",
    {processorCount},
    {processorFrequency},
    {memorySize}
)
ON DUPLICATE KEY UPDATE
    device_model = "{deviceModel}",
    device_name = "{deviceName}",
    operating_system = "{operatingSystem}",
    graphics_name = "{graphicsName}",
    graphics_version = "{graphicsVersion}",
    graphics_memory = {graphicsMemory},
    processor_type = "{processorType}",
    processor_count = {processorCount},
    processor_frequency = {processorFrequency},
    memory_size = {memorySize},
    last_update = CURRENT_TIMESTAMP();