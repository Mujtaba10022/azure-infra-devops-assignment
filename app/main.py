import os
from flask import Flask, render_template, request, jsonify
import pyodbc
import json

app = Flask(__name__)

# SQL Database Configuration
SQL_SERVER = os.getenv("SQL_SERVER", "sqlgmstaging2025.database.windows.net")
SQL_DATABASE = os.getenv("SQL_DATABASE", "customerdb")
SQL_USERNAME = os.getenv("SQL_USERNAME", "sqladmin")
SQL_PASSWORD = os.getenv("SQL_PASSWORD", "")

def get_db_connection():
    conn_str = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={SQL_DATABASE};"
        f"UID={SQL_USERNAME};"
        f"PWD={SQL_PASSWORD};"
        f"Encrypt=yes;"
        f"TrustServerCertificate=no;"
    )
    return pyodbc.connect(conn_str)

def execute_query(query):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        results = [dict(zip(columns, row)) for row in rows]
        conn.close()
        return results, None
    except Exception as e: 
        return None, str(e)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy", "service": "SQL Agent Portal"})

@app.route("/api/customers")
def get_customers():
    results, error = execute_query("SELECT * FROM Customers")
    if error:
        return jsonify({"error": error}), 500
    return jsonify(results)

@app.route("/api/products")
def get_products():
    results, error = execute_query("SELECT * FROM Products")
    if error:
        return jsonify({"error": error}), 500
    return jsonify(results)

@app.route("/api/orders")
def get_orders():
    results, error = execute_query("SELECT * FROM Orders")
    if error:
        return jsonify({"error":  error}), 500
    return jsonify(results)

@app.route("/api/query", methods=["POST"])
def run_query():
    data = request.json
    query = data. get("query", "")
    if not query. upper().startswith("SELECT"):
        return jsonify({"error": "Only SELECT queries allowed"}), 400
    results, error = execute_query(query)
    if error:
        return jsonify({"error": error}), 500
    return jsonify({"results": results})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
