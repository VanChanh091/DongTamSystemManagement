class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Họ và tên không được để trống";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email không được để trống";
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return "Email không hợp lệ";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Mật khẩu không được để trống";
    }
    if (value.length < 8) {
      return "Mật khẩu phải có ít nhất 8 ký tự";
    }
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return "Mật khẩu phải bao gồm ít nhất một chữ cái và một số";
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.trim().isEmpty) {
      return "Xác nhận mật khẩu không được để trống";
    }
    if (confirmPassword != password) {
      return "Mật khẩu không khớp";
    }
    return null;
  }

  static String? validateOTP(String? value, String correctOTP) {
    if (value == null || value.trim().isEmpty) {
      return "Mã OTP không được để trống";
    }
    if (value.length != 4) {
      return "Mã OTP phải có 4 ký tự";
    }

    if (value != correctOTP) {
      return "Mã OTP không đúng";
    }
    return null;
  }
}
