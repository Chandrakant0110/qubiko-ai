class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final bool isAnonymous;
  final String? phoneNumber;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.isAnonymous = false,
    this.phoneNumber,
    this.creationTime,
    this.lastSignInTime,
  });

  factory UserModel.fromFirebase(user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      isAnonymous: user.isAnonymous,
      phoneNumber: user.phoneNumber,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }

  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    bool? isAnonymous,
    String? phoneNumber,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      creationTime: creationTime ?? this.creationTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'phoneNumber': phoneNumber,
      'creationTime': creationTime?.millisecondsSinceEpoch,
      'lastSignInTime': lastSignInTime?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
      isAnonymous: map['isAnonymous'] ?? false,
      phoneNumber: map['phoneNumber'],
      creationTime: map['creationTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['creationTime']) 
          : null,
      lastSignInTime: map['lastSignInTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSignInTime']) 
          : null,
    );
  }
} 