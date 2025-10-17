import 'package:json_annotation/json_annotation.dart';

part 'camion_decharge.g.dart';

@JsonSerializable()
class CamionDecharge {
  @JsonKey(name: 'id_decharge')
  final int? idDecharge;

  @JsonKey(name: 'mat_camion')
  final String matCamion;

  final String? bateau;
  final String? fournisseur;
  final String? usine;
  final String? maree;

  @JsonKey(name: 'heure_decharge')
  final DateTime? heureDecharge;

  @JsonKey(name: 'heure_traitement')
  final DateTime? heureTraitement;

  final double? temperature;

  @JsonKey(name: 'pois_decharge')
  final double? poisDecharge;

  @JsonKey(name: 'poids_unitaire_carton')
  final int? poidsUnitaireCarton;

  @JsonKey(name: 'nbr_agraige_qualite')
  final int? nbrAgraigeQualite;

  @JsonKey(name: 'nbr_agraige_moule')
  final int? nbrAgraigeMoule;

  @JsonKey(name: 'is_exported')
  final bool isExported;

  @JsonKey(name: 'date_creation')
  final DateTime dateCreation;

  @JsonKey(name: 'date_modification')
  final DateTime dateModification;

  @JsonKey(name: 'is_synced')
  final bool isSynced;

  @JsonKey(name: 'server_id')
  final int? serverId;

  CamionDecharge({
    this.idDecharge,
    required this.matCamion,
    this.bateau,
    this.fournisseur,
    this.usine,
    this.maree,
    this.heureDecharge,
    this.heureTraitement,
    this.temperature,
    this.poisDecharge,
    this.poidsUnitaireCarton,
    this.nbrAgraigeQualite,
    this.nbrAgraigeMoule,
    this.isExported = false,
    required this.dateCreation,
    required this.dateModification,
    this.isSynced = false,
    this.serverId,
  });

  factory CamionDecharge.fromJson(Map<String, dynamic> json) =>
      _$CamionDechargeFromJson(json);

  factory CamionDecharge.fromApiJson(Map<String, dynamic> json) {
    return CamionDecharge(
      idDecharge: json['idDecharge'],
      matCamion: json['matCamion'],
      bateau: json['bateau'],
      fournisseur: json['fournisseur'],
      usine: json['usine'],
      maree: json['maree'],
      heureDecharge: json['heureDecharge'] != null
          ? DateTime.parse(json['heureDecharge'])
          : null,
      heureTraitement: json['heureTraitement'] != null
          ? DateTime.parse(json['heureTraitement'])
          : null,
      temperature: json['temperature']?.toDouble(),
      poisDecharge: json['poisDecharge']?.toDouble(),
      poidsUnitaireCarton: json['poidsUnitaireCarton'],
      nbrAgraigeQualite: json['nbrAgraigeQualite'],
      nbrAgraigeMoule: json['nbrAgraigeMoule'],
      isExported: json['isExported'] ?? false,
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      isSynced: json['isSynced'] ?? false,
      serverId: json['serverId'],
    );
  }

  Map<String, dynamic> toJson() => _$CamionDechargeToJson(this);

  Map<String, dynamic> toApiJson() {
    return {
      if (idDecharge != null) 'idDecharge': idDecharge,
      'matCamion': matCamion,
      if (bateau != null) 'bateau': bateau,
      if (fournisseur != null) 'fournisseur': fournisseur,
      if (usine != null) 'usine': usine,
      if (maree != null) 'maree': maree,
      if (heureDecharge != null) 'heureDecharge': heureDecharge!.toIso8601String(),
      if (heureTraitement != null) 'heureTraitement': heureTraitement!.toIso8601String(),
      if (temperature != null) 'temperature': temperature,
      if (poisDecharge != null) 'poisDecharge': poisDecharge,
      if (poidsUnitaireCarton != null) 'poidsUnitaireCarton': poidsUnitaireCarton,
      if (nbrAgraigeQualite != null) 'nbrAgraigeQualite': nbrAgraigeQualite,
      if (nbrAgraigeMoule != null) 'nbrAgraigeMoule': nbrAgraigeMoule,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'mat_camion': matCamion,
      'bateau': bateau,
      'fournisseur': fournisseur,
      'usine': usine,
      'maree': maree,
      'heure_decharge': heureDecharge?.toIso8601String(),
      'heure_traitement': heureTraitement?.toIso8601String(),
      'temperature': temperature,
      'pois_decharge': poisDecharge,
      'poids_unitaire_carton': poidsUnitaireCarton,
      'nbr_agraige_qualite': nbrAgraigeQualite,
      'nbr_agraige_moule': nbrAgraigeMoule,
      'is_exported': isExported ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory CamionDecharge.fromDatabase(Map<String, dynamic> map) {
    return CamionDecharge(
      idDecharge: map['id_decharge'],
      matCamion: map['mat_camion'],
      bateau: map['bateau'],
      fournisseur: map['fournisseur'],
      usine: map['usine'],
      maree: map['maree'],
      heureDecharge: map['heure_decharge'] != null
          ? DateTime.parse(map['heure_decharge'])
          : null,
      heureTraitement: map['heure_traitement'] != null
          ? DateTime.parse(map['heure_traitement'])
          : null,
      temperature: map['temperature']?.toDouble(),
      poisDecharge: map['pois_decharge']?.toDouble(),
      poidsUnitaireCarton: map['poids_unitaire_carton'],
      nbrAgraigeQualite: map['nbr_agraige_qualite'],
      nbrAgraigeMoule: map['nbr_agraige_moule'],
      isExported: map['is_exported'] == 1,
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  CamionDecharge copyWith({
    int? idDecharge,
    String? matCamion,
    String? bateau,
    String? fournisseur,
    String? usine,
    String? maree,
    DateTime? heureDecharge,
    DateTime? heureTraitement,
    double? temperature,
    double? poisDecharge,
    int? poidsUnitaireCarton,
    int? nbrAgraigeQualite,
    int? nbrAgraigeMoule,
    bool? isExported,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return CamionDecharge(
      idDecharge: idDecharge ?? this.idDecharge,
      matCamion: matCamion ?? this.matCamion,
      bateau: bateau ?? this.bateau,
      fournisseur: fournisseur ?? this.fournisseur,
      usine: usine ?? this.usine,
      maree: maree ?? this.maree,
      heureDecharge: heureDecharge ?? this.heureDecharge,
      heureTraitement: heureTraitement ?? this.heureTraitement,
      temperature: temperature ?? this.temperature,
      poisDecharge: poisDecharge ?? this.poisDecharge,
      poidsUnitaireCarton: poidsUnitaireCarton ?? this.poidsUnitaireCarton,
      nbrAgraigeQualite: nbrAgraigeQualite ?? this.nbrAgraigeQualite,
      nbrAgraigeMoule: nbrAgraigeMoule ?? this.nbrAgraigeMoule,
      isExported: isExported ?? this.isExported,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }
}