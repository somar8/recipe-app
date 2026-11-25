// Demo mode only: a pretend Supabase that keeps everything in memory, so the app can be
// tried and screenshotted without a real project. Never used by the real app (lib/main.dart).
//
// You are "Samer". Your friend Anna shared one recipe and one collection with you, and
// Bram has sent you a friend request. The visibility rules mirror supabase/schema.sql.
import 'dart:convert';
import 'package:http/http.dart' as http;

class DemoBackend extends http.BaseClient {
  DemoBackend() {
    _seed();
  }

  /// Function names to answer with 404, like a project whose setup is out of date.
  final missingFunctions = <String>{};

  static const _me = '00000000-0000-4000-8000-000000000001';
  static const _anna = '00000000-0000-4000-8000-000000000002';
  static const _bram = '00000000-0000-4000-8000-000000000003';

  final _people = <String, Map<String, String>>{
    _me: {'display_name': 'Samer', 'email': 'demo@example.com'},
    _anna: {'display_name': 'Anna', 'email': 'anna@example.com'},
    _bram: {'display_name': 'Bram', 'email': 'bram@example.com'},
    // People to find with the search in Account -> Friends.
    '00000000-0000-4000-8000-000000000004': {
      'display_name': 'Anneke Jansen',
      'email': 'anneke.jansen@example.com',
    },
    '00000000-0000-4000-8000-000000000005': {
      'display_name': 'Annabel Smit',
      'email': 'bel@example.com',
    },
    '00000000-0000-4000-8000-000000000006': {
      'display_name': 'Jan de Boer',
      'email': 'jan.deboer@example.com',
    },
    '00000000-0000-4000-8000-000000000007': {
      'display_name': 'Joost Visser',
      'email': 'jv@example.com',
    },
  };

  /// Like the database: "an***@gmail.com", or "j***@…" for very short names.
  static String _hint(String email) {
    final at = email.indexOf('@');
    return '${email.substring(0, at <= 2 ? 1 : 2)}***${email.substring(at)}';
  }

  String _statusOf(String id) {
    if (_friends.contains(id)) return 'friend';
    if (_sent.containsValue(_people[id]!['email'])) return 'sent';
    if (_incoming.containsValue(id)) return 'received';
    return 'none';
  }

  final _recipes = <int, Map<String, dynamic>>{};
  final _groups = <int, Map<String, dynamic>>{};
  final _items = <(int, int)>{}; // (group id, recipe id)
  final _friends = <String>{_anna};
  final _incoming = <int, String>{1: _bram}; // request id -> sender
  final _sent = <int, String>{}; // request id -> email
  final _sentTo =
      <int, String>{}; // request id -> person, when picked from the search
  final _recipeShares = <(int, String)>{}; // (recipe id, friend id)
  final _collectionShares = <(int, String)>{}; // (group id, friend id)
  var _nextId = 100;
  var _nextRequest = 2;
  Map<String, dynamic> _metadata = {
    'first_name': 'Samer',
    'last_name': 'Haddad',
    'username': 'Samer Haddad',
  };

  void _addRecipe(
    String title,
    String? description,
    int? prep,
    int? cook,
    int? servings,
    List<List<String?>> ingredients,
    String? steps, {
    String owner = _me,
  }) {
    final id = _nextId++;
    _recipes[id] = {
      'id': id,
      'user_id': owner,
      'title': title,
      'description': description,
      'instructions': steps,
      'prep_time_minutes': prep,
      'cook_time_minutes': cook,
      'servings': servings,
      'recipe_ingredients': [
        for (var i = 0; i < ingredients.length; i++)
          {
            'id': id * 100 + i,
            'position': i,
            'name': ingredients[i][0],
            'quantity': ingredients[i][1],
            'unit': ingredients[i][2],
          },
      ],
    };
  }

