-- Drop all
DROP TABLE IF EXISTS mouse_dragged;
DROP TABLE IF EXISTS mouse_clicked;
DROP TABLE IF EXISTS camera_swapped;
DROP TABLE IF EXISTS cheat_detected;
DROP TABLE IF EXISTS player_cheated;
DROP TABLE IF EXISTS player_death;
DROP TABLE IF EXISTS reward_picked;
DROP TABLE IF EXISTS card_discarded;
DROP TABLE IF EXISTS card_played;
DROP TABLE IF EXISTS card_drew;
DROP TABLE IF EXISTS player_turn;
DROP TABLE IF EXISTS chapter_resolved;
DROP TABLE IF EXISTS chapter_revealed;
DROP TABLE IF EXISTS player_connected;
DROP TABLE IF EXISTS game_stopped;
DROP TABLE IF EXISTS game_started;
DROP TABLE IF EXISTS session_exited;
DROP TABLE IF EXISTS session_launched;
DROP TABLE IF EXISTS device_register;

DROP TABLE IF EXISTS card;
DROP TABLE IF EXISTS enemy;
DROP TABLE IF EXISTS chapter;


-- Static tables
CREATE TABLE IF NOT EXISTS chapter(
    uuid BINARY(16),
    name VARCHAR(128),
    description VARCHAR(512),
    type ENUM("Encounter","Event","Boss"),
    effect VARCHAR(256),
    act TINYINT UNSIGNED,
    CONSTRAINT PK_chapter PRIMARY KEY (uuid)
);

CREATE TABLE IF NOT EXISTS enemy(
    chapter BINARY(16),
    life TINYINT UNSIGNED,
    armor TINYINT UNSIGNED,
    strength TINYINT UNSIGNED,
    CONSTRAINT PK_enemy PRIMARY KEY (chapter),
    CONSTRAINT FK_enemy_chapter FOREIGN KEY (chapter) REFERENCES chapter(uuid)
);

CREATE TABLE IF NOT EXISTS card(
    uuid BINARY(16),
    name VARCHAR(128),
    description VARCHAR(256),
    category ENUM("Physical", "Intelligence", "Dexterity"),
    rarity ENUM("Common","Uncommon"),
    CONSTRAINT PK_card PRIMARY KEY (uuid)
);



-- Inserts
LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/action_card_list.csv"
INTO TABLE card
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(name, category, rarity, description)
SET uuid = UUID();

LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/chapter_card_list.csv"
INTO TABLE chapter
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(name, act, type, description, effect)
SET uuid = UUID();

LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/enemy_list.csv"
INTO TABLE enemy
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
(@name, @life, @armor, @strength)
SET chapter = (
        SELECT uuid
        FROM chapter
        WHERE name = @name
    ),
    life = @life,
    armor = @armor,
    strength = @strength;



-- Tables
CREATE TABLE IF NOT EXISTS device_register(
    device_id CHAR(40),
    device_model VARCHAR(128),
    device_name VARCHAR(128),
    operating_system VARCHAR(128),
    graphics_name VARCHAR(128),
    graphics_version VARCHAR(128),
    graphics_memory INT,
    processor_type VARCHAR(128),
    processor_count INT,
    processor_frequency INT,
    memory_size INT,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    notes VARCHAR(256),
    CONSTRAINT PK_device_register PRIMARY KEY (device_id)
);

CREATE TABLE IF NOT EXISTS session_launched(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    device_id CHAR(40),
    dev_build BOOL DEFAULT FALSE,
    CONSTRAINT PK_session_launched PRIMARY KEY (event_uuid),
    CONSTRAINT FK_session_launched_device_register FOREIGN KEY (device_id) REFERENCES device_register(device_id)
);

CREATE TABLE IF NOT EXISTS session_exited(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    CONSTRAINT PK_session_exited PRIMARY KEY (event_uuid),
    CONSTRAINT FK_session_exited_session_launched FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid)
);

CREATE TABLE IF NOT EXISTS game_started(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    game_uuid BINARY(16),
    CONSTRAINT PK_game_started PRIMARY KEY (event_uuid)
);

CREATE TABLE IF NOT EXISTS game_stopped(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    game_uuid BINARY(16),
    CONSTRAINT PK_game_stopped PRIMARY KEY (event_uuid),
    CONSTRAINT FK_game_stopped_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid)
);

CREATE TABLE IF NOT EXISTS player_connected(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    character_class ENUM("Warrior","Mage","Rogue"),
    CONSTRAINT PK_player_connected PRIMARY KEY (event_uuid),
    CONSTRAINT FK_player_connected_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid),
    CONSTRAINT FK_player_connected_session_launched FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid)
);

CREATE TABLE IF NOT EXISTS chapter_revealed(
    event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    chapter_uuid BINARY(16),
    CONSTRAINT PK_chapter_revealed PRIMARY KEY (event_uuid),
    CONSTRAINT FK_chapter_revealed_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid),
    CONSTRAINT FK_chapter_revealed_chapter FOREIGN KEY (chapter_uuid) REFERENCES chapter(chapter_uuid)
);

CREATE TABLE IF NOT EXISTS chapter_resolved(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    CONSTRAINT PK_chapter_resolved PRIMARY KEY (event_uuid),
    CONSTRAINT FK_chapter_resolved_chapter_revealed FOREIGN KEY (game_uuid, chapter_index) REFERENCES chapter_revealed(game_uuid, chapter_index)
);

