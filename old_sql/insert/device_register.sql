INSERT INTO device_register(
    device_id,
    device_model,
    device_name,
    operating_system,
    graphics_name,
    graphics_version,
    graphics_memory,
    processor_type,
    processor_count,
    processor_frequency,
    memory_size,
    screen_width,
    screen_height
)
VALUES (
    "{device_id}",
    "{device_model}",
    "{device_name}",
    "{operating_system}",
    "{graphics_name}",
    "{graphics_version}",
    {graphics_memory},
    "{processor_type}",
    {processor_count},
    {processor_frequency},
    {memory_size}
    {screen_width},
    {screen_height}
)
ON DUPLICATE KEY UPDATE
    device_model = "{device_model}",
    device_name = "{device_name}",
    operating_system = "{operating_system}",
    graphics_name = "{graphics_name}",
    graphics_version = "{graphics_version}",
    graphics_memory = {graphics_memory},
    processor_type = "{processor_type}",
    processor_count = {processor_count},
    processor_frequency = {processor_frequency},
    memory_size = {memory_size},
    screen_width = {screen_width},
    screen_height = {screen_height},
    last_update = CURRENT_TIMESTAMP();