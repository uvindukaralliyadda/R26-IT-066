from flask import Flask, Blueprint, request, jsonify
import joblib
import pandas as pd
from pathlib import Path

base_dir = Path(__file__).resolve().parent
bp = Blueprint("decision_support", __name__)

# =========================
# LOAD MODELS (FINAL VERSION)
# =========================

model1_bundle = joblib.load(base_dir / "random_forest_model2.pkl")
model1 = model1_bundle["model"]
cols1 = model1_bundle["columns"]

model2_bundle = joblib.load(base_dir / "model2_xgboost.pkl")
model2 = model2_bundle["model"]
cols2 = model2_bundle["columns"]

print("✅ Models loaded successfully")
print("Model1 features:", len(cols1))
print("Model2 features:", len(cols2))


# =========================
# HELPER FUNCTIONS
# =========================

def build_model1_input(data):
    input_dict = {
        "soil_moisture": data["soil_moisture"],
        "temperature": data["temperature"],
        "humidity": data["humidity"],
        "nitrogen": data["nitrogen"],
        "phosphorus": data["phosphorus"],
        "potassium": data["potassium"],

        # growth stage (Model 1 uses 5 stages)
        "growth_stage_germination": 1 if data["growth_stage"] == "germination" else 0,
        "growth_stage_tillering": 1 if data["growth_stage"] == "tillering" else 0,
        "growth_stage_panicle": 1 if data["growth_stage"] == "panicle" else 0,
        "growth_stage_heading": 1 if data["growth_stage"] == "heading" else 0,
        "growth_stage_maturity": 1 if data["growth_stage"] == "maturity" else 0,

        # season
        "season_Maha": 1 if data["season"] == "Maha" else 0,
        "season_Yala": 1 if data["season"] == "Yala" else 0,

        # variety
        "variety_BG300": 1 if data["variety"] == "BG300" else 0,
        "variety_AT362": 1 if data["variety"] == "AT362" else 0,
    }

    df = pd.DataFrame([input_dict])
    df = df.reindex(columns=cols1, fill_value=0)

    return df


def build_model2_input(data):
    input_dict = {
        "severity": data["severity"],

        # disease
        "disease_type_Blast": 1 if data["disease"] == "Blast" else 0,
        "disease_type_BrownSpot": 1 if data["disease"] == "BrownSpot" else 0,

        # growth stage (Model 2 uses different naming)
        "growth_stage_vegetative": 1 if data["growth_stage"] == "vegetative" else 0,
        "growth_stage_tillering": 1 if data["growth_stage"] == "tillering" else 0,
        "growth_stage_panicle": 1 if data["growth_stage"] == "panicle" else 0,
        "growth_stage_heading": 1 if data["growth_stage"] == "heading" else 0,
        "growth_stage_grain": 1 if data["growth_stage"] == "grain" else 0,
    }

    df = pd.DataFrame([input_dict])
    df = df.reindex(columns=cols2, fill_value=0)

    return df


# =========================
# ROUTES
# =========================

@bp.route("/")
def home():
    return "🌾 Paddy DSS API is running"


@bp.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        # -------- VALIDATION --------
        required_fields = [
            "soil_moisture", "temperature", "humidity",
            "nitrogen", "phosphorus", "potassium",
            "growth_stage", "season", "variety",
            "disease", "severity"
        ]

        for field in required_fields:
            app = Flask(__name__)
            app.register_blueprint(bp)
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400

        # -------- MODEL 1 --------
        df1 = build_model1_input(data)
        base_yield = model1.predict(df1)[0]

        # -------- MODEL 2 --------
        df2 = build_model2_input(data)
        loss_percent = model2.predict(df2)[0]

        # -------- CALCULATIONS --------
        untreated_yield = base_yield * (1 - loss_percent / 100)

        # assume treatment reduces loss by 60%
        treated_loss = loss_percent * 0.4
        treated_yield = base_yield * (1 - treated_loss / 100)

        decision = "TREAT" if treated_yield > untreated_yield else "DO NOT TREAT"

        return jsonify({
             "base_yield": float(round(base_yield, 2)),
             "loss_percent": float(round(loss_percent, 2)),
             "untreated_yield": float(round(untreated_yield, 2)),
             "treated_yield": float(round(treated_yield, 2)),
             "decision": decision
     })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =========================
# RUN SERVER
# =========================

if __name__ == "__main__":
    app.run(debug=True)