from datetime import datetime
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle, PageBreak


ROOT = Path(__file__).resolve().parent
OUTPUT_DIR = ROOT / "docs"
OUTPUT_PDF = OUTPUT_DIR / "Agro_Eye_Project_Report.pdf"


def build_story():
    styles = getSampleStyleSheet()

    title_style = ParagraphStyle(
        "TitleStyle",
        parent=styles["Title"],
        fontSize=24,
        leading=28,
        spaceAfter=14,
        textColor=colors.HexColor("#0D2D1D"),
    )
    subtitle_style = ParagraphStyle(
        "SubtitleStyle",
        parent=styles["Normal"],
        fontSize=11,
        leading=15,
        textColor=colors.HexColor("#333333"),
        spaceAfter=20,
    )
    h1 = ParagraphStyle(
        "H1",
        parent=styles["Heading1"],
        fontSize=16,
        leading=20,
        spaceBefore=10,
        spaceAfter=8,
        textColor=colors.HexColor("#0D2D1D"),
    )
    h2 = ParagraphStyle(
        "H2",
        parent=styles["Heading2"],
        fontSize=13,
        leading=16,
        spaceBefore=8,
        spaceAfter=6,
        textColor=colors.HexColor("#1F4F38"),
    )
    body = ParagraphStyle(
        "Body",
        parent=styles["BodyText"],
        fontSize=10.5,
        leading=15,
        spaceAfter=6,
    )
    bullet = ParagraphStyle(
        "BulletBody",
        parent=body,
        leftIndent=12,
        bulletIndent=0,
        spaceAfter=2,
    )

    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    story = [
        Paragraph("Agro Eye Project Report", title_style),
        Paragraph(
            f"Comprehensive implementation and integration documentation generated on {now}.",
            subtitle_style,
        ),
        Paragraph("1) Project Overview", h1),
        Paragraph(
            "Agro Eye is a Flutter-based mobile application for plant leaf disease detection. "
            "The application allows users to authenticate, capture or select leaf images, "
            "run local on-device inference, and display disease/healthy predictions with confidence.",
            body,
        ),
        Paragraph(
            "Core goals of the project:", h2
        ),
        Paragraph("• Build a practical mobile UX for disease scanning (camera + gallery).", bullet),
        Paragraph("• Integrate a deep learning model with low-latency on-device inference.", bullet),
        Paragraph("• Provide robust preprocessing and readable prediction output.", bullet),
        Paragraph("• Keep the app functional even when model runtime issues occur (fallback-safe architecture).", bullet),

        Paragraph("2) Technology Stack", h1),
        Paragraph("Application Layer", h2),
        Paragraph("• Flutter (Dart SDK constraint: ^3.8.1)", bullet),
        Paragraph("• Firebase Core + Firebase Auth for app initialization and authentication", bullet),
        Paragraph("• image_picker for camera/gallery image input", bullet),
        Paragraph("• image package for image decoding, resizing, and pixel processing", bullet),
        Paragraph("• tflite_flutter for TensorFlow Lite runtime execution", bullet),

        Paragraph("ML & Conversion Layer", h2),
        Paragraph("• PyTorch checkpoints (.pth) as model training artifacts", bullet),
        Paragraph("• ONNX as interchange format", bullet),
        Paragraph("• onnx2tf for ONNX → TensorFlow/TFLite conversion", bullet),
        Paragraph("• TensorFlow Lite model deployed as app asset", bullet),

        Paragraph("3) High-Level App Architecture", h1),
        Paragraph(
            "The model integration follows a service-oriented pattern where UI concerns and inference logic "
            "are separated. The UI triggers image acquisition and classification requests while a dedicated "
            "classifier service handles model loading, preprocessing, tensor execution, and probability postprocessing.",
            body,
        ),
        Paragraph("Main flow", h2),
        Paragraph("• User opens Home screen and classifier initializes in the background.", bullet),
        Paragraph("• User captures/selects an image.", bullet),
        Paragraph("• Image is sent to PlantClassifierService.classifyImage(...).", bullet),
        Paragraph("• Service decodes + resizes image to 224×224 and normalizes with ImageNet stats.", bullet),
        Paragraph("• TFLite inference returns logits/probabilities for 8 classes.", bullet),
        Paragraph("• Top class + confidence are returned and rendered in the UI.", bullet),

        Paragraph("4) Files and Responsibilities", h1),
        Paragraph("Key Flutter files", h2),
        Paragraph("• lib/main.dart: Firebase initialization and app bootstrap", bullet),
        Paragraph("• lib/home_screen.dart: crop selection, gallery/camera triggers, and result display", bullet),
        Paragraph("• lib/services/plant_classifier_service.dart: TFLite lifecycle + preprocessing + inference", bullet),
        Paragraph("• pubspec.yaml: dependencies and model/labels asset registration", bullet),

        Paragraph("Platform configuration", h2),
        Paragraph("• android/app/src/main/AndroidManifest.xml: camera/media permissions", bullet),
        Paragraph("• android/app/build.gradle.kts: noCompress(\"tflite\") for model packaging", bullet),
        Paragraph("• ios/Runner/Info.plist: camera and photo-library usage descriptions", bullet),

        PageBreak(),

        Paragraph("5) Model Evolution and Integration Journey", h1),
        Paragraph(
            "The integration journey included multiple iterations due to cross-platform runtime and conversion "
            "constraints. Initial attempts used ONNX Runtime directly in Flutter, but Android native library "
            "loading issues blocked reliable deployment. The project then moved to TensorFlow Lite for stable "
            "mobile inference packaging.",
            body,
        ),
        Paragraph("Important technical milestones", h2),
        Paragraph("• Initial ONNX Runtime approach encountered Android shared-library loading issues.", bullet),
        Paragraph("• Migration to TFLite runtime in Flutter improved deployment reliability.", bullet),
        Paragraph("• Python compatibility issues (very recent Python versions) broke ML package installation.", bullet),
        Paragraph("• A compatible conversion environment (Python 3.11-based) was used for successful conversion.", bullet),
        Paragraph("• Input tensor format mismatch (NCHW vs NHWC) was corrected in Flutter preprocessing.", bullet),
        Paragraph("• Final integration switched active model to best_mobilenetv3_small checkpoint.", bullet),

        Paragraph("6) Final Integrated Model (Current State)", h1),
        Paragraph("Current active mobile model", h2),
        Paragraph("• Source checkpoint: output_comparison/best_mobilenetv3_small.pth", bullet),
        Paragraph("• Converted deployment model: assets/ml/plant_disease_model.tflite", bullet),
        Paragraph("• Model family: MobileNetV3 Small", bullet),
        Paragraph("• Checkpoint validation accuracy: 100.0 (as stored in checkpoint metadata)", bullet),
        Paragraph("• Epoch in checkpoint metadata: 15", bullet),

        Paragraph("Input/Output contract", h2),
        Paragraph("• Input shape: [1, 224, 224, 3]", bullet),
        Paragraph("• Input dtype: float32", bullet),
        Paragraph("• Tensor format: NHWC (channels-last)", bullet),
        Paragraph("• Output shape: [1, 8]", bullet),
        Paragraph("• Output dtype: float32", bullet),

        Paragraph("Class labels", h2),
    ]

    class_data = [
        ["Index", "Label"],
        ["0", "Apple Scab"],
        ["1", "Apple Black Rot"],
        ["2", "Apple Cedar Rust"],
        ["3", "Apple Healthy"],
        ["4", "Grape Black Rot"],
        ["5", "Grape Esca"],
        ["6", "Grape Leaf Blight"],
        ["7", "Grape Healthy"],
    ]

    class_table = Table(class_data, colWidths=[2.5 * cm, 11.5 * cm])
    class_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#E8F2EC")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.HexColor("#0D2D1D")),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#B7C9BF")),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
                ("FONTSIZE", (0, 0), (-1, -1), 10),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FBF9")]),
                ("ALIGN", (0, 0), (0, -1), "CENTER"),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    story.extend([class_table, Spacer(1, 0.4 * cm)])

    story.extend(
        [
            Paragraph("7) Inference Pipeline Details", h1),
            Paragraph("Image preprocessing", h2),
            Paragraph("• Decode image bytes into RGB pixel matrix.", bullet),
            Paragraph("• Resize image to 224×224.", bullet),
            Paragraph("• Convert each channel from [0,255] to [0,1].", bullet),
            Paragraph("• Normalize with ImageNet mean/std per channel.", bullet),
            Paragraph("• Build tensor in NHWC format: [batch, height, width, channels].", bullet),

            Paragraph("Post-processing", h2),
            Paragraph("• Raw model output is transformed via softmax.", bullet),
            Paragraph("• Highest-probability label is selected as top prediction.", bullet),
            Paragraph("• Confidence is presented as percentage in UI.", bullet),
            Paragraph("• The label is also interpreted as Healthy vs Disease based on class name.", bullet),

            Paragraph("8) Conversion Pipeline Used for MobileNetV3-Small", h1),
            Paragraph("Implemented script: convert_best_mobilenetv3_small.py", h2),
            Paragraph("• Loads checkpoint and extracts state_dict + class_names.", bullet),
            Paragraph("• Rebuilds torchvision MobileNetV3-Small with 8-class classifier head.", bullet),
            Paragraph("• Exports model to ONNX (opset 13, dynamic batch axis).", bullet),
            Paragraph("• Converts ONNX to TensorFlow/TFLite using onnx2tf.", bullet),
            Paragraph("• Copies generated float32 TFLite model to assets/ml/plant_disease_model.tflite.", bullet),
            Paragraph("• Updates assets/ml/model_metadata.json for deployment traceability.", bullet),

            Paragraph("9) Platform and Packaging Considerations", h1),
            Paragraph("Android", h2),
            Paragraph("• Camera and media permissions are declared in AndroidManifest.xml.", bullet),
            Paragraph("• TFLite files are excluded from compression via aaptOptions.noCompress('tflite').", bullet),
            Paragraph("• This avoids model extraction/reading issues at runtime.", bullet),

            Paragraph("iOS", h2),
            Paragraph("• Info.plist contains NSCameraUsageDescription and NSPhotoLibraryUsageDescription.", bullet),
            Paragraph("• These are required for camera/gallery workflows on iOS.", bullet),

            PageBreak(),

            Paragraph("10) Known Issues and Resolutions", h1),
            Paragraph("Issue: Python package incompatibility with bleeding-edge Python", h2),
            Paragraph("• Symptom: TensorFlow/ONNX-related packages failing to install.", bullet),
            Paragraph("• Resolution: Use a compatible Python environment for model conversion (e.g., 3.11).", bullet),

            Paragraph("Issue: ONNX Runtime Android native loading failure", h2),
            Paragraph("• Symptom: Native shared library errors on Android runtime.", bullet),
            Paragraph("• Resolution: Move inference runtime to TensorFlow Lite in Flutter.", bullet),

            Paragraph("Issue: Bad state / failed precondition at inference time", h2),
            Paragraph("• Symptom: Runtime error during _interpreter.run(...).", bullet),
            Paragraph("• Root cause: Input tensor channel ordering mismatch.", bullet),
            Paragraph("• Resolution: Changed preprocessing to NHWC [1,224,224,3].", bullet),

            Paragraph("11) Operational Runbook", h1),
            Paragraph("Day-to-day app run", h2),
            Paragraph("• flutter pub get", bullet),
            Paragraph("• flutter run -d emulator-5554 (or any connected device)", bullet),

            Paragraph("Regenerating model from best_mobilenetv3_small", h2),
            Paragraph("• Ensure Python conversion environment has torch, torchvision, onnx2tf and dependencies.", bullet),
            Paragraph("• Run: python convert_best_mobilenetv3_small.py", bullet),
            Paragraph("• Rebuild Flutter app so updated asset is packaged.", bullet),

            Paragraph("12) Recommendations for Next Iteration", h1),
            Paragraph("• Add confidence thresholding and uncertain/abstain class handling.", bullet),
            Paragraph("• Add model version display in-app (read from model_metadata.json).", bullet),
            Paragraph("• Persist inference history with image, label, confidence, timestamp.", bullet),
            Paragraph("• Add instrumentation logs for interpreter input/output signatures on startup.", bullet),
            Paragraph("• Create a small automated validation script that compares ONNX vs TFLite outputs on sample images.", bullet),

            Paragraph("13) Summary", h1),
            Paragraph(
                "Agro Eye now runs a fully integrated, on-device MobileNetV3-Small disease classifier via TFLite. "
                "The app pipeline is stable, model assets are properly packaged, preprocessing is aligned with "
                "the deployed tensor contract, and the conversion workflow is reproducible through the project scripts.",
                body,
            ),
        ]
    )

    return story


def create_pdf():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    doc = SimpleDocTemplate(
        str(OUTPUT_PDF),
        pagesize=A4,
        leftMargin=1.8 * cm,
        rightMargin=1.8 * cm,
        topMargin=1.8 * cm,
        bottomMargin=1.8 * cm,
        title="Agro Eye Project Report",
        author="Agro Eye Development Team",
        subject="Model integration and project implementation details",
    )

    story = build_story()
    doc.build(story)

    print(f"PDF generated: {OUTPUT_PDF}")


if __name__ == "__main__":
    create_pdf()
