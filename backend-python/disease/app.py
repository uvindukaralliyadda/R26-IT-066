from flask import Flask, Blueprint, request, jsonify
from ultralytics import YOLO
import os
import cv2
import uuid
from pathlib import Path

base_dir = Path(__file__).resolve().parent

bp = Blueprint("disease", __name__)


model = YOLO(str(base_dir / "best.pt"))


UPLOAD_FOLDER = base_dir / "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@bp.route("/")
def home():
    return jsonify({
        "message": "Paddy Disease Detection API Running"
    })


@bp.route("/predict", methods=["POST"])
def predict():


    if "image" not in request.files:
        return jsonify({
            "success": False,
            "message": "No image file found"
        })

    file = request.files["image"]

    if file.filename == "":
        return jsonify({
            "success": False,
            "message": "No selected image"
        })

    try:


        filename = f"{uuid.uuid4()}.jpg"

        filepath = os.path.join(str(UPLOAD_FOLDER), filename)

        file.save(filepath)


        image = cv2.imread(filepath)

        height, width, _ = image.shape

        image_area = width * height


        results = model(filepath)

        result = results[0]


        if len(result.boxes) == 0:
            return jsonify({
                "success": True,
                "disease": "healthy",
                "confidence": 0,
                "spread_area_percent": 0,
                "severity": "None"
            })


        class_id = int(result.boxes.cls[0])

        confidence = float(result.boxes.conf[0])

        predicted_class = model.names[class_id]


        total_disease_area = 0

        for box in result.boxes.xyxy:

            x1, y1, x2, y2 = box.tolist()

            box_width = x2 - x1
            box_height = y2 - y1

            area = box_width * box_height

            total_disease_area += area

        spread_percent = (total_disease_area / image_area) * 100


        if confidence < 0.50:
            predicted_class = "healthy"
            spread_percent = 0


        if spread_percent <= 5:
            severity = "Mild"

        elif spread_percent <= 20:
            severity = "Moderate"

        elif spread_percent <= 40:
            severity = "High"

        else:
            severity = "Severe"

        # Healthy override
        if predicted_class == "healthy":
            severity = "None"


        return jsonify({
            "success": True,
            "disease": predicted_class,
            "confidence": round(confidence * 100, 2),
            "spread_area_percent": round(spread_percent, 2),
            "severity": severity
        })

    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        })

if __name__ == "__main__":

    app = Flask(__name__)

    app.register_blueprint(bp)

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )