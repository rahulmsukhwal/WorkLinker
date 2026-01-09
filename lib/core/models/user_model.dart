import 'package:cloud_firestore/cloud_firestore.dart';

enum GlobalRole {
  admin,
  manager,
  developer,
  client,
}

enum UserStatus {
  active,
  inactive,
}

class UserModel {
  final String uid;
  final String? phone;
  final String? email;
  final GlobalRole globalRole;
  final UserStatus status;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    this.phone,
    this.email,
    required this.globalRole,
    required this.status,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      globalRole: GlobalRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['globalRole'],
        orElse: () => GlobalRole.client,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'globalRole': globalRole.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
    if (phone != null) map['phone'] = phone;
    if (email != null) map['email'] = email;
    return map;
  }

  String get displayIdentifier => phone ?? email ?? 'Unknown';

  String getAlias() {
    final suffix = uid.substring(0, 4).toUpperCase();
    switch (globalRole) {
      case GlobalRole.admin:
        return 'Admin-$suffix';
      case GlobalRole.manager:
        return 'Manager-$suffix';
      case GlobalRole.developer:
        return 'Dev-$suffix';
      case GlobalRole.client:
        return 'Client-$suffix';
    }
  }
}
