// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agraige_qualite_tests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgraigeQualiteTests _$AgraigeQualiteTestsFromJson(Map<String, dynamic> json) =>
    AgraigeQualiteTests(
      id: (json['id'] as num?)?.toInt(),
      agraigeA: (json['agraige_a'] as num?)?.toInt(),
      agraigeB: (json['agraige_b'] as num?)?.toInt(),
      agraigeC: (json['agraige_c'] as num?)?.toInt(),
      agraigeMAQ: (json['agraige_maq'] as num?)?.toInt(),
      agraigeCHIN: (json['agraige_chin'] as num?)?.toInt(),
      agraigeFP: (json['agraige_fp'] as num?)?.toInt(),
      agraigeG: (json['agraige_g'] as num?)?.toInt(),
      agraigeAnchois: (json['agraige_anchois'] as num?)?.toInt(),
      petitCaliber: (json['petit_caliber'] as num?)?.toInt(),
      idCamionDecharge: (json['id_camion_decharge'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
      serverId: (json['server_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AgraigeQualiteTestsToJson(
  AgraigeQualiteTests instance,
) => <String, dynamic>{
  'id': instance.id,
  'agraige_a': instance.agraigeA,
  'agraige_b': instance.agraigeB,
  'agraige_c': instance.agraigeC,
  'agraige_maq': instance.agraigeMAQ,
  'agraige_chin': instance.agraigeCHIN,
  'agraige_fp': instance.agraigeFP,
  'agraige_g': instance.agraigeG,
  'agraige_anchois': instance.agraigeAnchois,
  'petit_caliber': instance.petitCaliber,
  'id_camion_decharge': instance.idCamionDecharge,
  'date_creation': instance.dateCreation.toIso8601String(),
  'date_modification': instance.dateModification.toIso8601String(),
  'is_synced': instance.isSynced,
  'server_id': instance.serverId,
};
