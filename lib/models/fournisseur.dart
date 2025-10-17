import 'package:json_annotation/json_annotation.dart';

part 'fournisseur.g.dart';

@JsonSerializable()
class Fournisseur {
  @JsonKey(name: 'id_fournisseur')
  final int? idFournisseur;

  @JsonKey(name: 'nom_fournisseur')
  final String nomFournisseur;

  @JsonKey(name: 'telephone')
  final String? telephone;

  @JsonKey(name: 'adresse')
  final String? adresse;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'date_creation')
  final DateTime dateCreation;

  @JsonKey(name: 'date_modification')
  final DateTime dateModification;

  @JsonKey(name: 'is_synced')
  final bool isSynced;

  @JsonKey(name: 'server_id')
  final int? serverId;

  Fournisseur({
    this.idFournisseur,
    required this.nomFournisseur,
    this.telephone,
    this.adresse,
    this.email,
    this.description,
    required this.dateCreation,
    required this.dateModification,
    this.isSynced = false,
    this.serverId,
  });

  factory Fournisseur.fromJson(Map<String, dynamic> json) =>
      _$FournisseurFromJson(json);

  factory Fournisseur.fromApiJson(Map<String, dynamic> json) {
    return Fournisseur(
      idFournisseur: json['idFournisseur'],
      nomFournisseur: json['nomFournisseur'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      email: json['email'],
      description: json['description'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      isSynced: json['isSynced'] ?? false,
      serverId: json['serverId'],
    );
  }

  Map<String, dynamic> toJson() => _$FournisseurToJson(this);

  Map<String, dynamic> toApiJson() {
    return {
      if (idFournisseur != null) 'idFournisseur': idFournisseur,
      'nomFournisseur': nomFournisseur,
      if (telephone != null) 'telephone': telephone,
      if (adresse != null) 'adresse': adresse,
      if (email != null) 'email': email,
      if (description != null) 'description': description,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'nom_fournisseur': nomFournisseur,
      'telephone': telephone,
      'adresse': adresse,
      'email': email,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory Fournisseur.fromDatabase(Map<String, dynamic> map) {
    return Fournisseur(
      idFournisseur: map['id_fournisseur'],
      nomFournisseur: map['nom_fournisseur'],
      telephone: map['telephone'],
      adresse: map['adresse'],
      email: map['email'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  Fournisseur copyWith({
    int? idFournisseur,
    String? nomFournisseur,
    String? telephone,
    String? adresse,
    String? email,
    String? description,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return Fournisseur(
      idFournisseur: idFournisseur ?? this.idFournisseur,
      nomFournisseur: nomFournisseur ?? this.nomFournisseur,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      email: email ?? this.email,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }
}
