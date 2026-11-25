// Demo mode only: a pretend Supabase that keeps everything in memory, so the app can be
// tried and screenshotted without a real project. Never used by the real app (lib/main.dart).
import 'dart:convert';
import 'package:http/http.dart' as http;

class DemoBackend extends http.BaseClient {
  DemoBackend() {
    _seed();
  }

  final _recipes = <int, Map<String, dynamic>>{};
  final _groups = <int, Map<String, dynamic>>{};
  final _items = <(int, int)>{}; // (group id, recipe id)
  var _nextId = 100;
  Map<String, dynamic> _metadata = {'username': 'Samer'};

  static const _userId = '00000000-0000-4000-8000-000000000001';

  void _addRecipe(
    String title,
    String? description,
    int? prep,
    int? cook,
    int? servings,
    List<List<String?>> ingredients,
    String? steps,
  ) {
    final id = _nextId++;
    _recipes[id] = {
      'id': id,
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
    );
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
    );
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
    );
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
    );
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
    );
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
    );
    final breakfast = _nextId++;
    _groups[breakfast] = {
      'id': breakfast,
      'name': 'Breakfast',
      'description': 'Slow weekend mornings',
    };
    final weeknight = _nextId++;
    _groups[weeknight] = {
      'id': weeknight,
      'name': 'Weeknight dinners',
      'description': 'On the table in 30 minutes',
    };
    _items.addAll({
      (breakfast, 100),
      (breakfast, 105),
      (weeknight, 102),
      (weeknight, 103),
    });
  }

  Map<String, dynamic> get _user => {
    'id': _userId,
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
    return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part({'sub': _userId, 'exp': exp, 'role': 'authenticated', 'aud': 'authenticated'})}.demo';
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

  Map<String, dynamic> _groupJson(Map<String, dynamic> g) => {
    ...g,
    'user_id': _userId,
    'recipes': [
      for (final (gid, rid) in _items)
        if (gid == g['id'] && _recipes.containsKey(rid)) _recipes[rid],
    ],
  };

  int? _eq(Uri uri, String key) {
    final v = uri.queryParameters[key];
    return v != null && v.startsWith('eq.')
        ? int.tryParse(v.substring(3))
        : null;
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
    // ---- Auth ----
    if (path.endsWith('/auth/v1/token')) return (200, _session);
    if (path.endsWith('/auth/v1/user')) {
      if (method == 'PUT' && body is Map && body['data'] is Map) {
        _metadata = {
          ..._metadata,
          ...(body['data'] as Map).cast<String, dynamic>(),
        };
      }
      return (200, _user);
    }
    if (path.endsWith('/auth/v1/logout')) return (204, null);
    // ---- Database ----
    if (path.endsWith('/rpc/ping')) return (200, 'ok');
    if (path.endsWith('/rpc/save_recipe')) {
      final r = ((body as Map)['recipe'] as Map).cast<String, dynamic>();
      final id = (r['id'] as num?)?.toInt() ?? _nextId++;
      final ingredients = (r['ingredients'] as List? ?? const []).cast<Map>();
      _recipes[id] = {
        'id': id,
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
    if (path.endsWith('/rest/v1/recipes')) {
      final id = _eq(uri, 'id');
      if (method == 'DELETE') {
        _recipes.remove(id);
        _items.removeWhere((x) => x.$2 == id);
        return (204, null);
      }
      return (
        200,
        [
          for (final r in _recipes.values)
            if (id == null || r['id'] == id) r,
        ],
      );
    }
    if (path.endsWith('/rest/v1/recipe_groups')) {
      final id = _eq(uri, 'id');
      switch (method) {
        case 'POST':
          final newId = _nextId++;
          _groups[newId] = {
            'id': newId,
            ...(body as Map).cast<String, dynamic>(),
          };
          return (201, [_groupJson(_groups[newId]!)]);
        case 'PATCH':
          _groups[id!] = {
            ..._groups[id]!,
            ...(body as Map).cast<String, dynamic>(),
          };
          return (200, [_groupJson(_groups[id]!)]);
        case 'DELETE':
          _groups.remove(id);
          _items.removeWhere((x) => x.$1 == id);
          return (204, null);
      }
      return (
        200,
        [
          for (final g in _groups.values)
            if (id == null || g['id'] == id) _groupJson(g),
        ],
      );
    }
    if (path.endsWith('/rest/v1/recipe_group_items')) {
      if (method == 'DELETE') {
        _items.remove((_eq(uri, 'group_id'), _eq(uri, 'recipe_id')));
        return (204, null);
      }
      final rows = body is List ? body : [body];
      for (final row in rows.cast<Map>()) {
        _items.add((
          (row['group_id'] as num).toInt(),
          (row['recipe_id'] as num).toInt(),
        ));
      }
      return (201, null);
    }
    return (404, {'message': 'Not in the demo: $method $path'});
  }
}
