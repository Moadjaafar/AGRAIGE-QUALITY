import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/camion_decharge.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/agraige_moul_tests.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5071/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Future<CamionDecharge> createCamionDecharge(CamionDecharge camion) async {
    try {
      final payload = camion.toApiJson();
      print('Sending camion payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/camiondecharge'),
        headers: headers,
        body: json.encode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CamionDecharge.fromApiJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create camion: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }


  static Future<AgraigeQualiteTests> createQualiteTest(AgraigeQualiteTests test) async {
    try {
      final payload = test.toApiJson();
      print('Sending qualite test payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/AgraigeQualiteTests'),
        headers: headers,
        body: json.encode(payload),
      );

      print('Qualite test response status: ${response.statusCode}');
      print('Qualite test response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AgraigeQualiteTests.fromApiJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create qualite test: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }


  static Future<AgraigeMoulTests> createMoulTest(AgraigeMoulTests test) async {
    try {
      final payload = test.toApiJson();
      print('Sending moul test payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/AgraigeMoulTests'),
        headers: headers,
        body: json.encode(payload),
      );

      print('Moul test response status: ${response.statusCode}');
      print('Moul test response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AgraigeMoulTests.fromApiJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create moul test: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }


  static Future<bool> testConnection() async {
    try {
      // Simple connection test - try to make a POST request to test server availability
      final response = await http.post(
        Uri.parse('$baseUrl/camiondecharge'),
        headers: headers,
        body: json.encode({}), // Empty body - will likely fail validation but confirms server is reachable
      ).timeout(const Duration(seconds: 10));

      // Accept any response (even 400 bad request) as it means server is reachable
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}