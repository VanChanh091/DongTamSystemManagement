class UserAdminModel {
  final int userId;
  final String fullName, email, role;
  final String? sex, phone;
  final String department;
  final List<String> permissions;

  UserAdminModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    this.sex,
    this.phone,
    required this.permissions,
  });

  static String formatSex(String? sex) {
    switch (sex) {
      case "male":
        return "Nam";
      case "female":
        return "Nữ";
      default:
        return "";
    }
  }

  static String formatRole({required String role}) {
    switch (role) {
      case "admin":
        return "Quản trị";
      case "manager":
        return "Quản lý";
      case "user":
        return "Người dùng";
      default:
        return role;
    }
  }

  static String formatDepartment({required String department}) {
    switch (department) {
      case "Operation":
        return "Nghiệp Vụ";
      case "HR":
        return "Nhân sự";
      case "Accountant":
        return "Kế toán";
      case "Sale":
        return "Kinh doanh";
      case "Production":
        return "Sản xuất";
      case "QC":
        return "Chất Lượng";
      case "Delivery":
        return "Kho Vận";
      case "Marketing":
        return "Marketing";
      default:
        return "Chưa xác định";
    }
  }

  static String formatPermissions(List<String> permissions) {
    final permissionMap = {
      "manager": "Quản lý",
      "sale": "Kinh doanh",
      "plan": "Kế hoạch",
      "HR": "Nhân sự",
      "design": "Thiết kế",
      "accountant": "Kế toán",
      "production": "Sản xuất",
      "machine1350": "Máy 1350",
      "machine1900": "Máy 1900",
      "machine2Layer": "Máy 2 Lớp",
      "MachineRollPaper": "Máy Quấn Cuồn",
      "step2Production": "Công Đoạn 2",
      "QC": "Chất Lượng",
      "delivery": "Giao Hàng",
      "read": "Chỉ đọc",
    };

    return permissions.map((position) => permissionMap[position] ?? position).join(", ");
  }

  //change JSON from api to object User
  factory UserAdminModel.fromJson(Map<String, dynamic> json) {
    return UserAdminModel(
      userId: json["userId"],
      fullName: json["fullName"],
      email: json["email"],
      sex: json["sex"] ?? "",
      phone: json["phone"] ?? "",
      department: json["department"] ?? "",
      role: json["role"],
      permissions: List<String>.from(json["permissions"] ?? []),
    );
  }

  //change object User to JSON send to BE
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "sex": sex,
      "phone": phone,
      "role": role,
      "permissions": permissions,
    };
  }
}
