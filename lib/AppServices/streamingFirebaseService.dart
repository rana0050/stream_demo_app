import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:streaming_demo_app/Models/player_model.dart';

/// Dedicated Firebase Realtime Database service for the live streaming feature.
/// Manages [presenter/], [players/], and [invite/] nodes.
class StreamingFirebaseService {
  late final FirebaseDatabase _database;
  late final DatabaseReference _presenterRef;
  late final DatabaseReference _playersRef;
  late final DatabaseReference _inviteRef;

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    try {
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://streaming-demo-app-default-rtdb.firebaseio.com',
      );
      _presenterRef = _database.ref('presenter');
      _playersRef = _database.ref('players');
      _inviteRef = _database.ref('invite');
      _isInitialized = true;
      debugPrint('StreamingFirebaseService initialized');
    } catch (e) {
      debugPrint('StreamingFirebaseService init error: $e');
      rethrow;
    }
  }

  // ========================= PRESENTER ========================= //

  /// Write presenter name to Firebase
  Future<void> savePresenterName(String name) async {
    await _presenterRef.child('name').set(name);
    debugPrint('StreamingFirebaseService: Presenter name saved: $name');
  }

  /// Set presenter isLive = true
  Future<void> setPresenterLive(String name) async {
    await _presenterRef.update({
      'name': name,
      'isLive': true,
    });
    debugPrint('StreamingFirebaseService: Presenter is now LIVE');
  }

  /// Set presenter isLive = false
  Future<void> setPresenterOffline() async {
    await _presenterRef.update({'isLive': false});
    debugPrint('StreamingFirebaseService: Presenter is now OFFLINE');
  }

  /// Stream for presenter isLive flag
  Stream<DatabaseEvent> get isLiveStream => _presenterRef.child('isLive').onValue;

  // ========================= PLAYERS ========================= //

  /// Save / update player entry in Firebase
  Future<void> savePlayerName(String playerId, String name) async {
    await _playersRef.child(playerId).set({'name': name});
    debugPrint('StreamingFirebaseService: Player saved: $name ($playerId)');
  }

  /// Stream for players node
  Stream<DatabaseEvent> get playersStream => _playersRef.onValue;

  /// Fetch all players once
  Future<List<PlayerModel>> getPlayers() async {
    final snapshot = await _playersRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((e) => PlayerModel.fromMap(e.key as String, e.value as Map<dynamic, dynamic>)).toList();
  }

  // ========================= INVITE ========================= //

  /// Invite a player — only one at a time since /invite is a single node.
  /// status = "pending"
  Future<void> invitePlayer({
    required String playerId,
    required String playerName,
    required String presenterName,
  }) async {
    await _inviteRef.set({
      'invitedPlayerId': playerId,
      'invitedPlayerName': playerName,
      'presenterName': presenterName,
      'status': 'pending',
      'joinedAt': null,
    });
    debugPrint('StreamingFirebaseService: Invited $playerName ($playerId)');
  }

  /// Player accepts the invite.
  /// Sets status = "accepted" and records joinedAt timestamp.
  Future<void> acceptInvite(String playerId) async {
    await _inviteRef.update({
      'status': 'accepted',
      'joinedAt': ServerValue.timestamp,
    });
    debugPrint('StreamingFirebaseService: Invite accepted by $playerId');
  }

  /// Player declines the invite.
  Future<void> declineInvite() async {
    await _inviteRef.update({'status': 'declined'});
    debugPrint('StreamingFirebaseService: Invite declined');
  }

  /// Presenter cancels invite / ends session — removes the node entirely.
  Future<void> clearInvite() async {
    await _inviteRef.remove();
    debugPrint('StreamingFirebaseService: Invite cleared');
  }

  /// Real-time stream on the /invite node (used by both presenter and player).
  Stream<DatabaseEvent> get inviteStream => _inviteRef.onValue;

  //
}

/// Global singleton
final StreamingFirebaseService streamingFirebaseService = StreamingFirebaseService();
