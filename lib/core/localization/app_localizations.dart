import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'KormoBD',
      'yourLocation': 'Your Location',
      'chatbot': 'Chatbot',
      'apply': 'Apply',
      'postJob': 'Post Job',
      'viewApplicants': 'View Applicants',
      'jobList': 'Job List',
      'help': 'Commands: type "job" to see available jobs, "help" for help.',
      'availableJobs': 'Available jobs: Rajmistri, Painter, Helper',
      'noJobsFound': 'No jobs found in your area',
    },
    'bn': {
      'appTitle': 'কর্মোবিডি',
      'yourLocation': 'আপনার অবস্থান',
      'chatbot': 'চ্যাটবট',
      'apply': 'আবেদন করুন',
      'postJob': 'নিয়োগ করুন',
      'viewApplicants': 'আবেদনকারী দেখুন',
      'jobList': 'নিয়োগ তালিকা',
      'help':
          'কমান্ড: "job" টাইপ করুন কর্মের তালিকা দেখতে, "help" সাহায্যের জন্য।',
      'availableJobs': 'উপলব্ধ চাকরি: রাজমিস্ত্রি, পেইন্টার, হেল্পার',
      'noJobsFound': 'আপনার এলাকায় কোন চাকরি নেই',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
