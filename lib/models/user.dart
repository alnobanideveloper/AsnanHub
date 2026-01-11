class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String universityId;
  final String gender;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.universityId,
    required this.gender,
  });

  // 1. Converts the Object to a Map (for sending to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'universityId': universityId,
      'gender': gender,
    };
  }

  // 2. Creates an Object from a Map (for receiving from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      universityId: map['universityId'] ?? '',
      gender: map['gender'] ?? '',
    );
  }
}