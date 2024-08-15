import os
from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USERNAME"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )

@app.route('/contact', methods=['POST'])
def contact():
    data = request.json
    connection = get_db_connection()
    cursor = connection.cursor()

    query = "INSERT INTO messages (name, subject, email, message) VALUES (%s, %s, %s, %s)"
    cursor.execute(query, (data['name'], data['subject'], data['email'], data['message']))

    connection.commit()
    cursor.close()
    connection.close()

    return jsonify({"status": "success"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
