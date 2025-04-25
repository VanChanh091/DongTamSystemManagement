class ValidationAuth {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Họ và tên không được để trống";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final RegExp emailRegex = RegExp(r'^[\w.-]+@gmail\.com$');
    if (value == null || value.trim().isEmpty) {
      return "Email không được để trống";
    }

    if (!emailRegex.hasMatch(value)) {
      return "Email không hợp lệ, hãy nhập đúng định dạng @gmail.com";
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

    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return "Mật khẩu phải chứa ít nhất một chữ cái và một số";
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
}
