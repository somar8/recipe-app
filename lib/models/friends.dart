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
  SentRequest({required this.id, required this.label, this.name});

  final int id;

  /// The address you typed, or only a hint like "an***@gmail.com" for someone you
  /// picked from the search.
  final String label;

  /// Their name, when you picked them from the search.
  final String? name;

  factory SentRequest.fromDb(Map<String, dynamic> row) => SentRequest(
    id: (row['id'] as num).toInt(),
    label: row['email_label'] as String? ?? '',
    name: row['display_name'] as String?,
  );
}

/// Someone found while typing in "Add a friend". Their email is only shown as a hint
/// ("an***@gmail.com"): the database never sends full addresses of other people.
class PersonMatch {
  PersonMatch({
    required this.id,
    required this.name,
    required this.emailHint,
    required this.status,
  });

  final String id;
  final String name;
  final String emailHint;

  /// 'none', 'friend', 'sent' (you asked them) or 'received' (they asked you).
  final String status;

  factory PersonMatch.fromDb(Map<String, dynamic> row) => PersonMatch(
    id: row['id'] as String,
    name: (row['display_name'] as String?)?.trim().isNotEmpty == true
        ? row['display_name'] as String
        : (row['email_hint'] as String? ?? '').split('@').first,
    emailHint: row['email_hint'] as String? ?? '',
    status: row['status'] as String? ?? 'none',
  );
}
