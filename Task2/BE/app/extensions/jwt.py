from flask_jwt_extended import JWTManager
from config import SECRET_KEY

def init_jwt(app):
    app.config['JWT_SECRET_KEY'] = SECRET_KEY
    jwt = JWTManager(app)
    return jwt
