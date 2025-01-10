import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal lahir

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kirim pesan ke Firestore
  Future<void> sendMessage(String message, String receiverEmail) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String senderEmail = currentUser.email!;

      // Menentukan ID chat berdasarkan email pengirim dan penerima
      String chatId = generateChatId(senderEmail, receiverEmail);

      // Menyimpan pesan ke subkoleksi 'messages' pada percakapan
      await _db.collection('chats').doc(chatId).collection('messages').add({
        'sender': senderEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false, // Pesan baru dianggap belum dibaca
      });

      // Menambahkan notifikasi (untuk deteksi pesan baru)
      await _addNotification(senderEmail, receiverEmail, message);
    }
  }

  // Ambil pesan berdasarkan chatId
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Menghasilkan ID chat berdasarkan email pengirim dan penerima
  String generateChatId(String senderEmail, String receiverEmail) {
    List<String> emails = [senderEmail, receiverEmail];
    emails.sort();
    return emails
        .join('_'); // Gabungkan email yang terurut untuk menghasilkan ID chat
  }

  // Menambahkan notifikasi jika ada pesan baru
  Future<void> _addNotification(
      String senderEmail, String receiverEmail, String message) async {
    // Menyimpan data notifikasi
    await _db.collection('notifications').add({
      'chatId': generateChatId(senderEmail, receiverEmail),
      'sender': senderEmail,
      'receiver': receiverEmail,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Notifikasi baru dianggap belum dibaca
    });
  }

  // Mengambil daftar kontak untuk pengguna yang terautentikasi
  Future<List<String>> getContacts() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mengambil daftar kontak dari koleksi 'users'
      DocumentSnapshot snapshot =
          await _db.collection('users').doc(currentUser.uid).get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

      // Ambil daftar kontak dari field 'contacts' di data pengguna
      List<dynamic> contacts = userData['contacts'] ?? [];
      return contacts.map((contact) => contact.toString()).toList();
    }
    return [];
  }

  // Menambahkan email ke daftar kontak pengguna
  Future<void> addContact(String email) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mengambil referensi ke dokumen pengguna
      DocumentReference userDoc = _db.collection('users').doc(currentUser.uid);
      await userDoc.update({
        'contacts': FieldValue.arrayUnion(
            [email]), // Menambahkan email ke field contacts
      });
    }
  }

  // Menghapus kontak dari daftar kontak pengguna
  Future<void> deleteContact(String email) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mengambil referensi ke dokumen pengguna
      DocumentReference userDoc = _db.collection('users').doc(currentUser.uid);
      await userDoc.update({
        'contacts': FieldValue.arrayRemove(
            [email]), // Menghapus email dari field contacts
      });
    }
  }

  // Mendapatkan gambar profil pengguna
  Future<String> getProfileImage(String uid) async {
    DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    // Mengambil URL gambar profil dari data pengguna
    String profileImageUrl =
        userData['profileimage'] ?? 'assets/default_avatar.png';
    return profileImageUrl;
  }

  // Mengambil tanggal lahir pengguna dan memformatnya
  Future<String> getFormattedBirthdate(String uid) async {
    DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

    // Ambil timestamp tanggal lahir
    Timestamp timestamp = userData['birthdate'];
    DateTime birthdate = timestamp.toDate();

    // Format tanggal lahir
    String formattedBirthdate = DateFormat('MMMM dd, yyyy').format(birthdate);
    return formattedBirthdate;
  }
}
