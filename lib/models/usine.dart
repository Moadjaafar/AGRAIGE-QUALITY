import 'package:json_annotation/json_annotation.dart';

part 'usine.g.dart';

@JsonSerializable()
class Usine {
  @JsonKey(name: 'id_usine')
  final int? idUsine;

  @JsonKey(name: 'nom_usine')
  final String nomUsine;

  @JsonKey(name: 'adresse')
  final String? adresse;

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

  Usine({
    this.idUsine,
    required this.nomUsine,
    this.adresse,
    this.description,
    required this.dateCreation,
    required this.dateModification,
    this.isSynced = false,
    this.serverId,
  });

  factory Usine.fromJson(Map<String, dynamic> json) =>
      _$UsineFromJson(json);

  factory Usine.fromApiJson(Map<String, dynamic> json) {
    return Usine(
      idUsine: json['idUsine'],
      nomUsine: json['nomUsine'],
      adresse: json['adresse'],
      description: json['description'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      isSynced: json['isSynced'] ?? false,
      serverId: json['serverId'],
    );
  }

  Map<String, dynamic> toJson() => _$UsineToJson(this);

  Map<String, dynamic> toApiJson() {
    return {
      if (idUsine != null) 'idUsine': idUsine,
      'nomUsine': nomUsine,
      if (adresse != null) 'adresse': adresse,
      if (description != null) 'description': description,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'nom_usine': nomUsine,
      'adresse': adresse,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory Usine.fromDatabase(Map<String, dynamic> map) {
    return Usine(
      idUsine: map['id_usine'],
      nomUsine: map['nom_usine'],
      adresse: map['adresse'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  Usine copyWith({
    int? idUsine,
    String? nomUsine,
    String? adresse,
    String? description,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return Usine(
      idUsine: idUsine ?? this.idUsine,
      nomUsine: nomUsine ?? this.nomUsine,
      adresse: adresse ?? this.adresse,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }
}
