-- Drop all
DROP TABLE IF EXISTS player_cheated;
DROP TABLE IF EXISTS player_death;
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
-- DROP TABLE IF EXISTS device_register;

DROP TABLE IF EXISTS card;
DROP TABLE IF EXISTS enemy;
DROP TABLE IF EXISTS chapter;


-- Static tables
CREATE TABLE IF NOT EXISTS chapter(
    chapter_uuid BINARY(16),
    chapter_name VARCHAR(128),
    chapter_description VARCHAR(512),
    chapter_type ENUM("Encounter","Event","Boss"),
    chapter_effect VARCHAR(256),
    chapter_act TINYINT UNSIGNED,
    CONSTRAINT PK_chapter PRIMARY KEY (chapter_uuid)
);

CREATE TABLE IF NOT EXISTS enemy(
    chapter_uuid BINARY(16),
    enemy_life TINYINT UNSIGNED,
    enemy_armor TINYINT UNSIGNED,
    enemy_strength TINYINT UNSIGNED,
    CONSTRAINT PK_enemy PRIMARY KEY (chapter_uuid),
    CONSTRAINT FK_enemy FOREIGN KEY (chapter_uuid) REFERENCES chapter(chapter_uuid)
);

CREATE TABLE IF NOT EXISTS card(
    card_uuid BINARY(16),
    card_name VARCHAR(128),
    card_description VARCHAR(256),
    category ENUM("Physical", "Intelligence", "Dexterity"),
    rarity ENUM("Common","Uncommon"),
    CONSTRAINT PK_card PRIMARY KEY (card_uuid)
);



-- Inserts
LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/action_card_list.csv"
INTO TABLE card
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(card_name, category, rarity, card_description)
SET card_uuid = UUID();

LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/chapter_card_list.csv"
INTO TABLE chapter
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(chapter_name, chapter_act, chapter_type, chapter_description, chapter_effect)
SET chapter_uuid = UUID();

LOAD DATA LOCAL INFILE "D:/edmurat/seance-analytics/static_data/enemy_list.csv"
INTO TABLE enemy
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
(@enemy_name, @enemy_life, @enemy_armor, @enemy_strength)
SET chapter_uuid = (
        SELECT chapter_uuid
        FROM chapter
        WHERE chapter_name = @enemy_name
    ),
    enemy_life = @enemy_life,
    enemy_armor = @enemy_armor,
    enemy_strength = @enemy_strength;



-- Tables
CREATE TABLE IF NOT EXISTS device_register(
    device_uuid BINARY(16),
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
    CONSTRAINT PK_device_register PRIMARY KEY (device_uuid)
);

CREATE TABLE IF NOT EXISTS session_launched(
    session_uuid BINARY(16),
    device_uuid BINARY(16),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    dev_build BOOL DEFAULT FALSE,
    CONSTRAINT PK_session_launched PRIMARY KEY (session_uuid),
    CONSTRAINT FK_session_launched_device_register FOREIGN KEY (device_uuid) REFERENCES device_register(device_uuid)
);

CREATE TABLE IF NOT EXISTS session_exited(
    session_uuid BINARY(16),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_application_exited PRIMARY KEY (session_uuid),
    CONSTRAINT FK_session_exited_session_launched FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid)
);

CREATE TABLE IF NOT EXISTS game_started(
    game_uuid BINARY(16),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_game_started PRIMARY KEY (game_uuid)
);

CREATE TABLE IF NOT EXISTS game_stopped(
    game_uuid BINARY(16),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_game_stopped PRIMARY KEY (game_uuid),
    CONSTRAINT FK_game_stopped_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid)
);

CREATE TABLE IF NOT EXISTS player_connected(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    character_class ENUM("Warrior","Mage","Rogue"),
    CONSTRAINT PK_player_connected PRIMARY KEY (session_uuid, game_uuid),
    CONSTRAINT FK_player_connected_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid),
    CONSTRAINT FK_player_connected_session_launched FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid)
);

CREATE TABLE IF NOT EXISTS chapter_revealed(
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    chapter_uuid BINARY(16),
    CONSTRAINT PK_chapter_revealed PRIMARY KEY (game_uuid, chapter_index),
    CONSTRAINT FK_chapter_revealed_game_started FOREIGN KEY (game_uuid) REFERENCES game_started(game_uuid),
    CONSTRAINT FK_chapter_revealed_chapter FOREIGN KEY (chapter_uuid) REFERENCES chapter(chapter_uuid)
);

CREATE TABLE IF NOT EXISTS chapter_resolved(
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_chapter_resolved PRIMARY KEY (game_uuid, chapter_index),
    CONSTRAINT FK_chapter_resolved_chapter_revealed FOREIGN KEY (game_uuid, chapter_index) REFERENCES chapter_revealed(game_uuid, chapter_index)
);

CREATE TABLE IF NOT EXISTS player_turn(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    player_health TINYINT UNSIGNED,
    player_armor TINYINT UNSIGNED,
    CONSTRAINT PK_player_turn PRIMARY KEY (session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_player_turn_player_connection FOREIGN KEY (session_uuid) REFERENCES session_launched(session_uuid),
    CONSTRAINT FK_player_turn_chapter_revealed FOREIGN KEY (game_uuid,chapter_index) REFERENCES chapter_revealed(game_uuid,chapter_index)
);

CREATE TABLE IF NOT EXISTS card_drew(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    card_uuid BINARY(16),
    CONSTRAINT PK_card_drew PRIMARY KEY (session_uuid, game_uuid, chapter_index, turn_index, card_index),
    CONSTRAINT FK_card_drew_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_drew_card FOREIGN KEY (card_uuid) REFERENCES card(card_uuid)
);

CREATE TABLE IF NOT EXISTS card_played(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    card_uuid BINARY(16),
    CONSTRAINT PK_card_played PRIMARY KEY (session_uuid, game_uuid, chapter_index, turn_index, card_index),
    CONSTRAINT FK_card_drew_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_played_card_drew FOREIGN KEY (card_uuid) REFERENCES card_drew(card_uuid)
);

CREATE TABLE IF NOT EXISTS card_discarded(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    card_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    card_uuid BINARY(16),
    CONSTRAINT PK_card_discarded PRIMARY KEY (game_uuid, session_uuid, chapter_index, turn_index, card_index),
    CONSTRAINT FK_card_drew_player_turn FOREIGN KEY (session_uuid, game_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index),
    CONSTRAINT FK_card_discarded_card_drew FOREIGN KEY (card_uuid) REFERENCES card_drew(card_uuid)
);

CREATE TABLE IF NOT EXISTS player_death(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_player_death PRIMARY KEY (game_uuid,session_uuid, chapter_index, turn_index),
    CONSTRAINT FK_player_death_player_turn FOREIGN KEY (game_uuid, session_uuid, chapter_index, turn_index) REFERENCES player_turn(session_uuid, game_uuid, chapter_index, turn_index)
);

CREATE TABLE IF NOT EXISTS player_cheated(
    session_uuid BINARY(16),
    game_uuid BINARY(16),
    chapter_index TINYINT UNSIGNED,
    turn_index TINYINT UNSIGNED,
    cheat_type ENUM("CardOnKnees","DiceRoll"),
    event_time TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT PK_player_cheat PRIMARY KEY (game_uuid, session_uuid, chapter_index, turn_index, cheat_type),
    CONSTRAINT FK_player_cheat_player_turn FOREIGN KEY (game_uuid, session_uuid, chapter_index, turn_index) REFERENCES player_turn(game_uuid, session_uuid, chapter_index, turn_index)
);