from flask import Flask, Response, request
from flask_mysqldb import MySQL


dev_mode = False

app = Flask(__name__)

if dev_mode:
    import configparser
    
    config = configparser.ConfigParser()
    config.read("config.ini")

    app.config['MYSQL_HOST'] = config["MySQL"]["host"]
    app.config['MYSQL_PORT'] = config["MySQL"].getint("port",3306)
    app.config['MYSQL_USER'] = config["MySQL"]["user"]
    app.config['MYSQL_PASSWORD'] = config["MySQL"]["password"]
    app.config['MYSQL_DB'] = config["MySQL"]["schema"]
else :
    import os
    
    app.config['MYSQL_HOST'] = os.getenv("DATABASE_HOST")
    app.config['MYSQL_PORT'] = int(os.getenv("DATABASE_PORT"))
    app.config['MYSQL_USER'] = os.getenv("DATABASE_USER")
    app.config['MYSQL_PASSWORD'] = os.getenv("DATABASE_PASSWORD")
    app.config['MYSQL_DB'] = os.getenv("DATABASE_SCHEMA")
    
database = MySQL(app)


def read_query_from_file(path, kwargs = {}):
    query = ""
    with open(path,"r") as file:
        query = file.read()
        query = query.format(**kwargs)
    return query


def select_event():
    with database.connection.cursor() as cursor:
        query = f"""
            SELECT
                event_name AS `Event name`,
                BIN_TO_UUID(event_uuid) AS `Event UUID`,
                event_time AS `Event time`,
                game_time AS `Session time`,
                BIN_TO_UUID(user_uuid) AS `User UUID`,
                device_id AS `Device ID`,
                game_version AS `Game version`,
                dev_build AS `Dev build`,
                ip AS `IP`,
                port AS `Port`,
                username AS `Username`,
                BIN_TO_UUID(game_uuid) AS `Game UUID`,
                chapter_name AS `Chapter name`,
                card_name AS `Card name`,
                card_modifier AS `Card modifier`,
                effect_id AS `Effect ID`,
                player_class AS `Player class`,
                health_value AS `Health value`,
                armor_value AS `Armor value`,
                action_count AS `Action count`,
                action_used AS `Action used`,
                initial_health_value AS `Initial health value`,
                initial_armor_value AS `Initial armor value`,
                initial_card_amount AS `Initial card amount`,
                cheat_type AS `Cheat type`
            FROM game_event
            WHERE event_time >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
            ORDER BY event_time DESC;
        """
        cursor.execute(query)
        table = cursor.fetchall()
        str_output = "; ".join([s[0] for s in cursor.description]) + "\n"
        for line in table:
            str_output += "; ".join([str(v) for v in line]) + "\n"
        return str_output


def insert_device(data):
    with database.connection.cursor() as cursor:
        values = {
            "device_id": data["device_id"],
            "device_model": data["device_model"],
            "device_name": data["device_name"],
            "operating_system": data["operating_system"],
            "graphics_name": data["graphics_name"],
            "graphics_version": data["graphics_version"],
            "graphics_memory": data["graphics_memory"],
            "processor_type": data["processor_type"],
            "processor_count": data["processor_count"],
            "processor_frequency": data["processor_frequency"],
            "memory_size": data["memory_size"],
            "screen_width": data["screen_width"],
            "screen_height": data["screen_height"],
        }
        query = read_query_from_file("sql/device_register.sql",values)
        cursor.execute(query)
        database.connection.commit()


