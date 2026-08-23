import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Configurable base URL
  static String baseUrl = 'http://127.0.0.1:5000';

  static void setCustomBaseUrl(String url) {
    if (url.isNotEmpty) {
      baseUrl = url.trim();
    }
  }

  /// Generic POST request helper
  static Future<Map<String, dynamic>> postJson(
      String endpoint, Map<String, dynamic> bodyData) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(bodyData),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data.containsKey('error') && data['error'] != null) {
          throw Exception(data['error'].toString());
        }
        return data;
      } else {
        throw Exception(
            data['error'] ?? data['message'] ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ApiService Error] $endpoint: $e');
      rethrow;
    }
  }

  /// Component 1: Yield & Disease Treatment Decision
  static Future<Map<String, dynamic>> predictYieldDecision(
      Map<String, dynamic> payload) async {
    return await postJson('/decision-support/predict', payload);
  }

  /// Component 2: Crop Recommendation & Market Prediction
  static Future<Map<String, dynamic>> predictCropRecommendation(
      Map<String, dynamic> payload) async {
    return await postJson('/crop-recommendation/predict', payload);
  }

  /// Component 3: IoT Paddy Fertilization Decision Support
  static Future<Map<String, dynamic>> predictFertilization(
      Map<String, dynamic> payload) async {
    return await postJson('/iot/predict', payload);
  }

  /// Component 4: Paddy Leaf Disease Detection (Multipart Image Upload)
  static Future<Map<String, dynamic>> predictDiseaseImage({
    required List<int> imageBytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/disease/predict');
    try {
      final request = http.MultipartRequest('POST', uri);

      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['success'] == false) {
          throw Exception(data['message'] ?? data['error'] ?? 'Prediction failed');
        }
        return data;
      } else {
        throw Exception(
            data['error'] ?? data['message'] ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ApiService Multipart Error] /disease/predict: $e');
      rethrow;
    }
  }
}
