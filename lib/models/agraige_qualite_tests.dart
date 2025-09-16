import 'package:json_annotation/json_annotation.dart';

part 'agraige_qualite_tests.g.dart';

@JsonSerializable()
class AgraigeQualiteTests {
  final int? id;

  @JsonKey(name: 'agraige_a')
  final int? agraigeA;

  @JsonKey(name: 'agraige_b')
  final int? agraigeB;

  @JsonKey(name: 'agraige_c')
  final int? agraigeC;

  @JsonKey(name: 'agraige_maq')
  final int? agraigeMAQ;

  @JsonKey(name: 'agraige_chin')
  final int? agraigeCHIN;

  @JsonKey(name: 'agraige_fp')
  final int? agraigeFP;

  @JsonKey(name: 'agraige_g')
  final int? agraigeG;

  @JsonKey(name: 'agraige_anchois')
  final int? agraigeAnchois;

  @JsonKey(name: 'petit_caliber')
  final int? petitCaliber;

  @JsonKey(name: 'id_camion_decharge')
  final int idCamionDecharge;

  @JsonKey(name: 'date_creation')
  final DateTime dateCreation;

  @JsonKey(name: 'date_modification')
  final DateTime dateModification;

  @JsonKey(name: 'is_synced')
  final bool isSynced;

  @JsonKey(name: 'server_id')
  final int? serverId;

  AgraigeQualiteTests({
    this.id,
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
    this.isSynced = false,
    this.serverId,
  });

  factory AgraigeQualiteTests.fromJson(Map<String, dynamic> json) =>
      _$AgraigeQualiteTestsFromJson(json);

  Map<String, dynamic> toJson() => _$AgraigeQualiteTestsToJson(this);

  Map<String, dynamic> toDatabase() {
    return {
      'agraige_a': agraigeA,
      'agraige_b': agraigeB,
      'agraige_c': agraigeC,
      'agraige_maq': agraigeMAQ,
      'agraige_chin': agraigeCHIN,
      'agraige_fp': agraigeFP,
      'agraige_g': agraigeG,
      'agraige_anchois': agraigeAnchois,
      'petit_caliber': petitCaliber,
      'id_camion_decharge': idCamionDecharge,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory AgraigeQualiteTests.fromDatabase(Map<String, dynamic> map) {
    return AgraigeQualiteTests(
      id: map['id'],
      agraigeA: map['agraige_a'],
      agraigeB: map['agraige_b'],
      agraigeC: map['agraige_c'],
      agraigeMAQ: map['agraige_maq'],
      agraigeCHIN: map['agraige_chin'],
      agraigeFP: map['agraige_fp'],
      agraigeG: map['agraige_g'],
      agraigeAnchois: map['agraige_anchois'],
      petitCaliber: map['petit_caliber'],
      idCamionDecharge: map['id_camion_decharge'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  AgraigeQualiteTests copyWith({
    int? id,
    int? agraigeA,
    int? agraigeB,
    int? agraigeC,
    int? agraigeMAQ,
    int? agraigeCHIN,
    int? agraigeFP,
    int? agraigeG,
    int? agraigeAnchois,
    int? petitCaliber,
    int? idCamionDecharge,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return AgraigeQualiteTests(
      id: id ?? this.id,
      agraigeA: agraigeA ?? this.agraigeA,
      agraigeB: agraigeB ?? this.agraigeB,
      agraigeC: agraigeC ?? this.agraigeC,
      agraigeMAQ: agraigeMAQ ?? this.agraigeMAQ,
      agraigeCHIN: agraigeCHIN ?? this.agraigeCHIN,
      agraigeFP: agraigeFP ?? this.agraigeFP,
      agraigeG: agraigeG ?? this.agraigeG,
      agraigeAnchois: agraigeAnchois ?? this.agraigeAnchois,
      petitCaliber: petitCaliber ?? this.petitCaliber,
      idCamionDecharge: idCamionDecharge ?? this.idCamionDecharge,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }

  int get totalQuantity {
    return (agraigeA ?? 0) +
        (agraigeB ?? 0) +
        (agraigeC ?? 0) +
        (agraigeMAQ ?? 0) +
        (agraigeCHIN ?? 0) +
        (agraigeFP ?? 0) +
        (agraigeG ?? 0) +
        (agraigeAnchois ?? 0) +
        (petitCaliber ?? 0);
  }
}