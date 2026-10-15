import 'package:dongtam/data/models/admin/machine/admin_machine_paper_model.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';

class RawMachineResult {
  final List<String> machineNames;
  final Map<String, int?> nameToIdMap;
  final List<AdminMachinePaperModel> rawMachines;

  RawMachineResult({
    required this.machineNames,
    required this.nameToIdMap,
    required this.rawMachines,
  });

  static RawMachineResult empty() =>
      RawMachineResult(machineNames: [], nameToIdMap: {}, rawMachines: []);
}

class MachineHelper {
  static RawMachineResult? _cachedResult;

  /// Lấy danh sách máy sóng (giấy) từ API admin/machine-papers/machine-name.
  /// Mặc định dùng memory cache để tránh gọi API nhiều lần khi mở qua lại các dialog.
  static Future<RawMachineResult> getRawMachinePapers({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedResult != null && _cachedResult!.machineNames.isNotEmpty) {
      return _cachedResult!;
    }

    try {
      final machines = await AdminService().getRawMachinePapers();
      final Map<String, int?> newMap = {};
      final List<String> newItems = [];

      for (final machine in machines) {
        if (machine.machineName.isNotEmpty) {
          newMap[machine.machineName] = machine.machineId;
          newItems.add(machine.machineName);
        }
      }

      final result = RawMachineResult(
        machineNames: newItems,
        nameToIdMap: newMap,
        rawMachines: machines,
      );

      _cachedResult = result;
      return result;
    } catch (e, s) {
      AppLogger.e("Lỗi tải danh sách máy từ API", error: e, stackTrace: s);
      return _cachedResult ?? RawMachineResult.empty();
    }
  }

  /// Lấy nhanh danh sách tên máy
  static Future<List<String>> getMachinePaperNames({bool forceRefresh = false}) async {
    final result = await getRawMachinePapers(forceRefresh: forceRefresh);
    return result.machineNames;
  }

  /// Xóa cache
  static void clearCache() {
    _cachedResult = null;
  }
}
