from flask import Flask, jsonify

from disease.app import bp as disease_bp
from Decision_support.app import bp as decision_support_bp
from crop_reccomend.app import bp as crop_recommendation_bp
from Iot.app import bp as iot_bp


app = Flask(__name__)

# Add CORS headers for preflight OPTIONS and cross-origin POST requests
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Requested-With')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

app.register_blueprint(disease_bp, url_prefix="/disease")
app.register_blueprint(decision_support_bp, url_prefix="/decision-support")
app.register_blueprint(crop_recommendation_bp, url_prefix="/crop-recommendation")
app.register_blueprint(iot_bp, url_prefix="/iot")


@app.route("/")
def home():
    return jsonify({
        "message": "Integrated Paddy Flask API is running",
        "routes": {
            "disease": "/disease/predict",
            "decision_support": "/decision-support/predict",
            "crop_recommendation": "/crop-recommendation/predict",
            "iot": "/iot/predict"
        }
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
