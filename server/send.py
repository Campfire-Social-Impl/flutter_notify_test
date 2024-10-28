import firebase_admin
from firebase_admin import credentials
from firebase_admin import messaging

cred = credentials.Certificate("server/firebase-adminsdk.json")
firebase_admin.initialize_app(cred)


message = messaging.Message(
    data={"score": "850", "time": "2:45"},
    topic="test",
)

response = messaging.send(message)
print("Successfully sent message:", response)
