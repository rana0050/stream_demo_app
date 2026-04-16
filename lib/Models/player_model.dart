class PlayerModel {
  final String id;
  final String name;
  final int? joinedAt; // epoch ms — set when player accepts invite

  PlayerModel({
    required this.id,
    required this.name,
    this.joinedAt,
  });

  factory PlayerModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return PlayerModel(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      joinedAt: map['joinedAt'] as int?,
    );
  }

  //
}
