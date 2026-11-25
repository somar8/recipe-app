/// Someone you're friends with.
class Friend {
  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.since,
  });

  final String id;
  final String name;
  final String email;
  final DateTime? since;

  factory Friend.fromDb(Map<String, dynamic> row) => Friend(
    id: row['id'] as String,
    name: (row['display_name'] as String?)?.trim().isNotEmpty == true
        ? row['display_name'] as String
        : (row['email'] as String? ?? '').split('@').first,
    email: row['email'] as String? ?? '',
    since: DateTime.tryParse(row['since'] as String? ?? ''),
  );

  String get initial =>
      name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
}

/// A friend request waiting for you.
class IncomingRequest {
  IncomingRequest({required this.id, required this.from});

  final int id;
  final Friend from;

  factory IncomingRequest.fromDb(Map<String, dynamic> row) => IncomingRequest(
    id: (row['id'] as num).toInt(),
    from: Friend.fromDb((row['sender'] as Map).cast<String, dynamic>()),
  );
}

/// A friend request you sent that hasn't been answered yet.
class SentRequest {
  SentRequest({required this.id, required this.email});

  final int id;
  final String email;

  factory SentRequest.fromDb(Map<String, dynamic> row) => SentRequest(
    id: (row['id'] as num).toInt(),
    email: row['to_email'] as String,
  );
}
