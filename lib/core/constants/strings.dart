class AppStrings {
  static const appName = "KormoBD";

  static const login = "Login";
  static const register = "Register";

  static const worker = "Worker";
  static const employer = "Employer";
  static const admin = "Admin";

  static const postJob = "Post Job";
  static const applyJob = "Apply Job";
}

/// Bilingual app text storage and helper.
/// Use `AppText.getText(key, lang)` to fetch text for `en` or `bn`.
class AppText {
  static const Map<String, Map<String, String>> texts = {
    "login": {"en": "Login", "bn": "লগইন"},
    "register": {"en": "Register", "bn": "রেজিস্টার"},
    "worker": {"en": "Worker", "bn": "কর্মী"},
    "employer": {"en": "Employer", "bn": "নিয়োগকর্তা"},
    "admin": {"en": "Admin", "bn": "অ্যাডমিন"},
    // additional entries useful across the app
    "post_job": {"en": "Post Job", "bn": "চাকরি পোস্ট করুন"},
    "apply_job": {"en": "Apply Job", "bn": "চাকরিতে আবেদন করুন"},
    "app_name": {"en": "KormoBD", "bn": "কর্মোবিডি"},
  };

  /// Return the text for [key] in the requested [lang].
  /// If the key or language is missing, falls back to English, then to the key.
  static String getText(String key, String lang) {
    final entry = texts[key];
    if (entry == null) return key;
    // normalize language code to `en` or `bn`
    final code = lang.split('-').first.toLowerCase();
    if (entry.containsKey(code)) return entry[code]!;
    if (entry.containsKey('en')) return entry['en']!;
    return key;
  }
}
