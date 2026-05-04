# Thay YOUR_FIREBASE_PROJECT_CREDENTIALS.json bằng file credentials của bạn
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('YOUR_FIREBASE_PROJECT_CREDENTIALS.json')
firebase_admin.initialize_app(cred)
db = firestore.client()
