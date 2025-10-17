// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bateau.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bateau _$BateauFromJson(Map<String, dynamic> json) => Bateau(
  idBateau: (json['id_bateau'] as num?)?.toInt(),
  nomBateau: json['nom_bateau'] as String,
  description: json['description'] as String?,
  dateCreation: DateTime.parse(json['date_creation'] as String),
  dateModification: DateTime.parse(json['date_modification'] as String),
  isSynced: json['is_synced'] as bool? ?? false,
  serverId: (json['server_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$BateauToJson(Bateau instance) => <String, dynamic>{
  'id_bateau': instance.idBateau,
  'nom_bateau': instance.nomBateau,
  'description': instance.description,
  'date_creation': instance.dateCreation.toIso8601String(),
  'date_modification': instance.dateModification.toIso8601String(),
  'is_synced': instance.isSynced,
  'server_id': instance.serverId,
};
