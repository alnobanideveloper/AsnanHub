class StudentUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int year;
  final int casesCompleted;
  final String universityId;
  final String gender;

  StudentUser({
    required this.uid,
    required this.year,
    required this.casesCompleted,
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
      'casesCompleted' : casesCompleted,
      'email': email,
      'phone': phone,
      'year' : year,
      'universityId': universityId,
      'gender': gender,
    };
  }

  // 2. Creates an Object from a Map (for receiving from Firebase)
  factory StudentUser.fromMap(Map<String, dynamic> map) {
    return StudentUser(
      uid: map['uid'] ?? '',
      casesCompleted: map['casesCompleted'] is int 
          ? map['casesCompleted'] 
          : (map['casesCompleted'] is String 
              ? int.tryParse(map['casesCompleted']) ?? 0 
              : 0),
      name: map['name'] ?? '',
      year: map['year'] is int 
          ? map['year'] 
          : (map['year'] is String 
              ? int.tryParse(map['year']) ?? 0 
              : 0),
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      universityId: map['universityId'] ?? '',
      gender: map['gender'] ?? '',
    );
  }
}