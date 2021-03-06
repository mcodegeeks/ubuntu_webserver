### Create a virtual environment
```
$ python3 -m venv venv
```

### Activate the virtual environment
```
$ source venv/bin/activate
```

### Install flask framework
```
* Note: regardless of which version of Python you are using, when the virtual environment is activated, you should use the pip command (not pip3).
(venv) $ pip install flask
```

### Create a sample app (app.py)
```
from flask import Flask, jsonify

def create_app(script_info=None):
    app = Flask(__name__)

    @app.route("/")
    def index():
        return jsonify(hello="world")

    return app
```

### Creating the Web Server Gateway Interface (WSGI) Entry Point (wsgi.py)
```
from app import create_app

app = create_app()
if __name__ == "__main__":
    app.run()
```

### Run the flask app
```
(venv) $ flask run 
```

### Navigate to http://localhost:5000/. You should see:
```
{"hello":"world"}
```
