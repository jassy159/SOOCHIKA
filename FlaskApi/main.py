from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
import joblib
import numpy as np

# Initialize Flask app
app = Flask(_name_)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("key.json")  # Replace with your service account file
firebase_admin.initialize_app(cred)

# Initialize Firestore client
db = firestore.client()

# Load the pre-trained machine learning model
model = joblib.load('disaster_prediction_model.pkl')

# Root route to check if the server is running
@app.route('/')
def home():
    return "Disaster Prediction API is running!"

# POST route to add/update Flood Alert data in Firestore
@app.route('/sendFloodAlert/<locationIdDoc>', methods=['POST'])
def add_data(locationIdDoc):
    try:
        if not request.is_json:
            return jsonify({"error": "Request must be in JSON format"}), 415

        data = request.get_json()
        is_flood_alert = data.get('isFloodAlert', False)
        collection = 'FloodAlert'
        document_data = {'isFloodAlert': is_flood_alert}

        app.logger.info(f"Updating document {locationIdDoc} with data: {document_data}")
        db.collection(collection).document(locationIdDoc).set(document_data)

        return jsonify({"message": "Flood alert added successfully", "data": document_data}), 200
    except Exception as e:
        app.logger.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# POST route to add/update Landslide Alert data in Firestore
@app.route('/sendLandSlide/<locationIdDoc>', methods=['POST'])
def add_data_landslide(locationIdDoc):
    try:
        if not request.is_json:
            return jsonify({"error": "Request must be in JSON format"}), 415

        data = request.get_json()
        is_landslide_alert = data.get('isLandSlideAlert', False)
        collection = 'LandSlideAlert'
        document_data = {'isLandSlideAlert': is_landslide_alert}

        app.logger.info(f"Updating document {locationIdDoc} with data: {document_data}")
        db.collection(collection).document(locationIdDoc).set(document_data)

        return jsonify({"message": "Landslide alert added successfully", "data": document_data}), 200
    except Exception as e:
        app.logger.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# GET route to retrieve Flood Alert data from Firestore
@app.route('/getFloodAlert/<locationIdDoc>', methods=['GET'])
def get_flood_alert(locationIdDoc):
    try:
        doc_ref = db.collection('FloodAlert').document(locationIdDoc)
        doc = doc_ref.get()

        if doc.exists:
            return jsonify({"message": "Document found", "data": doc.to_dict()}), 200
        else:
            return jsonify({"message": "Document not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# GET route to retrieve Landslide Alert data from Firestore
@app.route('/getLandSlideAlert/<locationIdDoc>', methods=['GET'])
def get_landslide_alert(locationIdDoc):
    try:
        doc_ref = db.collection('LandSlideAlert').document(locationIdDoc)
        doc = doc_ref.get()

        if doc.exists:
            return jsonify({"message": "Document found", "data": doc.to_dict()}), 200
        else:
            return jsonify({"message": "Document not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# GET route for disaster prediction using ML model
@app.route('/landslidepredict', methods=['GET'])
def predict_get():
    try:
        soil_moisture = request.args.get('soil_moisture', type=float)
        rainfall = request.args.get('rainfall', type=float)

        if soil_moisture is None or rainfall is None:
            return jsonify({'error': 'Please provide both soil_moisture and rainfall values'}), 400

        input_data = np.array([[soil_moisture, rainfall]])
        prediction = model.predict(input_data)

        return jsonify({'prediction': int(prediction[0])}), 200
    except Exception as e:
        app.logger.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Run the Flask app
if _name_ == '_main_':
    app.run(host='0.0.0.0', port=5000, debug=True)