# Fish Industry ERP - API Documentation for Flutter Developer

## Overview
This document provides comprehensive API documentation for the Fish Industry ERP system. The backend provides RESTful APIs for managing truck discharge data and fish quality testing.

## Base Configuration

### API Base URL
```
https://your-api-domain.com/api
```

### Authentication
Currently no authentication required. Add authorization headers when implemented.

### Content Type
All requests should include:
```
Content-Type: application/json
```

---

## 1. Camion Decharge (Truck Discharge) API

### Base Endpoint: `/api/camiondecharge`

#### Get All Truck Discharges
```http
GET /api/camiondecharge
```

**Response:**
```json
[
  {
    "idDecharge": 1,
    "matCamion": "TRK001",
    "bateau": "Fishing Boat 1",
    "maree": "Morning Tide",
    "heureDecharge": "2024-01-15T08:30:00",
    "heureTraitement": "2024-01-15T09:00:00",
    "temperature": 4.5,
    "nbrAgraigeQualite": 10,
    "nbrAgraigeMoule": 5,
    "isExported": false,
    "dateCreation": "2024-01-15T08:00:00",
    "dateModification": "2024-01-15T08:00:00"
  }
]
```

#### Get Truck Discharge by ID
```http
GET /api/camiondecharge/{id}
```

**Response:** Same as single object from array above

#### Create New Truck Discharge
```http
POST /api/camiondecharge
```

**Request Body:**
```json
{
  "matCamion": "TRK001",
  "bateau": "Fishing Boat 1",
  "maree": "Morning Tide",
  "heureDecharge": "2024-01-15T08:30:00",
  "heureTraitement": "2024-01-15T09:00:00",
  "temperature": 4.5,
  "nbrAgraigeQualite": 10,
  "nbrAgraigeMoule": 5,
  "dateCreation": "2024-01-15T08:00:00"
}
```

**Required Fields:**
- `matCamion` (string, max 20 chars)

**Optional Fields:**
- `bateau`, `maree`, `heureDecharge`, `heureTraitement`, `temperature`, `nbrAgraigeQualite`, `nbrAgraigeMoule`, `dateCreation`

#### Update Truck Discharge
```http
PUT /api/camiondecharge/{id}
```

**Request Body:** (All fields optional)
```json
{
  "matCamion": "TRK001-UPDATED",
  "bateau": "Updated Boat Name",
  "temperature": 3.8,
  "isExported": true
}
```

#### Delete Truck Discharge
```http
DELETE /api/camiondecharge/{id}
```

**Response:** 204 No Content

#### Get Related Quality Tests
```http
GET /api/camiondecharge/{id}/agraige-tests
```

**Response:** Array of AgraigeQualiteTests objects

---

## 2. Agraige Qualite Tests (Fish Quality Tests) API

### Base Endpoint: `/api/agraigequalitetests`

#### Get All Quality Tests
```http
GET /api/agraigequalitetests
```

**Response:**
```json
[
  {
    "id": 1,
    "agraigeA": 50,
    "agraigeB": 30,
    "agraigeC": 20,
    "agraigeMAQ": 10,
    "agraigeCHIN": 5,
    "agraigeFP": 15,
    "agraigeG": 8,
    "agraigeAnchois": 12,
    "petitCaliber": 25,
    "idCamionDecharge": 1,
    "dateCreation": "2024-01-15T08:30:00",
    "dateModification": "2024-01-15T08:30:00"
  }
]
```

#### Get Quality Test by ID
```http
GET /api/agraigequalitetests/{id}
```

#### Create New Quality Test
```http
POST /api/agraigequalitetests
```

**Request Body:**
```json
{
  "agraigeA": 50,
  "agraigeB": 30,
  "agraigeC": 20,
  "agraigeMAQ": 10,
  "agraigeCHIN": 5,
  "agraigeFP": 15,
  "agraigeG": 8,
  "agraigeAnchois": 12,
  "petitCaliber": 25,
  "idCamionDecharge": 1,
  "dateCreation": "2024-01-15T08:30:00"
}
```

**Required Fields:**
- `idCamionDecharge` (integer)

#### Update Quality Test
```http
PUT /api/agraigequalitetests/{id}
```

#### Delete Quality Test
```http
DELETE /api/agraigequalitetests/{id}
```

#### Get Quality Tests by Truck
```http
GET /api/agraigequalitetests/by-camion/{camionId}
```

---

## 3. Agraige Moul Tests (Fish Mold Size Tests) API

### Base Endpoint: `/api/agraigemoutests`

#### Get All Mold Tests
```http
GET /api/agraigemoutests
```

