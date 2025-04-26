from flask import Flask, render_template, send_from_directory

# Configure Flask to use /web for static files
app = Flask(__name__, static_folder='web', static_url_path='')

@app.route('/')
def index():
    # Serve index.html from the /web folder
    return send_from_directory('web', 'index.html')

# Catch-all route to serve other files from /web
@app.route('/<path:path>')
def serve_file(path):
    return send_from_directory('web', path)

if __name__ == '__main__':
    app.run(debug=True)