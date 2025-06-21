class UserAdminModel {
  final int userId;
  final String fullName, email, role;
  final String? sex, phone, avatar;
  final List<String> permissions;

  UserAdminModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.sex,
    this.phone,
    this.avatar,
    required this.permissions,
  });

  //change JSON from api to object User
  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    return UserAdminModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      sex: json['sex'] ?? "",
      phone: json['phone'] ?? "",
      role: json['role'],
      avatar: json['avatar'] ?? "",
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  //change object User to JSON send to BE
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'sex': sex,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'permissions': permissions,
    };
  }
}