**Response:**
```json
[
  {
    "id": 1,
    "moul6_8": 100,
    "moul8_10": 150,
    "moul10_12": 200,
    "moul12_16": 180,
    "moul16_20": 120,
    "moul20_26": 80,
    "moulGt30": 50,
    "idCamionDecharge": 1,
    "dateCreation": "2024-01-15T08:30:00",
    "dateModification": "2024-01-15T08:30:00"
  }
]
```

#### Get Mold Test by ID
```http
GET /api/agraigemoutests/{id}
```

#### Create New Mold Test
```http
POST /api/agraigemoutests
```

**Request Body:**
```json
{
  "moul6_8": 100,
  "moul8_10": 150,
  "moul10_12": 200,
  "moul12_16": 180,
  "moul16_20": 120,
  "moul20_26": 80,
  "moulGt30": 50,
  "idCamionDecharge": 1,
  "dateCreation": "2024-01-15T08:30:00"
}
```

**Required Fields:**
- `idCamionDecharge` (integer)

#### Update Mold Test
```http
PUT /api/agraigemoutests/{id}
```

#### Delete Mold Test
```http
DELETE /api/agraigemoutests/{id}
```

#### Get Mold Tests by Truck
```http
GET /api/agraigemoutests/by-camion/{camionId}
```

---

## Flutter Implementation Guidelines

### 1. HTTP Client Setup

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    // Add authorization headers when needed
  };
}
```

### 2. Data Models

#### CamionDecharge Model
```dart
class CamionDecharge {
  final int idDecharge;
  final String matCamion;
  final String? bateau;
  final String? maree;
  final DateTime? heureDecharge;
  final DateTime? heureTraitement;
  final double? temperature;
  final int? nbrAgraigeQualite;
  final int? nbrAgraigeMoule;
  final bool isExported;
  final DateTime dateCreation;
  final DateTime dateModification;

  CamionDecharge({
    required this.idDecharge,
    required this.matCamion,
    this.bateau,
    this.maree,
    this.heureDecharge,
    this.heureTraitement,
    this.temperature,
    this.nbrAgraigeQualite,
    this.nbrAgraigeMoule,
    required this.isExported,
    required this.dateCreation,
    required this.dateModification,
  });

