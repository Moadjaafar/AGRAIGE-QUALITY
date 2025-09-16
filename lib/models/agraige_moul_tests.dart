import 'package:json_annotation/json_annotation.dart';

part 'agraige_moul_tests.g.dart';

@JsonSerializable()
class AgraigeMoulTests {
  final int? id;

  @JsonKey(name: 'moul_6_8')
  final int? moul6_8;

  @JsonKey(name: 'moul_8_10')
  final int? moul8_10;

  @JsonKey(name: 'moul_10_12')
  final int? moul10_12;

  @JsonKey(name: 'moul_12_16')
  final int? moul12_16;

  @JsonKey(name: 'moul_16_20')
  final int? moul16_20;

  @JsonKey(name: 'moul_20_26')
  final int? moul20_26;

  @JsonKey(name: 'moul_gt_30')
  final int? moulGt30;

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

  AgraigeMoulTests({
    this.id,
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
    this.isSynced = false,
    this.serverId,
  });

  factory AgraigeMoulTests.fromJson(Map<String, dynamic> json) =>
      _$AgraigeMoulTestsFromJson(json);

  Map<String, dynamic> toJson() => _$AgraigeMoulTestsToJson(this);

  Map<String, dynamic> toDatabase() {
    return {
      'moul_6_8': moul6_8,
      'moul_8_10': moul8_10,
      'moul_10_12': moul10_12,
      'moul_12_16': moul12_16,
      'moul_16_20': moul16_20,
      'moul_20_26': moul20_26,
      'moul_gt_30': moulGt30,
      'id_camion_decharge': idCamionDecharge,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory AgraigeMoulTests.fromDatabase(Map<String, dynamic> map) {
    return AgraigeMoulTests(
      id: map['id'],
      moul6_8: map['moul_6_8'],
      moul8_10: map['moul_8_10'],
      moul10_12: map['moul_10_12'],
      moul12_16: map['moul_12_16'],
      moul16_20: map['moul_16_20'],
      moul20_26: map['moul_20_26'],
      moulGt30: map['moul_gt_30'],
      idCamionDecharge: map['id_camion_decharge'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  AgraigeMoulTests copyWith({
    int? id,
    int? moul6_8,
    int? moul8_10,
    int? moul10_12,
    int? moul12_16,
    int? moul16_20,
    int? moul20_26,
    int? moulGt30,
    int? idCamionDecharge,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return AgraigeMoulTests(
      id: id ?? this.id,
      moul6_8: moul6_8 ?? this.moul6_8,
      moul8_10: moul8_10 ?? this.moul8_10,
      moul10_12: moul10_12 ?? this.moul10_12,
      moul12_16: moul12_16 ?? this.moul12_16,
      moul16_20: moul16_20 ?? this.moul16_20,
      moul20_26: moul20_26 ?? this.moul20_26,
      moulGt30: moulGt30 ?? this.moulGt30,
      idCamionDecharge: idCamionDecharge ?? this.idCamionDecharge,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }

  int get totalQuantity {
    return (moul6_8 ?? 0) +
        (moul8_10 ?? 0) +
        (moul10_12 ?? 0) +
        (moul12_16 ?? 0) +
        (moul16_20 ?? 0) +
        (moul20_26 ?? 0) +
        (moulGt30 ?? 0);
  }

  Map<String, int> get sizeDistribution {
    return {
      '6-8mm': moul6_8 ?? 0,
      '8-10mm': moul8_10 ?? 0,
      '10-12mm': moul10_12 ?? 0,
      '12-16mm': moul12_16 ?? 0,
      '16-20mm': moul16_20 ?? 0,
      '20-26mm': moul20_26 ?? 0,
      '>30mm': moulGt30 ?? 0,
    };
  }
}