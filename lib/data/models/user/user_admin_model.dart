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

  static String formatSex(String? sex) {
    switch (sex) {
      case "male":
        return 'Nam';
      case "female":
        return 'Nữ';
      default:
        return '';
    }
  }

  static String formatRole(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị';
      case 'manager':
        return 'Quản lý';
      case 'user':
        return 'Người dùng';
      default:
        return role;
    }
  }

  static String formatPermissions(List<String> permissions) {
    final permissionMap = {
      'manager': "Quản lý",
      "sale": "Kinh doanh",
      "plan": "Kế hoạch",
      "HR": "Nhân sự",
      "accountant": "Kế toán",
      "design": "Thiết kế",
      "production": "Sản xuất",
      "machine1350": "Máy 1350",
      "machine1900": "Máy 1900",
      "machine2Layer": "Máy 2 Lớp",
      "MachineRollPaper": "Máy Quấn Cuồn",
      "step2Production": "Công Đoạn 2",
      "read": "Chỉ đọc",
    };

    return permissions
        .map((position) => permissionMap[position] ?? position)
        .join(', ');
  }

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
