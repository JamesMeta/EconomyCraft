# app.py
from flask import Flask, request, Response
from flask_cors import CORS
import supabase

app = Flask(__name__)

@app.route('/')
def home():
    return 'Hello, Flask!'

@app.route('/')
def hello():
    return 'hello world'

# Debug GET route
@app.route('/proxy-test', methods=['GET'])
def debug_get():
    return f"GET request received", 200, {'Content-Type': 'text/plain'}

# Debug POST route
@app.route('/debug-post', methods=['POST'])
def debug_post():
    data = request
    return f"POST request received. Data: {data}", 200, {'Content-Type': 'text/plain'}

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    print(data)
    email = data.get('email')
    password = data.get('password')

    try:
        SUPABASE_URL = ""
        SUPABASE_SERVICE_ROLE_KEY = ""
        supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        
        response = supabase_client.auth.sign_in_with_password({
                    "email": email,
                    "password": password
                })

        user_id = response.user.id
    except:
        return {"error": "Invalid email or password"}, 401

    # return user_id or an error message
    if user_id:
        #return {"user_id": user_id}, 200
        return Response(user_id, mimetype='text/plain')
    else:
        return {"error": "Invalid email or password"}, 401

@app.route('/withdraw-1', methods=['POST'])
def withdraw_1():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(100, user_id)
    if response:
        return "Withdrawal of 1 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 1 failed", 400, {'Content-Type': 'text/plain'}
    

@app.route('/withdraw-5', methods=['POST'])
def withdraw_5():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(500, user_id)
    if response:
        return "Withdrawal of 5 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 5 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-10', methods=['POST'])
def withdraw_10():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(1000, user_id)
    if response:
        return "Withdrawal of 10 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 10 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-20', methods=['POST'])
def withdraw_20():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(2000, user_id)
    if response:
        return "Withdrawal of 20 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 20 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-32', methods=['POST'])
def withdraw_32():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(3200, user_id)
    if response:
        return "Withdrawal of 32 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 32 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/withdraw-64', methods=['POST'])
def withdraw_64():
    data = request.json
    user_id = data.get('user_id')
    response = withdraw(6400, user_id)
    if response:
        return "Withdrawal of 64 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Withdrawal of 64 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-1', methods=['POST'])
def deposit_1():
    data = request.json
    user_id = data.get('user_id')
    print(f"user_id is {user_id}")
    response = deposit(100, user_id)
    if response:
        return "Deposit of 1 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 1 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-5', methods=['POST'])
def deposit_5():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(500, user_id)
    if response:
        return "Deposit of 5 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 5 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-10', methods=['POST'])
def deposit_10():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(1000, user_id)
    if response:
        return "Deposit of 10 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 10 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-20', methods=['POST'])
def deposit_20():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(2000, user_id)
    if response:
        return "Deposit of 20 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 20 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-32', methods=['POST'])
def deposit_32():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(3200, user_id)
    if response:
        return "Deposit of 32 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 32 failed", 400, {'Content-Type': 'text/plain'}

@app.route('/deposit-64', methods=['POST'])
def deposit_64():
    data = request.json
    user_id = data.get('user_id')
    response = deposit(6400, user_id)
    if response:
        return "Deposit of 64 successful", 200, {'Content-Type': 'text/plain'}
    else:
        return "Deposit of 64 failed", 400, {'Content-Type': 'text/plain'}

def deposit(amount, user_id):
    SUPABASE_URL = "https://ylgfgklcypqtbqrkhsba.supabase.co"
    SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsZ2Zna2xjeXBxdGJxcmtoc2JhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NTcwMDg3NywiZXhwIjoyMDYxMjc2ODc3fQ.BSzOB85HmyQKmNwKMkRlF27CU7B9-Q-ER4nrWKxWPJo"
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f"Attempting to deposit {amount} for user ID {user_id}")
    response = supabase_client.table('users').select('money').eq('user_id', user_id).execute()
    print(f"Response data: {response.data}")
    if response.data:
        current_balance = response.data[0]['money']
        new_balance = current_balance + amount
        supabase_client.table('users').update({'money': new_balance}).eq('user_id', user_id).execute()
        return True
    else:
        return False
    pass

def withdraw(amount, user_id):
    SUPABASE_URL = "https://ylgfgklcypqtbqrkhsba.supabase.co"
    SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsZ2Zna2xjeXBxdGJxcmtoc2JhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NTcwMDg3NywiZXhwIjoyMDYxMjc2ODc3fQ.BSzOB85HmyQKmNwKMkRlF27CU7B9-Q-ER4nrWKxWPJo"
    supabase_client = supabase.create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    print(f"Attempting to withdraw {amount} for user ID {user_id}")
    response = supabase_client.table('users').select('money').eq('user_id', user_id).execute()
    if response.data:
        current_balance = response.data[0]['money']
        if current_balance >= amount:
            new_balance = current_balance - amount
            supabase_client.table('users').update({'money': new_balance}).eq('user_id', user_id).execute()
            return True
        else:
            return False
    else:
        return False
    pass

if __name__ == '__main__':
    app.run(debug=True)
    CORS(app)