  factory CamionDecharge.fromJson(Map<String, dynamic> json) {
    return CamionDecharge(
      idDecharge: json['idDecharge'],
      matCamion: json['matCamion'],
      bateau: json['bateau'],
      maree: json['maree'],
      heureDecharge: json['heureDecharge'] != null
          ? DateTime.parse(json['heureDecharge']) : null,
      heureTraitement: json['heureTraitement'] != null
          ? DateTime.parse(json['heureTraitement']) : null,
      temperature: json['temperature']?.toDouble(),
      nbrAgraigeQualite: json['nbrAgraigeQualite'],
      nbrAgraigeMoule: json['nbrAgraigeMoule'],
      isExported: json['isExported'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matCamion': matCamion,
      'bateau': bateau,
      'maree': maree,
      'heureDecharge': heureDecharge?.toIso8601String(),
      'heureTraitement': heureTraitement?.toIso8601String(),
      'temperature': temperature,
      'nbrAgraigeQualite': nbrAgraigeQualite,
      'nbrAgraigeMoule': nbrAgraigeMoule,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
```

#### AgraigeQualiteTests Model
```dart
class AgraigeQualiteTests {
  final int id;
  final int? agraigeA;
  final int? agraigeB;
  final int? agraigeC;
  final int? agraigeMAQ;
  final int? agraigeCHIN;
  final int? agraigeFP;
  final int? agraigeG;
  final int? agraigeAnchois;
  final int? petitCaliber;
  final int idCamionDecharge;
  final DateTime dateCreation;
  final DateTime dateModification;

  AgraigeQualiteTests({
    required this.id,
    this.agraigeA,
    this.agraigeB,
    this.agraigeC,
    this.agraigeMAQ,
    this.agraigeCHIN,
    this.agraigeFP,
    this.agraigeG,
    this.agraigeAnchois,
    this.petitCaliber,
    required this.idCamionDecharge,
    required this.dateCreation,
    required this.dateModification,
  });

  factory AgraigeQualiteTests.fromJson(Map<String, dynamic> json) {
    return AgraigeQualiteTests(
      id: json['id'],
      agraigeA: json['agraigeA'],
      agraigeB: json['agraigeB'],
      agraigeC: json['agraigeC'],
      agraigeMAQ: json['agraigeMAQ'],
      agraigeCHIN: json['agraigeCHIN'],
      agraigeFP: json['agraigeFP'],
      agraigeG: json['agraigeG'],
      agraigeAnchois: json['agraigeAnchois'],
      petitCaliber: json['petitCaliber'],
      idCamionDecharge: json['idCamionDecharge'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agraigeA': agraigeA,
      'agraigeB': agraigeB,
      'agraigeC': agraigeC,
      'agraigeMAQ': agraigeMAQ,
      'agraigeCHIN': agraigeCHIN,
      'agraigeFP': agraigeFP,
      'agraigeG': agraigeG,
      'agraigeAnchois': agraigeAnchois,
      'petitCaliber': petitCaliber,
      'idCamionDecharge': idCamionDecharge,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
```

#### AgraigeMoulTests Model
```dart
class AgraigeMoulTests {
  final int id;
  final int? moul6_8;
  final int? moul8_10;
  final int? moul10_12;
  final int? moul12_16;
  final int? moul16_20;
  final int? moul20_26;
  final int? moulGt30;
  final int idCamionDecharge;
  final DateTime dateCreation;
  final DateTime dateModification;

  AgraigeMoulTests({
    required this.id,
    this.moul6_8,
    this.moul8_10,
    this.moul10_12,
    this.moul12_16,
    this.moul16_20,
    this.moul20_26,
    this.moulGt30,
    required this.idCamionDecharge,
    required this.dateCreation,
    required this.dateModification,
  });

  factory AgraigeMoulTests.fromJson(Map<String, dynamic> json) {
    return AgraigeMoulTests(
      id: json['id'],
      moul6_8: json['moul6_8'],
      moul8_10: json['moul8_10'],
      moul10_12: json['moul10_12'],
      moul12_16: json['moul12_16'],
      moul16_20: json['moul16_20'],
      moul20_26: json['moul20_26'],
      moulGt30: json['moulGt30'],
      idCamionDecharge: json['idCamionDecharge'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moul6_8': moul6_8,
      'moul8_10': moul8_10,
      'moul10_12': moul10_12,
      'moul12_16': moul12_16,
      'moul16_20': moul16_20,
      'moul20_26': moul20_26,
      'moulGt30': moulGt30,
      'idCamionDecharge': idCamionDecharge,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }
}
```

### 3. Service Implementation Example

```dart
class CamionDechargeService {
  static Future<List<CamionDecharge>> getAllCamions() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/camiondecharge'),
      headers: ApiService.headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CamionDecharge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load camions: ${response.statusCode}');
    }
  }

  static Future<CamionDecharge> createCamion(CamionDecharge camion) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/camiondecharge'),
      headers: ApiService.headers,
      body: json.encode(camion.toJson()),
    );

    if (response.statusCode == 201) {
      return CamionDecharge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create camion: ${response.statusCode}');
    }
  }

  static Future<CamionDecharge> updateCamion(int id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/camiondecharge/$id'),
      headers: ApiService.headers,
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      return CamionDecharge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update camion: ${response.statusCode}');
    }
  }

  static Future<void> deleteCamion(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/camiondecharge/$id'),
      headers: ApiService.headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete camion: ${response.statusCode}');
    }
  }
}
```

### 4. Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Usage in service methods
try {
  final camions = await CamionDechargeService.getAllCamions();
  // Handle success
} on ApiException catch (e) {
  // Handle API errors
  print('API Error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

### 5. UI Implementation Tips

#### Form Validation
- `matCamion`: Required, max 20 characters
- `temperature`: Decimal with 2 decimal places
- `dateCreation`: Optional, defaults to current time if not provided
- Foreign key validation: Ensure `idCamionDecharge` exists before creating tests

#### Data Relationships
- One truck discharge can have multiple quality tests and mold tests
- Always create truck discharge first before adding related tests
- Use the truck discharge ID for creating related tests

#### Offline Support
- Consider caching API responses for offline viewing
- Queue CREATE/UPDATE operations when offline
- Sync when connection is restored

### 6. Dependencies

Add to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  # Add other dependencies as needed
```

---

## Error Responses

All endpoints return consistent error responses:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Bad Request",
  "status": 400,
  "detail": "Error message details"
}
```

Common HTTP Status Codes:
- `200`: Success
- `201`: Created
- `204`: No Content (for deletes)
- `400`: Bad Request (validation errors)
- `404`: Not Found
- `500`: Internal Server Error

---

## Testing

Use tools like Postman or Thunder Client to test endpoints before implementing in Flutter.

### Sample Test Workflow:
1. Create a truck discharge
2. Create quality tests for that truck
3. Create mold tests for that truck
4. Retrieve all data with relationships
5. Update and delete operations

---

This documentation provides everything needed to implement the Fish Industry ERP frontend in Flutter. Contact the backend team for any clarifications or additional endpoints needed.