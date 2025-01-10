import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;

  ChatMessage({
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
  });

  // Convert ChatMessage object ke Map untuk disimpan di Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp,
    };
  }

  // Convert Map ke ChatMessage object
  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderEmail: map['senderEmail'],
      receiverEmail: map['receiverEmail'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
}
