import '../l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/friends.dart';
import 'data_changes.dart';
import 'errors.dart';

/// Friends and friend requests. Requests go to an email address; the app never learns
/// whether that address has an account.
class FriendService {
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  SupabaseClient get _db => Supabase.instance.client;
  String get _me => _db.auth.currentUser!.id;

  /// Number of requests waiting for you; the Account tab shows it as a badge.
  final waitingCount = ValueNotifier<int>(0);

  Future<List<Friend>> friends() async {
    try {
      final rows = await _db.rpc('list_friends') as List;
      return rows
          .map((r) => Friend.fromDb((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedLoadFriends));
    }
  }

  Future<List<IncomingRequest>> incoming() async {
    try {
      final rows = await _db
          .from('friend_requests')
          .select(
            'id, created_at, sender:recipe_profiles!friend_requests_from_user_fkey(id, display_name, email)',
          )
          .neq(
            'from_user',
            _me,
          ) // requests to you; addresses are never readable
          .order('created_at', ascending: false);
      final list = rows.map(IncomingRequest.fromDb).toList();
      waitingCount.value = list.length;
      return list;
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedLoadRequests));
    }
  }

  Future<List<SentRequest>> sent() async {
    try {
      final rows = await _db.rpc('list_sent_requests') as List;
      return rows
          .map((r) => SentRequest.fromDb((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedLoadSent));
    }
  }

  /// Refreshes the badge count quietly (errors are ignored).
  Future<void> refreshWaitingCount() async {
    try {
      await incoming();
    } catch (_) {}
  }

  /// People whose name or email starts with [query] (3 letters or more), at most 5.
  Future<List<PersonMatch>> search(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final rows =
          await _db.rpc('search_people', params: {'query': query.trim()})
              as List;
      return rows
          .map((r) => PersonMatch.fromDb((r as Map).cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.searchNotWorking));
    }
  }

  /// Sends a request to someone picked from [search]. If they already asked you,
  /// you become friends straight away.
  Future<void> sendTo(String personId) async {
    try {
      await _db.rpc('send_friend_request_to', params: {'person': personId});
      markDataChanged(); // may have made you friends at once
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotSendRequest));
    }
  }

  Future<void> send(String email) async {
    try {
      await _db.rpc('send_friend_request', params: {'email': email.trim()});
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotSendRequest));
    }
  }

  Future<void> accept(int requestId) async {
    try {
      await _db.rpc('accept_friend_request', params: {'request_id': requestId});
      markDataChanged();
      waitingCount.value = (waitingCount.value - 1).clamp(0, 1 << 30);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotAccept));
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
      throw Exception(friendlyError(e, fallback: tr.couldNotRemoveRequest));
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
      markDataChanged();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.couldNotRemoveFriend));
    }
  }
}
