import 'dart:async';

import 'package:clup_management/reports.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) updateTheme;
  final Function(double) updateFontSize;
  final AppLanguage currentLanguage;
  final Function(AppLanguage) updateLanguage;

  const SettingsPage({
    super.key,
    required this.updateTheme,
    required this.updateFontSize,
    required this.currentLanguage,
    required this.updateLanguage,
  });

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  double fontSize = 12.0;
  AppLanguage language = AppLanguage.english;

  List<AppLanguage> items = [AppLanguage.english, AppLanguage.dari];

  final Map<String, Map<String, String>> translations = {
    'en': {
      'settings': 'Settings',
      'darkMode': 'Dark Mode',
      'fontSize': 'Font Size:',
      'language': 'Language',
      'noRecords': 'No records found.',
    },
    'fa': {
      'settings': 'تنظیمات',
      'darkMode': 'حالت تاریک',
      'fontSize': 'اندازه فونت:',
      'language': 'زبان',
      'noRecords': 'هیچ رکوردی یافت نشد.',
    },
  };

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 12.0;
      String lang = prefs.getString('language') ?? 'English';
      language = lang == 'English' ? AppLanguage.english : AppLanguage.dari;
    });
  }

  Future<void> saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> saveFontSizePreference(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', value);
  }

  Future<void> saveLanguagePreference(AppLanguage value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value == AppLanguage.english ? 'English' : 'Dari');
  }
  String getString(String key) {
    final langCode = language == AppLanguage.english ? 'en' : 'fa';
    final translationsForLang = translations[langCode];
    return translationsForLang?[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    TextDirection textDirection =
    language == AppLanguage.english ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text(getString('settings'), style: TextStyle(fontSize: fontSize)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dark Mode Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getString('darkMode'), style: TextStyle(fontSize: fontSize, color: Colors.yellow)),
                  Switch(
                    value: isDarkMode,
                    activeColor: Colors.black,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                        widget.updateTheme(isDarkMode);
                      });
                      saveThemePreference(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Font Size Slider
              Text('${getString('fontSize')} ${fontSize.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: fontSize, color: Colors.yellow)),
              Slider(
                value: fontSize,
                activeColor: Colors.black,
                min: 12.0,
                max: 24.0,
                label: fontSize.toString(),
                onChanged: (value) {
                  setState(() {
                    fontSize = value;
                    widget.updateFontSize(fontSize);
                  });
                  saveFontSizePreference(value);
                },
              ),
              const SizedBox(height: 20),
              // Language Dropdown
              Text(getString('language'), style: TextStyle(fontSize: fontSize, color: Colors.yellow)),
              DropdownButton<AppLanguage>(
                dropdownColor: Colors.black,
                value: language,
                items: items.map<DropdownMenuItem<AppLanguage>>((AppLanguage item) {
                  String displayText = item == AppLanguage.english ? 'English' : 'Dari';
                  return DropdownMenuItem<AppLanguage>(
                    value: item,
                    child: Text(displayText, style: const TextStyle(color: Colors.yellow)),
                  );
                }).toList(),
                onChanged: (AppLanguage? value) {
                  if (value != null) {
                    setState(() {
                      language = value;
                      widget.updateLanguage(language);
                    });
                    saveLanguagePreference(value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