  int _addGroup(String name, String description, {String owner = _me}) {
    final id = _nextId++;
    _groups[id] = {
      'id': id,
      'user_id': owner,
      'name': name,
      'description': description,
    };
    return id;
  }

  void _seed() {
    _addRecipe(
      'Fluffy pancakes',
      'Sunday breakfast classic',
      10,
      10,
      4,
      [
        ['Flour', '200', 'g'],
        ['Buttermilk', '300', 'ml'],
        ['Eggs', '2', null],
        ['Sugar', '2', 'tbsp'],
        ['Butter', '30', 'g'],
      ],
      '1. Whisk the flour, buttermilk, eggs and sugar until smooth.\n2. Rest the batter for 10 minutes.\n3. Melt a little butter in a pan over medium heat.\n4. Pour small circles of batter and cook until bubbles appear, then flip.\n5. Serve warm with syrup or fruit.',
    ); // 100
    _addRecipe(
      'Roasted tomato soup',
      'Sweet, smoky and ready in under an hour',
      15,
      40,
      4,
      [
        ['Tomatoes', '1', 'kg'],
        ['Red onion', '1', null],
        ['Garlic', '3', 'cloves'],
        ['Vegetable stock', '500', 'ml'],
        ['Basil', '1', 'bunch'],
      ],
      'Roast the tomatoes, onion and garlic at 200 °C for 30 minutes.\nBlend with the stock until smooth.\nSeason and finish with torn basil.',
    ); // 101
    _addRecipe(
      'Greek salad',
      'Quick lunch',
      10,
      null,
      2,
      [
        ['Cucumber', '1', null],
        ['Tomatoes', '3', null],
        ['Feta', '150', 'g'],
        ['Olives', '1', 'handful'],
      ],
      'Chop the vegetables.\nCrumble over the feta and add the olives.\nDress with olive oil and oregano.',
    ); // 102
    _addRecipe(
      'Spaghetti carbonara',
      'Creamy without cream',
      10,
      15,
      2,
      [
        ['Spaghetti', '200', 'g'],
        ['Guanciale', '100', 'g'],
        ['Egg yolks', '3', null],
        ['Pecorino', '50', 'g'],
      ],
      'Cook the pasta.\nCrisp the guanciale.\nMix yolks and cheese, then toss everything off the heat.',
    ); // 103
    _addRecipe(
      'Kipsoep',
      'Dutch chicken soup, like oma made',
      20,
      90,
      6,
      [
        ['Soup chicken', '1', null],
        ['Leek', '1', null],
        ['Carrots', '2', null],
        ['Vermicelli', '50', 'g'],
      ],
      'Simmer the chicken with the vegetables for 90 minutes.\nStrain, pull the meat and return it to the broth.\nAdd vermicelli for the last 5 minutes.',
    ); // 104
    _addRecipe(
      'Banana bread',
      null,
      15,
      60,
      8,
      [
        ['Ripe bananas', '3', null],
        ['Flour', '250', 'g'],
        ['Brown sugar', '120', 'g'],
        ['Eggs', '2', null],
      ],
      'Mash the bananas.\nMix in the rest.\nBake at 175 °C for an hour.',
    ); // 105
    final breakfast = _addGroup('Breakfast', 'Slow weekend mornings'); // 106
    final weeknight = _addGroup(
      'Weeknight dinners',
      'On the table in 30 minutes',
    ); // 107
    _items.addAll({
      (breakfast, 100),
      (breakfast, 105),
      (weeknight, 102),
      (weeknight, 103),
    });

    // Anna's kitchen.
    _addRecipe(
      'Shakshuka',
      'Eggs in spicy tomato sauce',
      10,
      20,
      2,
      [
        ['Eggs', '4', null],
        ['Chopped tomatoes', '1', 'tin'],
        ['Red pepper', '1', null],
        ['Cumin', '1', 'tsp'],
      ],
      'Soften the pepper.\nAdd tomatoes and cumin, simmer 10 minutes.\nCrack in the eggs, cover until set.',
      owner: _anna,
    ); // 108
    _addRecipe(
      'Lemon drizzle cake',
      'Anna\'s birthday favourite',
      20,
      45,
      10,
      [
        ['Butter', '225', 'g'],
        ['Sugar', '225', 'g'],
        ['Eggs', '4', null],
        ['Lemons', '2', null],
      ],
      'Cream butter and sugar.\nBeat in eggs, fold in flour and zest.\nBake 45 minutes, then drizzle with lemon syrup.',
      owner: _anna,
    ); // 109
    final annasBaking = _addGroup(
      'Anna\'s baking',
      'Weekend bakes',
      owner: _anna,
    ); // 110
    _items.add((annasBaking, 109));
    _addRecipe(
      'Secret curry',
      'Not shared',
      15,
      30,
      4,
      [
        ['Curry paste', '2', 'tbsp'],
      ],
      'Secret.',
      owner: _anna,
    ); // 111
    _recipeShares.add((108, _me));
    _collectionShares.add((annasBaking, _me));
  }

