import configparser
from flask import Flask, jsonify
from flask_mysqldb import MySQL
import os


config = configparser.ConfigParser()
config.read("config.ini")

app = Flask(__name__)
app.config['MYSQL_HOST'] = os.getenv("DATABASE_HOST")
app.config['MYSQL_PORT'] = os.getenv("DATABASE_PORT")
app.config['MYSQL_USER'] = os.getenv("DATABASE_USER")
app.config['MYSQL_PASSWORD'] = os.getenv("DATABASE_PASSWORD")
app.config['MYSQL_DB'] = os.getenv("DATABASE_SCHEMA")

database = MySQL(app)


@app.route('/api/v1/', methods=['GET'])
def home():
    return "Seance Analytics API"

@app.route('/api/v1/fetch/action', methods=['GET'])
def fetch_action_card():
    with database.connection.cursor() as cursor:
        cursor.execute(read_query_from("sql/select/card.sql"))
        result = cursor.fetchall()
        return jsonify(result)
    
@app.route('/api/v1/fetch/chapter', methods=['GET'])
def fetch_chapter_card():
    with database.connection.cursor() as cursor:
        cursor.execute(read_query_from("sql/select/chapter.sql"))
        result = cursor.fetchall()
        return jsonify(result)





def read_query_from(path, kwargs = {}):
    query = ""
    with open(path,"r") as file:
        query = file.read()
        query.format(**kwargs)
    return query


if __name__ == "__main__":
    app.run(debug=True)
