import 'package:cloud_firestore/cloud_firestore.dart';

enum ProfileType { dating, networking, friendship }

class UserModel {
  final String uid;
  final String name;
  final int age;
  final String bio;
  final List<String> photoUrls;
  final List<String> interests;
  final ProfileType profileType;
  final DateTime createdAt;
  final String? location;
  final String? occupation;
  final String? education;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.bio,
    required this.photoUrls,
    required this.interests,
    required this.profileType,
    required this.createdAt,
    this.location,
    this.occupation,
    this.education,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'bio': bio,
      'photoUrls': photoUrls,
      'interests': interests,
      'profileType': profileType.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'occupation': occupation,
      'education': education,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      bio: map['bio'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      profileType: ProfileType.values.firstWhere(
        (e) => e.toString().split('.').last == map['profileType'],
        orElse: () => ProfileType.dating,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'],
      occupation: map['occupation'],
      education: map['education'],
    );
  }

  get profession => null;

  UserModel copyWith({
    String? uid,
    String? name,
    int? age,
    String? bio,
    List<String>? photoUrls,
    List<String>? interests,
    ProfileType? profileType,
    DateTime? createdAt,
    String? location,
    String? occupation,
    String? education,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      photoUrls: photoUrls ?? this.photoUrls,
      interests: interests ?? this.interests,
      profileType: profileType ?? this.profileType,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
    );
  }
}
