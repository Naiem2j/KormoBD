import 'package:flutter/material.dart';

/// Wrap the app with LanguageController to provide runtime locale switching.
class LanguageController extends StatefulWidget {
  final Widget child;
  final Locale initialLocale;

  const LanguageController({
    super.key,
    required this.child,
    this.initialLocale = const Locale('en'),
  });

  static LanguageControllerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<LanguageControllerState>();
    if (state == null) {
      throw StateError('LanguageController not found in context');
    }
    return state;
  }

  @override
  LanguageControllerState createState() => LanguageControllerState();
}

class LanguageControllerState extends State<LanguageController> {
  late Locale _locale;

  Locale get locale => _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
