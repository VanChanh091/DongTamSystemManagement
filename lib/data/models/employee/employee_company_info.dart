import 'package:intl/intl.dart';

class EmployeeCompanyInfo {
  final int companyInfoId;
  final String employeeCode;
  final DateTime? joinDate;
  final String department;
  final String position;
  final String? emergencyPhone;
  final String? emergencyContact;
  final String status;

  EmployeeCompanyInfo({
    required this.companyInfoId,
    required this.employeeCode,
    required this.joinDate,
    required this.department,
    required this.position,
    this.emergencyPhone,
    this.emergencyContact,
    required this.status,
  });

  factory EmployeeCompanyInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeCompanyInfo(
      companyInfoId: json['companyInfoId'] ?? 0,
      employeeCode: json['employeeCode'] ?? "",
      joinDate:
          json['joinDate'] != null && json['joinDate'] != ''
              ? DateTime.tryParse(json['joinDate'])
              : null,
      department: json['department'] ?? "",
      position: json['position'] ?? "",
      emergencyPhone: json['emergencyPhone'] ?? "",
      emergencyContact: json['emergencyContact'] ?? "",
      status: json['status'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employeeCode": employeeCode,
      "joinDate": DateFormat('yyyy-MM-dd').format(joinDate!),
      "department": department,
      "position": position,
      "emergencyPhone": emergencyPhone,
      "emergencyContact": emergencyContact,
      "status": status,
    };
  }
}
