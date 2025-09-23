class UserModel {
  final String uid;
  final String name;
  final int age;
  final String bio;
  final List<String> photoUrls;
  final List<String> interests;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.bio,
    required this.photoUrls,
    required this.interests,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      bio: map['bio'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'bio': bio,
      'photoUrls': photoUrls,
      'interests': interests,
      'createdAt': createdAt,
    };
  }
}
