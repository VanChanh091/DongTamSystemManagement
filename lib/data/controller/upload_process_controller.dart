import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:get/get.dart';

class UploadProcessController extends GetxController {
  RxDouble progress = 0.0.obs;
  RxBool isUploading = false.obs;
  RxString statusMessage = "".obs;

  void updateProgress(double value, String message) {
    progress.value = value;
    statusMessage.value = message;
  }

  void complete(String successMessage) {
    isUploading.value = false;

    if (Get.context != null) {
      showSnackBarSuccess(Get.context!, successMessage);
    }
  }

  void handleError(String error) {
    isUploading.value = false;

    if (Get.context != null) {
      showSnackBarError(Get.context!, error);
    }
  }
}