CREATE TABLE IF NOT EXISTS player_turn(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    player_health TINYINT UNSIGNED,
    player_armor TINYINT UNSIGNED,
    CONSTRAINT PK_player_turn PRIMARY KEY (event_uuid),
    CONSTRAINT FK_player_turn_player_connected FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid),
    CONSTRAINT FK_player_turn_chapter_revealed FOREIGN KEY (game_uuid,chapter_index) REFERENCES chapter_revealed(game_uuid,chapter_index)
);

CREATE TABLE IF NOT EXISTS card_drew(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    card_uuid BINARY(16),
    CONSTRAINT PK_card_drew PRIMARY KEY (event_uuid),
    CONSTRAINT FK_card_drew_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_drew_card FOREIGN KEY (card_uuid) REFERENCES card(card_uuid)
);

CREATE TABLE IF NOT EXISTS card_played(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    card_uuid BINARY(16),
    CONSTRAINT PK_card_played PRIMARY KEY (event_uuid),
    CONSTRAINT FK_card_played_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_played_card_drew FOREIGN KEY (card_uuid) REFERENCES card_drew(card_uuid)
);

CREATE TABLE IF NOT EXISTS card_discarded(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    card_uuid BINARY(16),
    CONSTRAINT PK_card_discarded PRIMARY KEY (event_uuid),
    CONSTRAINT FK_card_discarded_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_discarded_card_drew FOREIGN KEY (card_uuid) REFERENCES card_drew(card_uuid)
);

CREATE TABLE IF NOT EXISTS reward_picked(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    card_uuid BINARY(16),
    CONSTRAINT PK_reward_picked PRIMARY KEY (event_uuid),
    CONSTRAINT FK_reward_picked_session_launched FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid),
    CONSTRAINT FK_reward_picked_chapter_revealed FOREIGN KEY (game_uuid, chapter_index) REFERENCES chapter_revealed(game_uuid, chapter_index),
    CONSTRAINT FK_reward_picked_card FOREIGN KEY (card_uuid) REFERENCES card(uuid)
);

CREATE TABLE IF NOT EXISTS player_death(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    CONSTRAINT PK_player_death PRIMARY KEY (event_uuid),
    CONSTRAINT FK_player_death_player_turn FOREIGN KEY (game_uuid, session_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index)
);

CREATE TABLE IF NOT EXISTS player_cheated(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    cheat_type ENUM("HideCard","GiveCard","ChangeDice"),
    CONSTRAINT PK_player_cheated PRIMARY KEY (event_uuid),
    CONSTRAINT FK_player_cheated_player_turn FOREIGN KEY (game_uuid, session_uuid, chapter_index, turn_index) REFERENCES player_turn(game_uuid, session_uuid, chapter_index, turn_index)
);

CREATE TABLE IF NOT EXISTS cheat_detected(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    cheat_type ENUM("HideCard","GiveCard","ChangeDice"),
    CONSTRAINT PK_cheat_detected PRIMARY KEY (event_uuid),
    CONSTRAINT FK_cheat_detected_player_turn FOREIGN KEY (game_uuid, session_uuid, chapter_index, turn_index) REFERENCES player_turn(game_uuid, session_uuid, chapter_index, turn_index)
);

CREATE TABLE IF NOT EXISTS camera_swapped(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
	session_uuid BINARY(16),
    game_uuid BINARY(16),
    start_camera ENUM("Wayfarer", "Table", "LeftSide", "RightSide", "LeftBelow", "RightBelow"),
    end_camera ENUM("Wayfarer", "Table", "LeftSide", "RightSide", "LeftBelow", "RightBelow"),
    CONSTRAINT PK_camera_swapped PRIMARY KEY (event_uuid),
    CONSTRAINT FK_camera_swapped_player_connected FOREIGN KEY (session_uuid, game_uuid) REFERENCES player_connected(session_uuid, game_uuid)
);

CREATE TABLE IF NOT EXISTS mouse_clicked(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
	session_uuid BINARY(16),
    game_uuid BINARY(16),
    x_position SMALLINT UNSIGNED,
    y_position SMALLINT UNSIGNED,
    camera ENUM("Wayfarer", "Table", "LeftSide", "RightSide", "LeftBelow", "RightBelow"),
    CONSTRAINT PK_mouse_clicked PRIMARY KEY (event_uuid),
    CONSTRAINT FK_mouse_clicked_player_connected FOREIGN KEY (session_uuid, game_uuid) REFERENCES player_connected(session_uuid, game_uuid)
);

CREATE TABLE IF NOT EXISTS mouse_dragged(
	event_uuid BINARY(16) DEFAULT (UUID_TO_BIN(UUID())),
	event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
	session_uuid BINARY(16),
    game_uuid BINARY(16),
    x_start_position SMALLINT UNSIGNED,
    y_start_position SMALLINT UNSIGNED,
    x_end_position SMALLINT UNSIGNED,
    y_end_position SMALLINT UNSIGNED,
    start_camera ENUM("Wayfarer", "Table", "LeftSide", "RightSide", "LeftBelow", "RightBelow"),
    CONSTRAINT PK_mouse_dragged PRIMARY KEY (event_uuid),
    CONSTRAINT FK_mouse_dragged_player_connected FOREIGN KEY (session_uuid,	game_uuid) REFERENCES player_connected(session_uuid, game_uuid)
);