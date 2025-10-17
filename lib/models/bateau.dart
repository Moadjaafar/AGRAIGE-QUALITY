import 'package:json_annotation/json_annotation.dart';

part 'bateau.g.dart';

@JsonSerializable()
class Bateau {
  @JsonKey(name: 'id_bateau')
  final int? idBateau;

  @JsonKey(name: 'nom_bateau')
  final String nomBateau;

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

  Bateau({
    this.idBateau,
    required this.nomBateau,
    this.description,
    required this.dateCreation,
    required this.dateModification,
    this.isSynced = false,
    this.serverId,
  });

  factory Bateau.fromJson(Map<String, dynamic> json) =>
      _$BateauFromJson(json);

  factory Bateau.fromApiJson(Map<String, dynamic> json) {
    return Bateau(
      idBateau: json['idBateau'],
      nomBateau: json['nomBateau'],
      description: json['description'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: DateTime.parse(json['dateModification']),
      isSynced: json['isSynced'] ?? false,
      serverId: json['serverId'],
    );
  }

  Map<String, dynamic> toJson() => _$BateauToJson(this);

  Map<String, dynamic> toApiJson() {
    return {
      if (idBateau != null) 'idBateau': idBateau,
      'nomBateau': nomBateau,
      if (description != null) 'description': description,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'nom_bateau': nomBateau,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  factory Bateau.fromDatabase(Map<String, dynamic> map) {
    return Bateau(
      idBateau: map['id_bateau'],
      nomBateau: map['nom_bateau'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'],
    );
  }

  Bateau copyWith({
    int? idBateau,
    String? nomBateau,
    String? description,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? isSynced,
    int? serverId,
  }) {
    return Bateau(
      idBateau: idBateau ?? this.idBateau,
      nomBateau: nomBateau ?? this.nomBateau,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      isSynced: isSynced ?? this.isSynced,
      serverId: serverId ?? this.serverId,
    );
  }
}
