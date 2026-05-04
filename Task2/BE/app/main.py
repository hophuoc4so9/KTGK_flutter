from flask import Flask
from extensions.firebase import init_firebase

app = Flask(__name__)
init_firebase(app)

if __name__ == "__main__":
    app.run(debug=True)
