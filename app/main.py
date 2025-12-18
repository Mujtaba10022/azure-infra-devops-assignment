import os
from flask import Flask, request, jsonify

app = Flask(__name__)

SQL_SERVER = os.getenv("SQL_SERVER", "sqlgmstaging2025.database.windows. net")
SQL_DATABASE = os.getenv("SQL_DATABASE", "customerdb")
SQL_USERNAME = os.getenv("SQL_USERNAME", "sqladmin")
SQL_PASSWORD = os. getenv("SQL_PASSWORD", "")

AZURE_OPENAI_KEY = os.getenv("AZURE_OPENAI_KEY", "")
AZURE_OPENAI_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT", "")
AZURE_OPENAI_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-4o-mini")

def get_openai_client():
    if not AZURE_OPENAI_KEY: 
        return None
    try:
        from openai import AzureOpenAI
        return AzureOpenAI(api_key=AZURE_OPENAI_KEY, api_version="2024-02-15-preview", azure_endpoint=AZURE_OPENAI_ENDPOINT)
    except: 
        return None

def get_db_connection():
    import pyodbc
    conn_str = f"DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={SQL_SERVER};DATABASE={SQL_DATABASE};UID={SQL_USERNAME};PWD={SQL_PASSWORD};Encrypt=yes;TrustServerCertificate=no;"
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

def natural_language_to_sql(question):
    client = get_openai_client()
    if not client: 
        return None, "Azure OpenAI not configured"
    
    prompt = """You are an expert SQL analyst and database engineer with 20 years of experience. 
Your job is to convert natural language questions into precise, optimized SQL queries. 

## RESPONSE FORMAT: 
- Return ONLY the raw SQL query
- No explanations, no comments, no markdown code blocks
- No ```sql or ``` tags
- Just pure executable SQL

Convert this question to SQL: """

    try:
        response = client.chat.completions.create(
            model=AZURE_OPENAI_DEPLOYMENT,
            messages=[
                {"role":  "system", "content": prompt},
                {"role": "user", "content": question}
            ],
            max_tokens=500,
            temperature=0
        )
        sql = response. choices[0].message.content. strip()
        if sql. startswith("```sql"):
            sql = sql[6:]
        if sql.startswith("```"):
            sql = sql[3:]
        if sql.endswith("```"):
            sql = sql[:-3]
        return sql. strip(), None
    except Exception as e: 
        return None, str(e)

