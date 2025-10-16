// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camion_decharge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CamionDecharge _$CamionDechargeFromJson(Map<String, dynamic> json) =>
    CamionDecharge(
      idDecharge: (json['id_decharge'] as num?)?.toInt(),
      matCamion: json['mat_camion'] as String,
      bateau: json['bateau'] as String?,
      maree: json['maree'] as String?,
      heureDecharge: json['heure_decharge'] == null
          ? null
          : DateTime.parse(json['heure_decharge'] as String),
      heureTraitement: json['heure_traitement'] == null
          ? null
          : DateTime.parse(json['heure_traitement'] as String),
      temperature: (json['temperature'] as num?)?.toDouble(),
      poisDecharge: (json['pois_decharge'] as num?)?.toDouble(),
      nbrAgraigeQualite: (json['nbr_agraige_qualite'] as num?)?.toInt(),
      nbrAgraigeMoule: (json['nbr_agraige_moule'] as num?)?.toInt(),
      isExported: json['is_exported'] as bool? ?? false,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      isSynced: json['is_synced'] as bool? ?? false,
      serverId: (json['server_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CamionDechargeToJson(CamionDecharge instance) =>
    <String, dynamic>{
      'id_decharge': instance.idDecharge,
      'mat_camion': instance.matCamion,
      'bateau': instance.bateau,
      'maree': instance.maree,
      'heure_decharge': instance.heureDecharge?.toIso8601String(),
      'heure_traitement': instance.heureTraitement?.toIso8601String(),
      'temperature': instance.temperature,
      'pois_decharge': instance.poisDecharge,
      'nbr_agraige_qualite': instance.nbrAgraigeQualite,
      'nbr_agraige_moule': instance.nbrAgraigeMoule,
      'is_exported': instance.isExported,
      'date_creation': instance.dateCreation.toIso8601String(),
      'date_modification': instance.dateModification.toIso8601String(),
      'is_synced': instance.isSynced,
      'server_id': instance.serverId,
    };
