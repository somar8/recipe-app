import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/friends.dart';
import 'errors.dart';

/// Friends and friend requests. Requests go to an email address; the app never learns
/// whether that address has an account.
class FriendService {
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  SupabaseClient get _db => Supabase.instance.client;
  String get _me => _db.auth.currentUser!.id;
  String get _myEmail => (_db.auth.currentUser?.email ?? '').toLowerCase();

  /// Number of requests waiting for you; the Account tab shows it as a badge.
  final waitingCount = ValueNotifier<int>(0);

  Future<List<Friend>> friends() async {
    try {
      final rows = await _db.rpc('list_friends') as List;
      return rows
          .map((r) => Friend.fromDb((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Failed to load your friends.'),
      );
    }
  }

  Future<List<IncomingRequest>> incoming() async {
    try {
      final rows = await _db
          .from('friend_requests')
          .select(
            'id, created_at, sender:recipe_profiles!friend_requests_from_user_fkey(id, display_name, email)',
          )
          .eq('to_email', _myEmail)
          .order('created_at', ascending: false);
      final list = rows.map(IncomingRequest.fromDb).toList();
      waitingCount.value = list.length;
      return list;
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Failed to load friend requests.'),
      );
    }
  }

  Future<List<SentRequest>> sent() async {
    try {
      final rows = await _db
          .from('friend_requests')
          .select('id, to_email')
          .eq('from_user', _me)
          .order('created_at', ascending: false);
      return rows.map(SentRequest.fromDb).toList();
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Failed to load your sent requests.'),
      );
    }
  }

  /// Refreshes the badge count quietly (errors are ignored).
  Future<void> refreshWaitingCount() async {
    try {
      await incoming();
    } catch (_) {}
  }

  Future<void> send(String email) async {
    try {
      await _db.rpc('send_friend_request', params: {'email': email.trim()});
    } catch (e) {
      throw Exception(
        friendlyError(
          e,
          fallback: 'Could not send the request. Please try again.',
        ),
      );
    }
  }

  Future<void> accept(int requestId) async {
    try {
      await _db.rpc('accept_friend_request', params: {'request_id': requestId});
      waitingCount.value = (waitingCount.value - 1).clamp(0, 1 << 30);
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Could not accept the request.'),
      );
    }
  }

  /// Declines a request to you, or cancels one you sent.
  Future<void> remove(int requestId, {bool incoming = false}) async {
    try {
      await _db.from('friend_requests').delete().eq('id', requestId);
      if (incoming) {
        waitingCount.value = (waitingCount.value - 1).clamp(0, 1 << 30);
      }
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Could not remove the request.'),
      );
    }
  }

  /// Ends a friendship. Everything you shared with each other stops being shared.
  Future<void> unfriend(String friendId) async {
    try {
      await _db
          .from('friendships')
          .delete()
          .or(
            'and(user_a.eq.$_me,user_b.eq.$friendId),and(user_a.eq.$friendId,user_b.eq.$_me)',
          );
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Could not remove this friend.'),
      );
    }
  }
}