@app.route("/")
def home():
    return '''<! DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI SQL Agent | By Ghulam Mujtaba</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container { max-width: 1000px; margin: 0 auto; }
        .header {
            text-align: center;
            padding: 40px 20px;
            color: white;
        }
        .header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        .header p { font-size: 1.1rem; opacity: 0.9; }
        . status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.2);
            padding:  8px 16px;
            border-radius: 50px;
            margin-top: 15px;
            backdrop-filter: blur(10px);
        }
        .status-dot {
            width:  10px;
            height: 10px;
            background: #4ade80;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .main-card {
            background:  white;
            border-radius: 24px;
            padding: 40px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
        }
        .search-section { margin-bottom: 30px; }
        .search-label {
            display: block;
            font-weight: 600;
            color:  #374151;
            margin-bottom: 12px;
            font-size: 0.95rem;
        }
        .search-box { display: flex; gap:  12px; flex-wrap: wrap; }
        .search-input {
            flex:  1;
            min-width: 280px;
            padding: 16px 20px;
            font-size: 1rem;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            outline: none;
            transition: all 0.3s ease;
        }
        .search-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102,126,234,0.1);
        }
        .search-btn {
            padding:  16px 32px;
            font-size: 1rem;
            font-weight: 600;
            color: white;
            background:  linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border:  none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap:  8px;
        }
        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102,126,234,0.4);
        }
        .search-btn:active { transform: translateY(0); }
        .quick-actions {
            display:  flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 15px;
        }
        .quick-btn {
            padding:  8px 16px;
            font-size: 0.85rem;
            color: #667eea;
            background:  #f0f1ff;
            border:  none;
            border-radius: 8px;
            cursor:  pointer;
            transition: all 0.2s ease;
        }
        .quick-btn:hover { background: #667eea; color: white; }
        .result-section { margin-top: 30px; }
        . result-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom:  15px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .result-title { font-weight: 600; color: #374151; }
        .sql-badge {
            font-size: 0.7rem;
            padding: 6px 12px;
            background: #fef3c7;
            color: #92400e;
            border-radius: 6px;
            font-family: monospace;
            max-width: 600px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .result-box {
            background: #f8fafc;
            border:  1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            max-height: 400px;
            overflow:  auto;
        }
        .result-table { width: 100%; border-collapse: collapse; }
        .result-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 0.85rem;
            position: sticky;
            top: 0;
        }
        .result-table td {
            padding:  12px 15px;
            border-bottom: 1px solid #e2e8f0;
            font-size: 0.9rem;
        }
        .result-table tr:hover { background: #f1f5f9; }
        .result-count {
            margin-top: 15px;
            padding:  10px 15px;
            background: #ecfdf5;
            color: #065f46;
            border-radius: 8px;
            font-size: 0.85rem;
            display: inline-block;
        }
        .loading { text-align: center; padding: 40px; color: #667eea; }
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #e5e7eb;
            border-top-color: #667eea;
            border-radius: 50%;
            animation:  spin 1s linear infinite;
            margin: 0 auto 15px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .api-links {
            display:  flex;
            justify-content: center;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            flex-wrap: wrap;
        }
        .api-link {
            padding: 10px 20px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            border-radius: 8px;
            transition: all 0.2s ease;
            background: #f8fafc;
        }
        .api-link:hover { background: #667eea; color:  white; }
        .footer {
            text-align: center;
            padding: 30px;
            color: rgba(255,255,255,0.9);
            font-size: 0.9rem;
        }
        . footer a { color: white; text-decoration:  none; font-weight: 600; }
        . error-box {
            background:  #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 15px 20px;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 AI SQL Agent</h1>
            <p>Transform natural language into powerful SQL queries</p>
            <div class="status-badge">
                <span class="status-dot"></span>
                <span>GPT-4o-mini Connected | Azure SQL Active</span>
            </div>
        </div>
        <div class="main-card">
            <div class="search-section">
                <label class="search-label">🔍 Ask anything about your data: </label>
                <div class="search-box">
                    <input type="text" id="question" class="search-input" placeholder="e.g., Show me top 5 customers by spending">
                    <button onclick="askQuestion()" class="search-btn">
                        <svg width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                        </svg>
                        Ask AI
                    </button>
                </div>
                <div class="quick-actions">
                    <button class="quick-btn" onclick="setQuestion('mujtaba')">🔍 Mujtaba</button>
                    <button class="quick-btn" onclick="setQuestion('Show all customers')">👥 All Customers</button>
                    <button class="quick-btn" onclick="setQuestion('List all products')">📦 All Products</button>
                    <button class="quick-btn" onclick="setQuestion('Show recent orders')">🛒 Recent Orders</button>
                    <button class="quick-btn" onclick="setQuestion('Total revenue')">💰 Total Revenue</button>
                    <button class="quick-btn" onclick="setQuestion('Top 5 customers by spending')">🏆 Top Customers</button>
                    <button class="quick-btn" onclick="setQuestion('Products low in stock')">📉 Low Stock</button>
                    <button class="quick-btn" onclick="setQuestion('Average order value')">📊 Avg Order</button>
                </div>
            </div>
            <div class="result-section" id="resultSection" style="display: none;">
                <div class="result-header">
                    <span class="result-title">📊 Results</span>
                    <span class="sql-badge" id="sqlQuery" title="Generated SQL Query"></span>
                </div>
                <div class="result-box">
                    <div id="resultContent"></div>
                </div>
            </div>
            <div class="api-links">
                <a href="/api/health" class="api-link">💚 Health</a>
                <a href="/api/customers" class="api-link">👥 Customers API</a>
                <a href="/api/products" class="api-link">📦 Products API</a>
                <a href="/api/orders" class="api-link">🛒 Orders API</a>
            </div>
        </div>
        <div class="footer">
            Powered by <a href="#">Ghulam Mujtaba</a> | Azure OpenAI + Azure SQL | Built with 🧠
        </div>
    </div>
    <script>
        function setQuestion(q) {
            document.getElementById('question').value = q;
            askQuestion();
        }
        async function askQuestion() {
            const question = document.getElementById('question').value;
            if (!question) return;
            const resultSection = document.getElementById('resultSection');
            const resultContent = document. getElementById('resultContent');
            const sqlQuery = document. getElementById('sqlQuery');
            resultSection.style.display = 'block';
            resultContent. innerHTML = '<div class="loading"><div class="loading-spinner"></div>🤖 AI is analyzing your question...</div>';
            sqlQuery.textContent = '';
            try {
                const response = await fetch('/api/ask', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON. stringify({ question: question })
                });
                const data = await response.json();
                if (data. error) {
                    resultContent.innerHTML = '<div class="error-box">❌ Error: ' + data.error + '</div>';
                    return;
                }
                sqlQuery.textContent = 'SQL:  ' + (data.sql || '');
                sqlQuery.title = data.sql || '';
                if (data.results && data.results.length > 0) {
                    const keys = Object.keys(data.results[0]);
                    let tableHtml = '<table class="result-table"><thead><tr>';
                    keys. forEach(key => { tableHtml += '<th>' + key + '</th>'; });
                    tableHtml += '</tr></thead><tbody>';
                    data.results.forEach(row => {
                        tableHtml += '<tr>';
                        keys.forEach(key => {
                            let value = row[key];
                            if (value === null) value = '-';
                            if (typeof value === 'number' && key. toLowerCase().includes('amount') || key.toLowerCase().includes('price') || key.toLowerCase().includes('spent') || key.toLowerCase().includes('revenue')) {
                                value = '$' + parseFloat(value).toFixed(2);
                            }
                            tableHtml += '<td>' + value + '</td>';
                        });
                        tableHtml += '</tr>';
                    });
                    tableHtml += '</tbody></table>';
                    tableHtml += '<div class="result-count">✅ Found ' + data.count + ' result(s)</div>';
                    resultContent.innerHTML = tableHtml;
                } else {
                    resultContent.innerHTML = '<div style="text-align: center;padding:30px;color:#64748b;">😕 No results found.  Try a different query! </div>';
                }
            } catch (error) {
                resultContent.innerHTML = '<div class="error-box">❌ Error: ' + error.message + '</div>';
            }
        }
        document.getElementById('question').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') askQuestion();
        });
    </script>
</body>
</html>'''

