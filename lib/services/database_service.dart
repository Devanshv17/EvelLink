import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

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

  Future<List<UserModel>> getEventParticipants(String eventId, String currentUserId) async {
    // Get all participants in event
    final participantsQuery = await _firestore
        .collection('eventParticipants')
        .doc(eventId)
        .collection('users')
        .get();

    if (participantsQuery.docs.isEmpty) return [];

    final participantIds = participantsQuery.docs
        .map((doc) => doc.id)
        .where((id) => id != currentUserId)
        .toList();

    if (participantIds.isEmpty) return [];

    // Get user profiles for participants
    final usersQuery = await _firestore
        .collection('users')
        .where('uid', whereIn: participantIds)
        .get();

    return usersQuery.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
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
    await _firestore
        .collection('eventParticipants')
        .doc(eventId)
        .collection('users')
        .doc(userId)
        .set({
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isUserInEvent(String eventId, String userId) async {
    final doc = await _firestore
        .collection('eventParticipants')
        .doc(eventId)
        .collection('users')
        .doc(userId)
        .get();
    return doc.exists;
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

    // Check for mutual like to create match
    await _checkForMatch(eventId, swiperId, swipedId);
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

  Future<List<String>> getUsersWhoLikedMe(String eventId, String userId) async {
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
    }
    
    return likedBy;
  }

  Future<List<String>> getHiddenLikes(String eventId, String userId) async {
    final snapshot = await _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .get();
    
    List<String> hiddenLikedBy = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['hiddenLikes'] != null && data['hiddenLikes'][userId] != null) {
        hiddenLikedBy.add(doc.id);
      }
    }
    
    return hiddenLikedBy;
  }

  Future<void> _checkForMatch(String eventId, String swiperId, String swipedId) async {
    // Check if the swiped user also liked the swiper
    final swipedUserDoc = await _firestore
        .collection('interactions')
        .doc(eventId)
        .collection('swipes')
        .doc(swipedId)
        .get();

    if (swipedUserDoc.exists) {
      final data = swipedUserDoc.data()!;
      final likes = data['likes'] as Map<String, dynamic>? ?? {};
      
      if (likes.containsKey(swiperId)) {
        // It's a match!
        await _createMatch(eventId, swiperId, swipedId);
      }
    }
  }

  Future<void> _createMatch(String eventId, String user1Id, String user2Id) async {
    final matchId = _generateMatchId(user1Id, user2Id);
    
    await _firestore.collection('matches').doc(matchId).set({
      'users': [user1Id, user2Id],
      'eventId': eventId,
      'matchedAt': FieldValue.serverTimestamp(),
      'unreadCount': {user1Id: 0, user2Id: 0},
    });
  }

  // Match operations
  Future<List<MatchModel>> getUserMatches(String userId) async {
    final snapshot = await _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .orderBy('matchedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => MatchModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Chat operations
  Future<void> sendMessage(String matchId, String senderId, String text) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      messageId: messageRef.id,
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    await messageRef.set(message.toMap());

    // Update match with last message
    await _firestore.collection('matches').doc(matchId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
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

  // Cleanup expired events
  Future<void> cleanupExpiredEventData(String eventId) async {
    final batch = _firestore.batch();

    // Delete interactions for this event
    final interactionsRef = _firestore.collection('interactions').doc(eventId);
    batch.delete(interactionsRef);

    // Delete event participants
    final participantsRef = _firestore.collection('eventParticipants').doc(eventId);
    batch.delete(participantsRef);

    await batch.commit();
  }
}
