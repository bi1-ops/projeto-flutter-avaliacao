class AppValidators {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  const AppValidators._();

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static String? validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateEmail(
    String? value, {
    String emptyMessage = 'Informe o e-mail.',
  }) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return emptyMessage;
    }
    if (!isValidEmail(email)) {
      return 'Informe um e-mail valido.';
    }
    return null;
  }
}
