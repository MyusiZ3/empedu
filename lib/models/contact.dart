class Contact {
  final int? id;
  final String name;
  final String phoneNumber;

  Contact({this.id, required this.name, required this.phoneNumber});

  // Mengonversi data kontak ke dalam bentuk Map untuk disimpan di database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  // Mengonversi Map ke dalam objek Contact
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