@app.route("/api/health")
def health():
    client = get_openai_client()
    return jsonify({
        "status":  "healthy",
        "ai_status": "connected" if client else "not configured",
        "model":  AZURE_OPENAI_DEPLOYMENT if client else None,
        "database": SQL_DATABASE,
        "server": SQL_SERVER
    })

@app.route("/api/customers")
def get_customers():
    results, error = execute_query("SELECT * FROM Customers")
    return jsonify({"error": error}) if error else jsonify(results)

@app.route("/api/products")
def get_products():
    results, error = execute_query("SELECT * FROM Products")
    return jsonify({"error": error}) if error else jsonify(results)

@app.route("/api/orders")
def get_orders():
    results, error = execute_query("SELECT * FROM Orders")
    return jsonify({"error": error}) if error else jsonify(results)

@app.route("/api/ask", methods=["POST"])
def ask_question():
    data = request.json
    question = data. get("question", "")
    if not question:
        return jsonify({"error": "Please provide a question"}), 400
    
    sql_query, error = natural_language_to_sql(question)
    if error:
        return jsonify({"error": f"AI Error: {error}"}), 500
    
    if not sql_query. upper().strip().startswith("SELECT"):
        return jsonify({"error":  "Only SELECT queries allowed", "sql": sql_query}), 400
    
    results, db_error = execute_query(sql_query)
    if db_error:
        return jsonify({"error": f"Database Error: {db_error}", "sql": sql_query}), 500
    
    return jsonify({
        "question": question,
        "sql": sql_query,
        "results": results,
        "count":  len(results)
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)