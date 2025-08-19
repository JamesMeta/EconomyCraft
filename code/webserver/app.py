from flask import Flask, send_from_directory
import os

app = Flask(__name__, static_folder='web', static_url_path='')

@app.route('/')
def index():
    return send_from_directory('web', 'index.html')

@app.route('/<path:path>')
def serve_file(path):
    # Security: prevent accessing files outside 'web'
    safe_path = os.path.join('web', path)
    if os.path.isfile(safe_path):
        return send_from_directory('web', path)
    else:
        return send_from_directory('web', 'index.html'), 404

# Only needed for local development
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)



# testing the auto deploy on new commit