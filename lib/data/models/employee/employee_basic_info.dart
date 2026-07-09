import "package:dongtam/data/models/employee/employee_company_info.dart";
import "package:intl/intl.dart";

class EmployeeBasicInfoModel {
  final int employeeId;
  final DateTime? birthday, citizenIssuedDate;
  final String? homeTown, educationSystem, major;
  final String fullName, gender, birthPlace, educationLevel, phoneNumber;
  final String citizenId, citizenIssuedPlace, permanentAddress, temporaryAddress, ethnicity;

  final EmployeeCompanyInfoModel? companyInfo;

  EmployeeBasicInfoModel({
    required this.employeeId,
    required this.fullName,
    required this.gender,
    required this.birthday,
    required this.birthPlace,
    this.homeTown,
    required this.educationLevel,
    required this.phoneNumber,
    this.educationSystem,
    this.major,
    required this.citizenId,
    required this.citizenIssuedDate,
    required this.citizenIssuedPlace,
    required this.permanentAddress,
    required this.temporaryAddress,
    required this.ethnicity,

    this.companyInfo,
  });

  factory EmployeeBasicInfoModel.fromJson(Map<String, dynamic> json) {
    return EmployeeBasicInfoModel(
      employeeId: json["employeeId"] ?? 0,
      fullName: json["fullName"] ?? "",
      gender: json["gender"] ?? "",
      birthday:
          json["birthday"] != null && json["birthday"] != ""
              ? DateTime.tryParse(json["birthday"])
              : null,
      birthPlace: json["birthPlace"] ?? "",
      homeTown: json["homeTown"] ?? "",
      educationLevel: json["educationLevel"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      educationSystem: json["educationSystem"] ?? "",
      major: json["major"] ?? "",
      citizenId: json["citizenId"] ?? "",
      citizenIssuedDate:
          json["citizenIssuedDate"] != null && json["citizenIssuedDate"] != ""
              ? DateTime.tryParse(json["citizenIssuedDate"])
              : null,
      citizenIssuedPlace: json["citizenIssuedPlace"] ?? "",
      permanentAddress: json["permanentAddress"] ?? "",
      temporaryAddress: json["temporaryAddress"] ?? "",
      ethnicity: json["ethnicity"] ?? "",
      companyInfo:
          json["companyInfo"] != null
              ? EmployeeCompanyInfoModel.fromJson(json["companyInfo"])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "gender": gender,
      "birthday": DateFormat("yyyy-MM-dd").format(birthday!),
      "birthPlace": birthPlace,
      "homeTown": homeTown,
      "educationLevel": educationLevel,
      "phoneNumber": phoneNumber,
      "educationSystem": educationSystem,
      "major": major,
      "citizenId": citizenId,
      "citizenIssuedDate": DateFormat("yyyy-MM-dd").format(citizenIssuedDate!),
      "citizenIssuedPlace": citizenIssuedPlace,
      "permanentAddress": permanentAddress,
      "temporaryAddress": temporaryAddress,
      "ethnicity": ethnicity,
      "companyInfo": companyInfo?.toJson(),
    };
  }
}
