// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fournisseur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fournisseur _$FournisseurFromJson(Map<String, dynamic> json) => Fournisseur(
  idFournisseur: (json['id_fournisseur'] as num?)?.toInt(),
  nomFournisseur: json['nom_fournisseur'] as String,
  telephone: json['telephone'] as String?,
  adresse: json['adresse'] as String?,
  email: json['email'] as String?,
  description: json['description'] as String?,
  dateCreation: DateTime.parse(json['date_creation'] as String),
  dateModification: DateTime.parse(json['date_modification'] as String),
  isSynced: json['is_synced'] as bool? ?? false,
  serverId: (json['server_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$FournisseurToJson(Fournisseur instance) =>
    <String, dynamic>{
      'id_fournisseur': instance.idFournisseur,
      'nom_fournisseur': instance.nomFournisseur,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'email': instance.email,
      'description': instance.description,
      'date_creation': instance.dateCreation.toIso8601String(),
      'date_modification': instance.dateModification.toIso8601String(),
      'is_synced': instance.isSynced,
      'server_id': instance.serverId,
    };
