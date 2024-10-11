import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function updateTheme;
  final Function updateFontSize;

  const SettingsPage({
    super.key,
    required this.updateTheme,
    required this.updateFontSize,
  });

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  double fontSize = 12.0;
  String language = 'English';

  List<String> items = ['English', 'Dari', 'Deutsch', 'Arabic'];

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  void dispose() {
    super.dispose(); // Correctly override dispose method
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      fontSize = prefs.getDouble('fontSize') ?? 12.0;
      language = prefs.getString('language') ?? 'English';
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

  Future<void> saveLanguagePreference(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Settings', style: TextStyle(fontSize: fontSize)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: SweepGradient(
            colors: [
              Colors.yellow,
              Colors.white,
              Colors.black26,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode', style: TextStyle(fontSize: fontSize)),
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
              Text('Font Size: ${fontSize.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: fontSize)),
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
              Text('Language', style: TextStyle(fontSize: fontSize)),
              DropdownButton(
                value: language, // Set the current language as the value
                items: items.map<DropdownMenuItem<String>>((item) {
                  return DropdownMenuItem<String>(
                      value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    language = value!;
                  });
                  saveLanguagePreference(value!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
