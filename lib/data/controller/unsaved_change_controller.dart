import 'package:get/get.dart';

class UnsavedChangeController extends GetxController {
  RxBool isUnsavedChanges = false.obs;

  void setUnsavedChanges(bool value) {
    if (isUnsavedChanges.value != value) {
      isUnsavedChanges.value = value;
    }
  }

  void resetUnsavedChanges() {
    isUnsavedChanges.value = false;
  }
}
