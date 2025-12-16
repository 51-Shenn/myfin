class AuthValidator {
  static String? validateEmail(String email) {
    if (email.isEmpty) return "Email cannot be empty";

    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!regex.hasMatch(email)) return "Invalid email address";
    return null;
  }

  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) return "$fieldName cannot be empty";
    return null;
  }

  static String? validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      return "Phone number cannot be empty";
    }

    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    final regex = RegExp(r'^\+?[1-9]\d{6,14}$');

    if (!regex.hasMatch(cleaned)) {
      return "Invalid phone number format";
    }

    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return "Password cannot be empty";
    if (password.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (password != confirmPassword) return "Passwords do not match";
    return null;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
