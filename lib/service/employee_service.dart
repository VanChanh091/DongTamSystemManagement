import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';

class EmployeeService {
  final Dio dioService = DioClient().dio;

  // get all and search
  Future<Map<String, dynamic>> getEmployees({
    String? field,
    String? keyword,
    int? page,
    int? pageSize,
    bool noPaging = false,
  }) async {
    return HelperService().fetchPaginatedData<EmployeeBasicInfo>(
      endpoint: "employee",
      queryParameters: {
        'field': field,
        'keyword': keyword,
        'page': page,
        'pageSize': pageSize,
        'noPaging': noPaging,
      },
      fromJson: (json) => EmployeeBasicInfo.fromJson(json),
      dataKey: 'employees',
    );
  }

  Future<List<EmployeeBasicInfo>> getEmployeeByPosition() async {
    return HelperService().fetchingData(
      endpoint: 'employee/position',
      queryParameters: const {},
      fromJson: (json) => EmployeeBasicInfo.fromJson(json),
    );
  }

  // add employee
  Future<bool> addEmployee({required Map<String, dynamic> employeeData}) async {
    return HelperService().addItem(endpoint: "employee", itemData: employeeData);
  }

  // update employee
  Future<bool> updateEmployee({
    required int employeeId,
    required Map<String, dynamic> updateEmployeeData,
  }) async {
    return HelperService().updateItem(
      endpoint: "employee",
      queryParameters: {"employeeId": employeeId},
      dataUpdated: updateEmployeeData,
    );
  }

  // delete employee
  Future<bool> deleteEmployee({required int employeeId}) async {
    return HelperService().deleteItem(
      endpoint: "employee",
      queryParameters: {"employeeId": employeeId},
    );
  }

  //export customer
  Future<File?> exportExcelEmployee({String? status, DateTime? joinDate, bool all = false}) async {
    try {
      final token = await SecureStorageService().getToken();

      final Map<String, dynamic> body = {"all": all};

      if (joinDate != null) {
        body["joinDate"] = joinDate.toIso8601String();
      } else if (status != null) {
        body['status'] = status;
      }

      final response = await dioService.post(
        "/api/employee/export",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return await HelperService().saveExcelFile(
          bytes: response.data as List<int>,
          fileNamePrefix: "employee",
        );
      } else {
        AppLogger.w("Export failed with statusCode: ${response.statusCode}");
        return null;
      }
    } catch (e, s) {
      AppLogger.e("failed to export employee", error: e, stackTrace: s);
      return null;
    }
  }
}
