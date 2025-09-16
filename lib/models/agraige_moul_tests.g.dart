// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agraige_moul_tests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgraigeMoulTests _$AgraigeMoulTestsFromJson(Map<String, dynamic> json) =>
    AgraigeMoulTests(
      id: (json['id'] as num?)?.toInt(),
      moul6_8: (json['moul_6_8'] as num?)?.toInt(),
      moul8_10: (json['moul_8_10'] as num?)?.toInt(),
      moul10_12: (json['moul_10_12'] as num?)?.toInt(),
      moul12_16: (json['moul_12_16'] as num?)?.toInt(),
      moul16_20: (json['moul_16_20'] as num?)?.toInt(),
      moul20_26: (json['moul_20_26'] as num?)?.toInt(),
      moulGt30: (json['moul_gt_30'] as num?)?.toInt(),
      idCamionDecharge: (json['id_camion_decharge'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
      serverId: (json['server_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AgraigeMoulTestsToJson(AgraigeMoulTests instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moul_6_8': instance.moul6_8,
      'moul_8_10': instance.moul8_10,
      'moul_10_12': instance.moul10_12,
      'moul_12_16': instance.moul12_16,
      'moul_16_20': instance.moul16_20,
      'moul_20_26': instance.moul20_26,
      'moul_gt_30': instance.moulGt30,
      'id_camion_decharge': instance.idCamionDecharge,
      'date_creation': instance.dateCreation.toIso8601String(),
      'date_modification': instance.dateModification.toIso8601String(),
      'is_synced': instance.isSynced,
      'server_id': instance.serverId,
    };
