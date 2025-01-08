import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart'; // Import model Contact

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('contacts.db');
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Membuat tabel untuk menyimpan kontak
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phoneNumber TEXT
      )
    ''');
  }

  // Menambah kontak ke dalam database
  Future<int> createContact(Contact contact) async {
    final db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  // Mendapatkan semua kontak dari database
  Future<List<Contact>> getContacts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Menghapus kontak berdasarkan ID
  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  // **Metode untuk mengupdate kontak berdasarkan ID**
  Future<int> updateContact(Contact contact) async {
    final db = await instance.database;

    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
}