def insert_event(event,data):
    parameters = "event_name, "
    values = f"\"{event}\", "
    
    if "event_time" in data:
        parameters += "event_time, "
        values += f"STR_TO_DATE(\"{data['event_time']}\",\"%Y-%m-%d %H:%i:%S.%f\"), "
        
    if "game_time" in data:
        parameters += "game_time, "
        values += f"\"{data['game_time']}\", "
    
    if "user_uuid" in data:
        parameters += "user_uuid, "
        values += f"UUID_TO_BIN(\"{data['user_uuid']}\"), "
        
    if "device_id" in data:
        parameters += "device_id, "
        values += f"\"{data['device_id']}\", "
    
    if "game_version" in data:
        parameters += "game_version, "
        values += f"\"{data['game_version']}\", "
    
    if "dev_build" in data:
        parameters += "dev_build, "
        values += f"{data['dev_build']}, "
        
    if "ip" in data:
        parameters += "ip, "
        values += f"\"{data['ip']}\", "
        
    if "port" in data:
        parameters += "port, "
        values += f"\"{data['port']}\", "
       
    if "username" in data:
        parameters += "username, "
        values += f"\"{data['username']}\", "
        
    if "game_uuid" in data:
        parameters += "game_uuid, "
        values += f"UUID_TO_BIN(\"{data['game_uuid']}\"), "
        
    if "chapter_name" in data:
        parameters += "chapter_name, "
        values += f"\"{data['chapter_name']}\", "
        
    if "card_name" in data:
        parameters += "card_name, "
        values += f"\"{data['card_name']}\", "
        
    if "card_modifier" in data:
        parameters += "card_modifier, "
        values += f"{data['card_modifier']}, "
        
    if "effect_id" in data:
        parameters += "effect_id, "
        values += f"{data['effect_id']}, "    
    
    if "player_class" in data:
        parameters += "player_class, "
        values += f"\"{data['player_class']}\", "
    
    if "health_value" in data:
        parameters += "health_value, "
        values += f"{data['health_value']}, "
    
    if "armor_value" in data:
        parameters += "armor_value, "
        values += f"{data['armor_value']}, "
        
    if "action_count" in data:
        parameters += "action_count, "
        values += f"{data['action_count']}, "
        
    if "action_used" in data:
        parameters += "action_used, "
        values += f"{data['action_used']}, "
    
    if "initial_health_value" in data:
        parameters += "initial_health_value, "
        values += f"{data['initial_health_value']}, "
        
    if "initial_armor_value" in data:
        parameters += "initial_armor_value, "
        values += f"{data['initial_armor_value']}, "
        
    if "initial_card_amount" in data:
        parameters += "initial_card_amount, "
        values += f"{data['initial_card_amount']}, "
    
    if "cheat_type" in data:
        parameters += "cheat_type, "
        values += f"\"{data['cheat_type']}\", "
    
    with database.connection.cursor() as cursor:
        query = f"INSERT INTO game_event({parameters[:-2]}) VALUES ({values[:-2]});"
        print(query)
        cursor.execute(query)
        database.connection.commit()


@app.route('/<version>', methods=['GET','POST'])
def home(version):
    if request.method == "GET":
        if version == "v1":
            return "Seance Analytics API v1"
        else:
            return "Unknown version"
    elif request.method == "POST":
        if version == "v1":
            return "Seance Analytics API v1"
        else:
            return "Unknown version"


@app.route('/<version>/register/device', methods=['POST'])
def endpoint_register_device(version):
    if request.method == "POST":
        if version == "v1":
            insert_device(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"


@app.route('/<version>/event/<event>', methods=['POST'])
def endpoint_register_event(version,event):
    if request.method == "POST":
        if version == "v1":
            insert_event(event, request.form)
            return "Insertion complete"
        else:
            return "Unknown version"


@app.route('/<version>/event', methods=['GET'])
def endpoint_get_events(version):
    if request.method == "GET":
        if version == "v1":
            return Response(select_event(), mimetype='text/csv')
        else:
            return "Unknown version"


@app.route('/<version>/event/display', methods=['GET'])
def endpoint_get_events_display(version):
    if request.method == "GET":
        if version == "v1":
            return Response(select_event(), mimetype='application/json')
        else:
            return "Unknown version"


if __name__ == "__main__":
    app.run(debug=True)
