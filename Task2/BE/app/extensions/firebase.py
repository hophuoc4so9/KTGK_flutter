import firebase_admin
from firebase_admin import credentials, firestore
from config import FIREBASE_CREDENTIALS

def init_firebase(app=None):
    cred = credentials.Certificate(FIREBASE_CREDENTIALS)
    firebase_admin.initialize_app(cred)
    app.db = firestore.client()
