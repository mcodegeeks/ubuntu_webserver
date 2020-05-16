from flask import Flask, jsonify

def create_app(script_info=None):
    app = Flask(__name__)

    @app.route("/")
    def index():
        return jsonify(hello="world")

    return app
