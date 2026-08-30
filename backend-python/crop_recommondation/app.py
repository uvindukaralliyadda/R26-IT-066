from flask import Flask, Blueprint, request, jsonify
import joblib
import pandas as pd
from pathlib import Path

base_dir = Path(__file__).resolve().parent
bp = Blueprint("crop_recommendation", __name__)


crop_model = joblib.load(base_dir / "random_forest_model.pkl")
market_model = joblib.load(base_dir / "market_prediction_model.pkl")


crop_features = joblib.load(base_dir / "crop_features.pkl")
market_features = joblib.load(base_dir / "market_features.pkl")



@bp.route("/")
def home():
    return jsonify({
        "message": "Paddy Crop Recommendation API Running"
    })



@bp.route("/predict", methods=["POST"])
def predict():

    try:

        data = request.json


        crop_input = {
            "soil_moisture": data["soil_moisture"],
            "temperature": data["temperature"],
            "humidity": data["humidity"],
            "nitrogen": data["nitrogen"],
            "phosphorus": data["phosphorus"],
            "potassium": data["potassium"],
            "season": data["season"]
        }

        crop_df = pd.DataFrame([crop_input])

        # one-hot encode
        crop_df = pd.get_dummies(crop_df)

        # align columns
        crop_df = crop_df.reindex(columns=crop_features, fill_value=0)


        probs = crop_model.predict_proba(crop_df)[0]

        top_indices = probs.argsort()[-3:][::-1]


        crop_mapping = {
            0: "BG300",
            1: "AT362",
            2: "BG352"
        }

        crops = [crop_mapping[int(i)] for i in top_indices]


        market_data = data["market_data"]

        results = []

        for crop in crops:

    
            samba_varieties = ["BG300", "BG352"]
            nadu_varieties = ["AT362"]

            crop_samba = 1 if crop in samba_varieties else 0
            crop_nadu = 1 if crop in nadu_varieties else 0

            sample = {
                "year": 2024,
                "month_num": market_data["month_num"],
                "lag_price": market_data["lag_price"],
                "lag_1": market_data["lag_1"],
                "lag_2": market_data["lag_2"],
                "lag_3": market_data["lag_3"],

                "crop_Samba": crop_samba,
                "crop_Nadu": crop_nadu,

                "season_Maha": 1 if data["season"] == "Maha" else 0,
                "season_Yala": 1 if data["season"] == "Yala" else 0
            }

            df_sample = pd.DataFrame([sample])

            # align market columns
            df_sample = df_sample.reindex(
                columns=market_features,
                fill_value=0
            )

            predicted_price = market_model.predict(df_sample)[0]


            variety_bonus = {
                "BG300": 8,
                "AT362": 3,
                "BG352": 0
            }

            predicted_price += variety_bonus.get(crop, 0)

            results.append({
                "crop": crop,
                "predicted_price": round(float(predicted_price), 2)
            })


        results = sorted(
            results,
            key=lambda x: x["predicted_price"],
            reverse=True
        )


        response = {
            "recommendations": {
                "high_profit": results[0],
                "balanced": results[1],
                "safe": results[2]
            },
            "all_predictions": results
        }

        return jsonify(response)

    except Exception as e:

        return jsonify({
            "error": str(e)
        }), 500



if __name__ == "__main__":
    app = Flask(__name__)
    app.register_blueprint(bp)
    app.run(debug=True)