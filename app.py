from flask import Flask, jsonify, request
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
    app.config['MYSQL_PORT'] = os.getenv("DATABASE_PORT")
    app.config['MYSQL_USER'] = os.getenv("DATABASE_USER")
    app.config['MYSQL_PASSWORD'] = os.getenv("DATABASE_PASSWORD")
    app.config['MYSQL_DB'] = os.getenv("DATABASE_SCHEMA")
    

database = MySQL(app)

#region Routing

@app.route('/<version>', methods=['GET'])
def home(version):
    if request.method == "GET":
        if version == "v1":
            return "Seance Analytics API v1"
        else:
            return "Unknown version"

@app.route('/<version>/action', methods=['GET'])
def endpoint_card(version):
    if request.method == "GET":
        if version == "v1":
            return get_action()
        else:
            return "Unknown version"
    
@app.route('/<version>/chapter', methods=['GET'])
def endpoint_chapter(version):
    if request.method == "GET":
        if version == "v1":
            return get_chapter()
        else:
            return "Unknown version"

@app.route('/<version>/event/session_launched', methods=['POST'])
def endpoint_session_launched(version):
    if request.method == "POST":
        if version == "v1":
            insert_session_launched(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/session_exited', methods=['POST'])
def endpoint_session_exited(version):
    if request.method == "POST":
        if version == "v1":
            insert_session_exited(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/game_started', methods=['POST'])
def endpoint_game_started(version):
    if request.method == "POST":
        if version == "v1":
            insert_game_started(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/game_stopped', methods=['POST'])
def endpoint_game_stopped(version):
    if request.method == "POST":
        if version == "v1":
            insert_game_stopped(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/player_connected', methods=['POST'])
def endpoint_player_connected(version):
    if request.method == "POST":
        if version == "v1":
            insert_player_connected(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"
        
@app.route('/<version>/event/chapter_revealed', methods=['POST'])
def endpoint_chapter_revealed(version):
    if request.method == "POST":
        if version == "v1":
            insert_chapter_revealed(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"
        
@app.route('/<version>/event/chapter_resolved', methods=['POST'])
def endpoint_chapter_resolved(version):
    if request.method == "POST":
        if version == "v1":
            insert_chapter_resolved(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/player_turn', methods=['POST'])
def endpoint_player_turn(version):
    if request.method == "POST":
        if version == "v1":
            insert_player_turn(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/card_drew', methods=['POST'])
def endpoint_card_drew(version):
    if request.method == "POST":
        if version == "v1":
            insert_card_drew(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/card_played', methods=['POST'])
def endpoint_card_played(version):
    if request.method == "POST":
        if version == "v1":
            insert_card_played(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/card_discarded', methods=['POST'])
def endpoint_card_discarded(version):
    if request.method == "POST":
        if version == "v1":
            insert_card_discarded(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/player_death', methods=['POST'])
def endpoint_player_death(version):
    if request.method == "POST":
        if version == "v1":
            insert_player_death(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"

@app.route('/<version>/event/player_cheated', methods=['POST'])
def endpoint_player_cheated(version):
    if request.method == "POST":
        if version == "v1":
            insert_player_cheated(request.form)
            return "Insertion complete"
        else:
            return "Unknown version"



#endregion

def read_query_from_file(path, kwargs = {}):
    query = ""
    with open(path,"r") as file:
        query = file.read()
        query = query.format(**kwargs)
    return query

def get_action():
    with database.connection.cursor() as cursor:
        query = read_query_from_file("sql/select/card.sql")
        cursor.execute(query)
        result = cursor.fetchall()
        return jsonify(result)

def get_chapter():
    with database.connection.cursor() as cursor:
        query = read_query_from_file("sql/select/chapter.sql")
        cursor.execute(query)
        result = cursor.fetchall()
        return jsonify(result)
    
def insert_session_launched(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "devBuild": data["devBuild"]
        }
        query = read_query_from_file("sql/insert/session_launched.sql",values)
        cursor.execute(query)
        database.connection.commit()
        
def insert_session_exited(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"]
        }
        query = read_query_from_file("sql/insert/session_exited.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_game_started(data):
    with database.connection.cursor() as cursor:
        values = {
            "gameUuid": data["gameUuid"]
        }
        query = read_query_from_file("sql/insert/game_started.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_game_stopped(data):
    with database.connection.cursor() as cursor:
        values = {
            "gameUuid": data["gameUuid"]
        }
        query = read_query_from_file("sql/insert/game_stopped.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_player_connected(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "characterClass": data["characterClass"]
        }
        query = read_query_from_file("sql/insert/player_connected.sql",values)
        cursor.execute(query)
        database.connection.commit()
        
def insert_chapter_revealed(data):
    with database.connection.cursor() as cursor:
        values = {
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "chapterUuid": data["chapterUuid"]
        }
        query = read_query_from_file("sql/insert/chapter_revealed.sql",values)
        cursor.execute(query)
        database.connection.commit()
        
def insert_chapter_resolved(data):
    with database.connection.cursor() as cursor:
        values = {
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"]
        }
        query = read_query_from_file("sql/insert/chapter_resolved.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_player_turn(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"],
            "playerHealth": data["playerHealth"],
            "playerArmor": data["playerArmor"]
        }
        query = read_query_from_file("sql/insert/player_turn.sql",values)
        cursor.execute(query)
        database.connection.commit()
        
def insert_card_drew(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"],
            "cardIndex": data["cardIndex"],
            "cardUuid": data["cardUuid"]
        }
        query = read_query_from_file("sql/insert/card_drew.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_card_played(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"],
            "cardIndex": data["cardIndex"],
            "cardUuid": data["cardUuid"]
        }
        query = read_query_from_file("sql/insert/card_played.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_card_discarded(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"],
            "cardIndex": data["cardIndex"],
            "cardUuid": data["cardUuid"]
        }
        query = read_query_from_file("sql/insert/card_discarded.sql",values)
        cursor.execute(query)
        database.connection.commit()

def insert_player_death(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"]
        }
        query = read_query_from_file("sql/insert/player_death.sql",values)
        cursor.execute(query)
        database.connection.commit()
        
def insert_player_cheated(data):
    with database.connection.cursor() as cursor:
        values = {
            "sessionUuid": data["sessionUuid"],
            "gameUuid": data["gameUuid"],
            "chapterIndex": data["chapterIndex"],
            "turnIndex": data["turnIndex"],
            "cheatType": data["cheatType"]
        }
        query = read_query_from_file("sql/insert/player_cheated.sql",values)
        cursor.execute(query)
        database.connection.commit()



if __name__ == "__main__":
    app.run(debug=True)
