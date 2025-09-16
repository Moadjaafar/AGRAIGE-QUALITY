import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/camion_decharge.dart';
import '../models/agraige_qualite_tests.dart';
import '../models/agraige_moul_tests.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Future<List<CamionDecharge>> getAllCamionDecharges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/camiondecharge'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CamionDecharge.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load camions: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<CamionDecharge> getCamionDechargeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/camiondecharge/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return CamionDecharge.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Camion not found');
      } else {
        throw ApiException('Failed to load camion: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<CamionDecharge> createCamionDecharge(CamionDecharge camion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/camiondecharge'),
        headers: headers,
        body: json.encode(camion.toJson()),
      );

      if (response.statusCode == 201) {
        return CamionDecharge.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create camion: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<CamionDecharge> updateCamionDecharge(int id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/camiondecharge/$id'),
        headers: headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return CamionDecharge.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to update camion: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<void> deleteCamionDecharge(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/camiondecharge/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete camion: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<List<AgraigeQualiteTests>> getAllQualiteTests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigequalitetests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AgraigeQualiteTests.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load qualite tests: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeQualiteTests> getQualiteTestById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigequalitetests/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return AgraigeQualiteTests.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Qualite test not found');
      } else {
        throw ApiException('Failed to load qualite test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<List<AgraigeQualiteTests>> getQualiteTestsByCamionId(int camionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigequalitetests/by-camion/$camionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AgraigeQualiteTests.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load qualite tests: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeQualiteTests> createQualiteTest(AgraigeQualiteTests test) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agraigequalitetests'),
        headers: headers,
        body: json.encode(test.toJson()),
      );

      if (response.statusCode == 201) {
        return AgraigeQualiteTests.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create qualite test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeQualiteTests> updateQualiteTest(int id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agraigequalitetests/$id'),
        headers: headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return AgraigeQualiteTests.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to update qualite test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<void> deleteQualiteTest(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/agraigequalitetests/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete qualite test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<List<AgraigeMoulTests>> getAllMoulTests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigemoutests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AgraigeMoulTests.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load moul tests: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeMoulTests> getMoulTestById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigemoutests/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return AgraigeMoulTests.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Moul test not found');
      } else {
        throw ApiException('Failed to load moul test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<List<AgraigeMoulTests>> getMoulTestsByCamionId(int camionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agraigemoutests/by-camion/$camionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AgraigeMoulTests.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load moul tests: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeMoulTests> createMoulTest(AgraigeMoulTests test) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agraigemoutests'),
        headers: headers,
        body: json.encode(test.toJson()),
      );

      if (response.statusCode == 201) {
        return AgraigeMoulTests.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to create moul test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<AgraigeMoulTests> updateMoulTest(int id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agraigemoutests/$id'),
        headers: headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return AgraigeMoulTests.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to update moul test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<void> deleteMoulTest(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/agraigemoutests/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw ApiException('Failed to delete moul test: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/camiondecharge'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
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