  // ---- Visibility, as in the database's access rules ----
  bool _canSeeGroup(int gid) =>
      _groups[gid]?['user_id'] == _me || _collectionShares.contains((gid, _me));

  bool _canSeeRecipe(int rid) =>
      _recipes[rid]?['user_id'] == _me ||
      _recipeShares.contains((rid, _me)) ||
      _items.any((x) => x.$2 == rid && _collectionShares.contains((x.$1, _me)));

  Map<String, dynamic> _withOwner(Map<String, dynamic> row) => {
    ...row,
    'owner': {'display_name': _people[row['user_id']]?['display_name']},
  };

  Map<String, dynamic> _groupJson(Map<String, dynamic> g) => _withOwner({
    ...g,
    'recipes': [
      for (final (gid, rid) in _items)
        if (gid == g['id'] && _recipes.containsKey(rid)) _recipes[rid],
    ],
  });

  Map<String, dynamic> get _user => {
    'id': _me,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'demo@example.com',
    'email_confirmed_at': '2026-01-01T00:00:00Z',
    'created_at': '2026-01-01T00:00:00Z',
    'app_metadata': {'provider': 'email'},
    'user_metadata': _metadata,
    'identities': [],
  };

  String _jwt() {
    String part(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    final exp =
        DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/
        1000;
    return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part({'sub': _me, 'exp': exp, 'role': 'authenticated', 'aud': 'authenticated', 'email': 'demo@example.com'})}.demo';
  }

  Map<String, dynamic> get _session => {
    'access_token': _jwt(),
    'token_type': 'bearer',
    'expires_in': 31536000,
    'expires_at':
        DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/
        1000,
    'refresh_token': 'demo-refresh',
    'user': _user,
  };

  int? _eqInt(Uri uri, String key) => int.tryParse(_eqStr(uri, key) ?? '');

  String? _eqStr(Uri uri, String key) {
    final v = uri.queryParameters[key];
    return v != null && v.startsWith('eq.') ? v.substring(3) : null;
  }

  /// `in.("a","b")` or `in.(a,b)` -> {a, b}
  Set<String> _inList(Uri uri, String key) {
    final v = uri.queryParameters[key];
    if (v == null || !v.startsWith('in.(')) return {};
    return v
        .substring(4, v.length - 1)
        .split(',')
        .map((s) => s.replaceAll('"', '').trim())
        .toSet();
  }

