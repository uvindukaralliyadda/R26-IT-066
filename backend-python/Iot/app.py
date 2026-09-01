from flask import Flask, Blueprint, request, jsonify
import joblib
import pandas as pd
from pathlib import Path

base_dir = Path(__file__).resolve().parent
bp = Blueprint("iot", __name__)

# 🔹 Load models
rf = joblib.load(base_dir / "rf_classifier.pkl")
xgb_reg = joblib.load(base_dir / "xgb_regressor.pkl")

# 🔹 Load encoders
le_stage = joblib.load(base_dir / "le_stage.pkl")
le_variety = joblib.load(base_dir / "le_variety.pkl")


@bp.route("/")
def home():
    return jsonify({
        "message": "Paddy IoT Fertilizer API is running"
    })


@bp.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json

        # Convert input to DataFrame
        sample = pd.DataFrame([{
            "soil_moisture": data["soil_moisture"],
            "soil_temp": data["soil_temp"],
            "soil_ph": data["soil_ph"],
            "nitrogen": data["nitrogen"],
            "phosphorus": data["phosphorus"],
            "potassium": data["potassium"],
            "humidity": data["humidity"],
            "growth_stage": data["growth_stage"],
            "rice_variety": data["rice_variety"]
        }])

        # Encode categorical values
        sample["growth_stage"] = le_stage.transform(sample["growth_stage"])
        sample["rice_variety"] = le_variety.transform(sample["rice_variety"])

        # 🔹 Classification
        need = rf.predict(sample)[0]

        if need == 1:
            amount = xgb_reg.predict(sample)[0]

            response = {
                "fertilizer_needed": True,
                "recommended_amount": round(float(amount), 2),
                "unit": "kg/ha"
            }
        else:
            response = {
                "fertilizer_needed": False,
                "recommended_amount": 0,
                "unit": "kg/ha"
            }

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": str(e)})


if __name__ == "__main__":
    app = Flask(__name__)
    app.register_blueprint(bp)
    app.run(debug=True)