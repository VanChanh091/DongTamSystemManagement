import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/utils/handleError/dio_client.dart';
import 'package:dongtam/utils/helper/helper_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:file_picker/file_picker.dart';

class EmployeeService {
  final Dio dioService = DioClient().dio;

  // get all
  Future<Map<String, dynamic>> getAllEmployees({
    bool refresh = false,
    bool noPaging = false,
    int? page,
    int? pageSize,
  }) async {
    return HelperService().fetchPaginatedData<EmployeeBasicInfo>(
      endpoint: "employee",
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'refresh': refresh,
        'noPaging': noPaging,
      },
      fromJson: (json) => EmployeeBasicInfo.fromJson(json),
      dataKey: 'employees',
    );
  }

  //get employee by field
  Future<Map<String, dynamic>> getEmployeeByField({
    required String field,
    required String keyword,
    int page = 1,
    int pageSize = 30,
  }) async {
    return HelperService().fetchPaginatedData<EmployeeBasicInfo>(
      endpoint: 'employee/filter',
      queryParameters: {'field': field, 'keyword': keyword, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => EmployeeBasicInfo.fromJson(json),
      dataKey: 'employees',
    );
  }

  // add employee
  Future<bool> addEmployee({required Map<String, dynamic> employeeData}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.post(
        "/api/employee/",
        data: employeeData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to add employee", error: e, stackTrace: s);
      throw Exception('Failed to add employee: $e');
    }
  }

  // update employee
  Future<bool> updateEmployee({
    required int employeeId,
    required Map<String, dynamic> updateEmployeeData,
  }) async {
    try {
      final token = await SecureStorageService().getToken();
      await dioService.put(
        "/api/employee/updateEmployee",
        queryParameters: {"employeeId": employeeId},
        data: updateEmployeeData,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to update employee", error: e, stackTrace: s);
      throw Exception('Failed to update employee: $e');
    }
  }

  // delete employee
  Future<bool> deleteEmployee({required int employeeId}) async {
    try {
      final token = await SecureStorageService().getToken();

      await dioService.delete(
        "/api/employee/deleteEmployee",
        queryParameters: {"employeeId": employeeId},
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ),
      );
      return true;
    } catch (e, s) {
      AppLogger.e("Failed to delete employee", error: e, stackTrace: s);
      throw Exception('Failed to delete employee: $e');
    }
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
        "/api/employee/exportExcel",
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;

        // Cho người dùng chọn thư mục lưu
        final dirPath = await FilePicker.platform.getDirectoryPath();
        if (dirPath == null) {
          return null;
        }

        final now = DateTime.now();
        final fileName = "employee_${now.toIso8601String().split('T')[0]}.xlsx";
        final file = File("$dirPath/$fileName");

        await file.writeAsBytes(bytes, flush: true);
        AppLogger.i("Exported Excel employee to: ${file.path}");

        return file;
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
