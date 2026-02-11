import 'package:equatable/equatable.dart';

class CharacterList extends Equatable {
  final List<Character>? results;

  const CharacterList({this.results});

  @override
  List<Object?> get props => [results];

  factory CharacterList.fromJson(Map<String, dynamic> json) {
    return CharacterList(
      results: json['results'] != null
          ? (json['results'] as List).map((i) => Character.fromJson(i)).toList()
          : null,
    );
  }
}

class Character extends Equatable {
  final int? id;
  final String? name;
  final String? status;
  final String? species;
  final String? type;
  final String? gender;
  final CharacterLocation? origin;
  final CharacterLocation? location;
  final String? image;
  final List<String>? episode;
  final String? url;
  final String? created;

  const Character({
    this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.origin,
    this.location,
    this.image,
    this.episode,
    this.url,
    this.created,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    species,
    type,
    gender,
    origin,
    location,
    image,
    episode,
    url,
    created,
  ];

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      type: json['type'],
      gender: json['gender'],
      origin: json['origin'] != null ? CharacterLocation.fromJson(json['origin']) : null,
      location: json['location'] != null ? CharacterLocation.fromJson(json['location']) : null,
      image: json['image'],
      episode: json['episode'] != null ? List<String>.from(json['episode']) : null,
      url: json['url'],
      created: json['created'],
    );
  }
}

class CharacterLocation extends Equatable {
  final String? name;
  final String? url;

  const CharacterLocation({this.name, this.url});

  @override
  List<Object?> get props => [name, url];

  factory CharacterLocation.fromJson(Map<String, dynamic> json) {
    return CharacterLocation(
      name: json['name'],
      url: json['url'],
    );
  }
}
