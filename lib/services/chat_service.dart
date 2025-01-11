import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengirim pesan
  Future<void> sendMessage(
      {required String chatId,
      required String senderId,
      required String receiverId,
      required String content}) async {
    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
  }

  // Membaca pesan
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var message in messages.docs) {
      await message.reference.update({'isRead': true});
    }
  }

  // Mendapatkan ID chat
  String getChatId(String userAId, String userBId) {
    return userAId.compareTo(userBId) < 0
        ? '$userAId$userBId'
        : '$userBId$userAId';
  }
}
