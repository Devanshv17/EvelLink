import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/match.dart';
import '../models/message.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Event operations
  Future<EventModel?> getEvent(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> joinEvent(String eventId, String userId) async {
    await _firestore.collection('events').doc(eventId).update({
      'activeUsers': FieldValue.arrayUnion([userId])
    });
  }

  Future<List<UserModel>> getEventUsers(String eventId, String currentUserId) async {
    final event = await getEvent(eventId);
    if (event == null) return [];

    final otherUsers = event.activeUsers.where((uid) => uid != currentUserId).toList();

    if (otherUsers.isEmpty) return [];

    final usersQuery = await _firestore
        .collection('users')
        .where('uid', whereIn: otherUsers)
        .get();

    return usersQuery.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  // Interaction operations
  Future<void> recordLike(String eventId, String swiperId, String swipedId, {bool isHidden = false}) async {
    final docRef = _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .doc(swiperId);

    final field = isHidden ? 'hiddenLikes' : 'likes';

    await docRef.set({
      field: {swipedId: FieldValue.serverTimestamp()}
    }, SetOptions(merge: true));
  }

  Future<void> recordPass(String eventId, String swiperId, String swipedId) async {
    final docRef = _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .doc(swiperId);

    await docRef.set({
      'passes': {swipedId: FieldValue.serverTimestamp()}
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserInteractions(String eventId, String userId) async {
    final doc = await _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .doc(userId)
        .get();

    return doc.data();
  }

  Future<List<String>> getUsersWhoLiked(String eventId, String userId) async {
    final snapshot = await _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .get();

    List<String> likedBy = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['likes'] != null && data['likes'][userId] != null) {
        likedBy.add(doc.id);
      }
      if (data['hiddenLikes'] != null && data['hiddenLikes'][userId] != null) {
        likedBy.add(doc.id);
      }
    }

    return likedBy;
  }

  Future<bool> isHiddenLike(String eventId, String likerId, String likedId) async {
    final doc = await _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .doc(likerId)
        .get();

    final data = doc.data();
    return data?['hiddenLikes']?[likedId] != null;
  }

  // Match operations
  Future<void> createMatch(String user1Id, String user2Id) async {
    final matchId = _generateMatchId(user1Id, user2Id);

    await _firestore.collection('matches').doc(matchId).set({
      'users': [user1Id, user2Id],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create initial chat document
    await _firestore.collection('chats').doc(matchId).set({
      'users': [user1Id, user2Id],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MatchModel>> getUserMatches(String userId) async {
    final snapshot = await _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Chat operations
  Future<void> sendMessage(String matchId, String senderId, String text) async {
    await _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in match
    await _firestore.collection('matches').doc(matchId).update({
      'lastMessage': text,
    });
  }

  Stream<List<MessageModel>> getChatMessages(String matchId) {
    return _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  String _generateMatchId(String user1Id, String user2Id) {
    final sortedIds = [user1Id, user2Id]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}