class CharacterList {
  final List<Character>? results;

  CharacterList({this.results});

  CharacterList copyWith({List<Character>? results}) {
    return CharacterList(
      results: results ?? this.results,
    );
  }

  factory CharacterList.fromJson(Map<String, dynamic> json) {
    return CharacterList(
      results: json['results'] != null
          ? (json['results'] as List).map((i) => Character.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }

  @override
  String toString() => 'CharacterList(results: ${results?.length} items)';
}

class Character {
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

  Character({
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

  Character copyWith({
    int? id,
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
    CharacterLocation? origin,
    CharacterLocation? location,
    String? image,
    List<String>? episode,
    String? url,
    String? created,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      origin: origin ?? this.origin,
      location: location ?? this.location,
      image: image ?? this.image,
      episode: episode ?? this.episode,
      url: url ?? this.url,
      created: created ?? this.created,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': origin?.toJson(),
      'location': location?.toJson(),
      'image': image,
      'episode': episode,
      'url': url,
      'created': created,
    };
  }

  @override
  String toString() => 'Character(id: $id, name: $name, status: $status)';
}

class CharacterLocation {
  final String? name;
  final String? url;

  CharacterLocation({this.name, this.url});

  CharacterLocation copyWith({String? name, String? url}) {
    return CharacterLocation(
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  factory CharacterLocation.fromJson(Map<String, dynamic> json) {
    return CharacterLocation(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  @override
  String toString() => 'CharacterLocation(name: $name, url: $url)';
}