  void _unfriend(String other) {
    _friends.remove(other);
    _recipeShares.removeWhere(
      (s) =>
          (s.$2 == other && _recipes[s.$1]?['user_id'] == _me) ||
          (s.$2 == _me && _recipes[s.$1]?['user_id'] == other),
    );
    _collectionShares.removeWhere(
      (s) =>
          (s.$2 == other && _groups[s.$1]?['user_id'] == _me) ||
          (s.$2 == _me && _groups[s.$1]?['user_id'] == other),
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    ); // feel like a network
    final body = request is http.Request && request.body.isNotEmpty
        ? jsonDecode(request.body)
        : null;
    final wantsObject = (request.headers['Accept'] ?? '').contains(
      'vnd.pgrst.object',
    );
    final (status, result) = _handle(request.method, request.url, body);
    final out = result == null
        ? null
        : (wantsObject && result is List
              ? (result.isEmpty ? null : result.first)
              : result);
    return http.StreamedResponse(
      Stream.value(out == null ? <int>[] : utf8.encode(jsonEncode(out))),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }

  (int, Object?) _handle(String method, Uri uri, Object? body) {
    final path = uri.path;
    // Tests can pretend the project's database is older and lacks some functions.
    final rpc = path.contains('/rpc/') ? path.split('/rpc/').last : null;
    if (rpc != null && missingFunctions.contains(rpc)) {
      return (
        404,
        {
          'code': 'PGRST202',
          'message': 'Could not find the function public.$rpc',
        },
      );
    }
    // ---- Auth ----
    if (path.endsWith('/auth/v1/token')) return (200, _session);
    if (path.endsWith('/auth/v1/user')) {
      if (method == 'PUT' && body is Map && body['data'] is Map) {
        _metadata = {
          ..._metadata,
          ...(body['data'] as Map).cast<String, dynamic>(),
        };
        // Like the database: "First Last", else the older single name.
        final full = [_metadata['first_name'], _metadata['last_name']]
            .whereType<String>()
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .join(' ');
        final name = full.isNotEmpty ? full : _metadata['username'];
        if (name is String) _people[_me]!['display_name'] = name;
      }
      return (200, _user);
    }
    if (path.endsWith('/auth/v1/logout')) return (204, null);

    // ---- Functions ----
    if (path.endsWith('/rpc/ping')) return (200, 'ok');
    if (path.endsWith('/rpc/save_recipe')) {
      final r = ((body as Map)['recipe'] as Map).cast<String, dynamic>();
      final id = (r['id'] as num?)?.toInt() ?? _nextId++;
      if (_recipes.containsKey(id) && _recipes[id]!['user_id'] != _me) {
        return (400, {'code': 'P0002', 'message': 'Recipe not found.'});
      }
      final ingredients = (r['ingredients'] as List? ?? const []).cast<Map>();
      _recipes[id] = {
        'id': id,
        'user_id': _me,
        'title': r['title'],
        'description': r['description'],
        'instructions': r['instructions'],
        'prep_time_minutes': r['prep_time_minutes'],
        'cook_time_minutes': r['cook_time_minutes'],
        'servings': r['servings'],
        'recipe_ingredients': [
          for (var i = 0; i < ingredients.length; i++)
            {
              'id': id * 100 + i,
              'position': i,
              ...ingredients[i].cast<String, dynamic>(),
            },
        ],
      };
      return (200, id);
    }
    if (path.endsWith('/rpc/copy_recipe')) {
      final source = ((body as Map)['source_id'] as num).toInt();
      if (!_canSeeRecipe(source)) {
        return (400, {'code': 'P0002', 'message': 'Recipe not found.'});
      }
      final id = _nextId++;
      final src = _recipes[source]!;
      _recipes[id] = {
        ...src,
        'id': id,
        'user_id': _me,
        'recipe_ingredients': [
          for (final i in (src['recipe_ingredients'] as List).cast<Map>())
            {
              ...i.cast<String, dynamic>(),
              'id': id * 100 + (i['position'] as int),
            },
        ],
      };
      return (200, id);
    }
    if (path.endsWith('/rpc/list_friends')) {
      return (
        200,
        [
          for (final f in _friends)
            {'id': f, ..._people[f]!, 'since': '2026-11-01T10:00:00Z'},
        ],
      );
    }
    if (path.endsWith('/rpc/send_friend_request')) {
      final email = ((body as Map)['email'] as String).trim().toLowerCase();
      if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
        return (
          400,
          {
            'code': '22023',
            'message': 'That doesn\'t look like an email address.',
          },
        );
      }
      if (email == 'demo@example.com') {
        return (
          400,
          {'code': '22023', 'message': 'That\'s your own email address.'},
        );
      }
      final sender = _incoming.entries
          .where((e) => _people[e.value]!['email'] == email)
          .firstOrNull;
      if (sender != null) {
        _incoming.remove(sender.key);
        _friends.add(sender.value);
        return (200, null);
      }
      if (_friends.any((f) => _people[f]!['email'] == email) ||
          _sent.containsValue(email)) {
        return (200, null);
      }
      _sent[_nextRequest++] = email;
      return (200, null);
    }
    if (path.endsWith('/rpc/search_people')) {
      final q = ((body as Map)['query'] as String).trim().toLowerCase();
      if (q.length < 3) return (200, []);
      final found = _people.entries
          .where((e) {
            if (e.key == _me) return false;
            final name = e.value['display_name']!.toLowerCase();
            return name.startsWith(q) ||
                name.contains(' $q') ||
                e.value['email']!.startsWith(q);
          })
          .take(5);
      return (
        200,
        [
          for (final e in found)
            {
              'id': e.key,
              'display_name': e.value['display_name'],
              'email_hint': _hint(e.value['email']!),
              'status': _statusOf(e.key),
            },
        ],
      );
    }
    if (path.endsWith('/rpc/send_friend_request_to')) {
      final person = (body as Map)['person'] as String;
      final email = _people[person]?['email'];
      if (email == null) {
        return (
          400,
          {'code': 'P0002', 'message': 'This person can\'t be found.'},
        );
      }
      final before = _nextRequest;
      final result = _handle(
        'POST',
        uri.replace(
          path: uri.path.replaceFirst(
            'send_friend_request_to',
            'send_friend_request',
          ),
        ),
        {'email': email},
      );
      if (_nextRequest > before) {
        _sentTo[before] = person; // remember who, like the database
      }
      return result;
    }
    if (path.endsWith('/rpc/list_sent_requests')) {
      // Like the database: a typed address as typed, a picked person by name + hint.
      return (
        200,
        [
          for (final e in _sent.entries)
            {
              'id': e.key,
              'display_name': _sentTo[e.key] == null
                  ? null
                  : _people[_sentTo[e.key]]!['display_name'],
              'email_label': _sentTo[e.key] == null ? e.value : _hint(e.value),
            },
        ],
      );
    }
    if (path.endsWith('/rpc/accept_friend_request')) {
      final id = ((body as Map)['request_id'] as num).toInt();
      final from = _incoming.remove(id);
      if (from == null) {
        return (
          400,
          {'code': 'P0002', 'message': 'This request no longer exists.'},
        );
      }
      _friends.add(from);
      return (200, from);
    }

    // ---- Tables ----
    if (path.endsWith('/rest/v1/recipes')) {
      final id = _eqInt(uri, 'id');
      if (method == 'DELETE') {
        if (_recipes[id]?['user_id'] == _me) {
          _recipes.remove(id);
          _items.removeWhere((x) => x.$2 == id);
          _recipeShares.removeWhere((s) => s.$1 == id);
        }
        return (204, null);
      }
      return (
        200,
        [
          for (final r in _recipes.values)
            if ((id == null || r['id'] == id) && _canSeeRecipe(r['id'] as int))
              _withOwner(r),
        ],
      );
    }
    if (path.endsWith('/rest/v1/recipe_groups')) {
      final id = _eqInt(uri, 'id');
      switch (method) {
        case 'POST':
          final newId = _addGroup(
            (body as Map)['name'] as String,
            body['description'] as String? ?? '',
          );
          return (201, [_groupJson(_groups[newId]!)]);
        case 'PATCH':
          if (_groups[id]?['user_id'] != _me) return (200, []);
          _groups[id!] = {
            ..._groups[id]!,
            ...(body as Map).cast<String, dynamic>(),
          };
          return (200, [_groupJson(_groups[id]!)]);
        case 'DELETE':
          if (_groups[id]?['user_id'] == _me) {
            _groups.remove(id);
            _items.removeWhere((x) => x.$1 == id);
            _collectionShares.removeWhere((s) => s.$1 == id);
          }
          return (204, null);
      }
      return (
        200,
        [
          for (final g in _groups.values)
            if ((id == null || g['id'] == id) && _canSeeGroup(g['id'] as int))
              _groupJson(g),
        ],
      );
    }
    if (path.endsWith('/rest/v1/recipe_group_items')) {
      if (method == 'DELETE') {
        final gid = _eqInt(uri, 'group_id');
        if (_groups[gid]?['user_id'] == _me) {
          _items.remove((gid, _eqInt(uri, 'recipe_id')));
        }
        return (204, null);
      }
      for (final row in (body is List ? body : [body]).cast<Map>()) {
        final gid = (row['group_id'] as num).toInt(),
            rid = (row['recipe_id'] as num).toInt();
        if (_groups[gid]?['user_id'] == _me &&
            _recipes[rid]?['user_id'] == _me) {
          _items.add((gid, rid));
        }
      }
      return (201, null);
    }
    if (path.endsWith('/rest/v1/friend_requests')) {
      if (method == 'DELETE') {
        final id = _eqInt(uri, 'id');
        _incoming.remove(id);
        _sent.remove(id);
        _sentTo.remove(id);
        return (204, null);
      }
      // Requests to you (the app asks for rows not sent by you; addresses stay hidden).
      if (uri.queryParameters['from_user']?.startsWith('neq.') ?? false) {
        return (
          200,
          [
            for (final e in _incoming.entries)
              {
                'id': e.key,
                'created_at': '2026-11-20T09:00:00Z',
                'sender': {'id': e.value, ..._people[e.value]!},
              },
          ],
        );
      }
      return (200, []);
    }
    if (path.endsWith('/rest/v1/friendships') && method == 'DELETE') {
      final or = uri.queryParameters['or'] ?? '';
      for (final f in [..._friends]) {
        if (or.contains(f)) _unfriend(f);
      }
      return (204, null);
    }
    for (final (table, key, shares, isMine) in [
      (
        'recipe_shares',
        'recipe_id',
        _recipeShares,
        (int id) => _recipes[id]?['user_id'] == _me,
      ),
      (
        'collection_shares',
        'group_id',
        _collectionShares,
        (int id) => _groups[id]?['user_id'] == _me,
      ),
    ]) {
      if (!path.endsWith('/rest/v1/$table')) continue;
      final id = _eqInt(uri, key);
      switch (method) {
        case 'POST':
          for (final row in (body is List ? body : [body]).cast<Map>()) {
            final target = (row[key] as num).toInt(),
                friend = row['friend_id'] as String;
            if (!isMine(target) || !_friends.contains(friend)) {
              return (
                403,
                {
                  'code': '42501',
                  'message': 'new row violates row-level security policy',
                },
              );
            }
            shares.add((target, friend));
          }
          return (201, null);
        case 'DELETE':
          final only = _eqStr(uri, 'friend_id');
          final some = _inList(uri, 'friend_id');
          shares.removeWhere(
            (s) =>
                s.$1 == id &&
                ((only != null &&
                        s.$2 == only &&
                        (only == _me || isMine(id!))) ||
                    (some.contains(s.$2) && isMine(id!))),
          );
          return (204, null);
      }
      return (
        200,
        [
          for (final s in shares)
            if (s.$1 == id && (isMine(id!) || s.$2 == _me)) {'friend_id': s.$2},
        ],
      );
    }
    return (404, {'message': 'Not in the demo: $method $path'});
  }
}
