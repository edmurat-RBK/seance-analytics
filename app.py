from flask import Flask, request
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
        values += f"UNIX_TIMESTAMP(STR_TO_DATE(\"{data['event_time']}\",\"%d/%m/%Y %T\"), "
        
    if "game_time" in data:
        parameters += "game_time, "
        values += f"\"{data['game_time']}\", "
    
    if "user_uuid" in data:
        parameters += "user_uuid, "
        values += f"UUID_TO_BIN(\"{data['user_uuid']}\"), "
        
    if "device_id" in data:
        parameters += "device_id, "
        values += f"\"{data['device_id']}\", "
        
    if "dev_build" in data:
        parameters += "dev_build, "
        values += f"\"{data['dev_build']}\", "
        
    if "ip" in data:
        parameters += "ip, "
        values += f"\"{data['ip']}\", "
        
    if "port" in data:
        parameters += "port, "
        values += f"\"{data['port']}\", "
        
    if "game_uuid" in data:
        parameters += "game_uuid, "
        values += f"UUID_TO_BIN(\"{data['game_uuid']}\"), "
        
    if "chapter_name" in data:
        parameters += "chapter_name, "
        values += f"\"{data['chapter_name']}\", "
        
    if "card_name" in data:
        parameters += "card_name, "
        values += f"\"{data['card_name']}\", "
        
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
    
    if "cheat" in data:
        parameters += "cheat, "
        values += f"\"{data['cheat']}\", "
    
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



if __name__ == "__main__":
    app.run(debug=True)
