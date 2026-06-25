class Validators {
  static String? email(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Invalid email';
    }
    return null;
  }
}
