class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? dateOfBirth;
  final int points;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.dateOfBirth,
    this.points = 0,
  });

  // From Firestore to Dart object
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: map['dateOfBirth'],
      points: map['points'] ?? 0,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'points': points,
    };
  }
}
