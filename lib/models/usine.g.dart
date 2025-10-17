// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usine _$UsineFromJson(Map<String, dynamic> json) => Usine(
  idUsine: (json['id_usine'] as num?)?.toInt(),
  nomUsine: json['nom_usine'] as String,
  adresse: json['adresse'] as String?,
  description: json['description'] as String?,
  dateCreation: DateTime.parse(json['date_creation'] as String),
  dateModification: DateTime.parse(json['date_modification'] as String),
  isSynced: json['is_synced'] as bool? ?? false,
  serverId: (json['server_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UsineToJson(Usine instance) => <String, dynamic>{
  'id_usine': instance.idUsine,
  'nom_usine': instance.nomUsine,
  'adresse': instance.adresse,
  'description': instance.description,
  'date_creation': instance.dateCreation.toIso8601String(),
  'date_modification': instance.dateModification.toIso8601String(),
  'is_synced': instance.isSynced,
  'server_id': instance.serverId,
};
