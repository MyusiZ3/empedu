import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId; // UID pengirim
  final String receiverId; // UID penerima
  final String message; // Isi pesan
  final bool isRead; // Status apakah pesan sudah dibaca
  final Timestamp timestamp; // Waktu pengiriman pesan

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  // Convert ChatMessage object ke Map untuk disimpan di Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'sender': senderId,
      'receiver': receiverId,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }

  // Convert Map dari Firebase ke ChatMessage object
  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['sender'] ?? '',
      receiverId: map['receiver'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
