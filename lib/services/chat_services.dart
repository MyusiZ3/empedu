import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kirim pesan ke Firestore
  Future<void> sendMessage(String message, String receiverUid) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String senderUid = currentUser.uid;

      // Menentukan ID chat berdasarkan UID pengirim dan penerima
      String chatId = generateChatId(senderUid, receiverUid);

      // Menyimpan pesan ke subkoleksi 'messages' pada percakapan
      await _db.collection('chats').doc(chatId).collection('messages').add({
        'sender': senderUid,
        'receiver': receiverUid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false, // Pesan baru dianggap belum dibaca
      });

      // Menambahkan notifikasi (untuk deteksi pesan baru)
      await _addNotification(senderUid, receiverUid, message);
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

  // Menghasilkan ID chat berdasarkan UID pengirim dan penerima
  String generateChatId(String senderUid, String receiverUid) {
    List<String> uids = [senderUid, receiverUid];
    uids.sort(); // Pastikan ID selalu terurut untuk kedua pengguna
    return uids.join('_'); // Gabungkan UID untuk menghasilkan ID chat
  }

  // Menambahkan notifikasi jika ada pesan baru
  Future<void> _addNotification(
      String senderUid, String receiverUid, String message) async {
    // Menyimpan data notifikasi
    await _db.collection('notifications').add({
      'chatId': generateChatId(senderUid, receiverUid),
      'sender': senderUid,
      'receiver': receiverUid,
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

  // Menambahkan UID ke daftar kontak pengguna
  Future<void> addContact(String contactUid) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mengambil referensi ke dokumen pengguna
      DocumentReference userDoc = _db.collection('users').doc(currentUser.uid);
      await userDoc.update({
        'contacts': FieldValue.arrayUnion(
            [contactUid]), // Menambahkan UID ke field contacts
      });
    }
  }

  // Menghapus kontak dari daftar kontak pengguna
  Future<void> deleteContact(String contactUid) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mengambil referensi ke dokumen pengguna
      DocumentReference userDoc = _db.collection('users').doc(currentUser.uid);
      await userDoc.update({
        'contacts': FieldValue.arrayRemove(
            [contactUid]), // Menghapus UID dari field contacts
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

    // Cek apakah field 'birthdate' null
    if (userData['birthdate'] == null) {
      return 'Not set'; // Default jika tanggal lahir belum diisi
    }

    // Ambil timestamp tanggal lahir
    Timestamp timestamp = userData['birthdate'];
    DateTime birthdate = timestamp.toDate();

    // Format tanggal lahir
    String formattedBirthdate = DateFormat('MMMM dd, yyyy').format(birthdate);
    return formattedBirthdate;
  }
}
