// report_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui; // Alias dart:ui as ui

// Define the language enum
enum AppLanguage { english, persian, dari }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variable to hold the current language
  AppLanguage _currentLanguage = AppLanguage.english;

  // Localization maps
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'reports': 'Reports',
      'allRegisteredMembers': 'All Registered Members',
      'expiringMembers': 'Expiring Members',
      'expiredMembers': 'Expired Members',
      'oneMonthRegistrations': '1-Month Registrations',
      'threeMonthsRegistrations': '3-Month Registrations',
      'sixMonthsRegistrations': '6-Month Registrations',
      'oneYearRegistrations': '1-Year Registrations',
      'noRecordsFound': 'No records found.',
      'close': 'Close',
      'daysRemaining': 'days remaining',
      'language': 'Language', // Added for settings
    },
    'fa': {
      'reports': 'گزارش‌ها',
      'allRegisteredMembers': 'همه اعضای ثبت‌نام شده',
      'expiringMembers': 'اعضای در حال انقضا',
      'expiredMembers': 'اعضای منقضی شده',
      'oneMonthRegistrations': 'ثبت‌نام‌های 1 ماهه',
      'threeMonthsRegistrations': 'ثبت‌نام‌های 3 ماهه',
      'sixMonthsRegistrations': 'ثبت‌نام‌های 6 ماهه',
      'oneYearRegistrations': 'ثبت‌نام‌های 1 ساله',
      'noRecordsFound': 'رکوردی یافت نشد.',
      'close': 'بستن',
      'daysRemaining': 'روز باقی‌مانده',
      'language': 'زبان', // Added for settings
    },
  };

  // Animation controllers for each card
  late AnimationController _allMembersController;
  late AnimationController _expiringMembersController;
  late AnimationController _expiredMembersController;
  late AnimationController _oneMonthController;
  late AnimationController _threeMonthsController;
  late AnimationController _sixMonthsController;
  late AnimationController _oneYearController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _allMembersController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _expiringMembersController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _expiredMembersController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _oneMonthController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _threeMonthsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _sixMonthsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _oneYearController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Dispose animation controllers
    _allMembersController.dispose();
    _expiringMembersController.dispose();
    _expiredMembersController.dispose();
    _oneMonthController.dispose();
    _threeMonthsController.dispose();
    _sixMonthsController.dispose();
    _oneYearController.dispose();
    super.dispose();
  }

  // Function to get the appropriate string based on the current language
  String _getString(String key) {
    return _localizedStrings[_currentLanguage == AppLanguage.english ? 'en' : 'fa']![key] ?? '';
  }

  // Function to toggle the language
  void _toggleLanguage() {
    setState(() {
      _currentLanguage =
      _currentLanguage == AppLanguage.english ? AppLanguage.persian : AppLanguage.english;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine text direction based on the current language
    ui.TextDirection textDirection =
    _currentLanguage == AppLanguage.english ? ui.TextDirection.ltr : ui.TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        appBar: AppBar(
          title: Text(_getString('reports')),
          backgroundColor: Colors.yellow,
          actions: [
            IconButton(
              icon: Icon(_currentLanguage == AppLanguage.english
                  ? Icons.language
                  : Icons.translate),
              onPressed: _toggleLanguage,
              tooltip: _currentLanguage == AppLanguage.english ? 'فارسی' : 'English',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildAnimatedReportCard(
                  title: _getString('allRegisteredMembers'),
                  color: Colors.yellow,
                  icon: AnimatedIcons.list_view,
                  animationController: _allMembersController,
                  onPressed: _showRegisteredMembers,
                ),
                _buildAnimatedReportCard(
                  title: _getString('expiringMembers'),
                  color: Colors.orange,
                  icon: AnimatedIcons.menu_close,
                  animationController: _expiringMembersController,
                  onPressed: _showExpiringRegistrations,
                ),
                _buildAnimatedReportCard(
                  title: _getString('expiredMembers'),
                  color: Colors.red,
                  icon: AnimatedIcons.close_menu,
                  animationController: _expiredMembersController,
                  onPressed: _showExpiredRegistrations,
                ),
                _buildAnimatedReportCard(
                  title: _getString('oneMonthRegistrations'),
                  color: Colors.blue,
                  icon: AnimatedIcons.event_add,
                  animationController: _oneMonthController,
                  onPressed: () => _showPersonsByDuration('One Month'),
                ),
                _buildAnimatedReportCard(
                  title: _getString('threeMonthsRegistrations'),
                  color: Colors.green,
                  icon: AnimatedIcons.play_pause,
                  animationController: _threeMonthsController,
                  onPressed: () => _showPersonsByDuration('Three Months'),
                ),
                _buildAnimatedReportCard(
                  title: _getString('sixMonthsRegistrations'),
                  color: Colors.purple,
                  icon: AnimatedIcons.search_ellipsis,
                  animationController: _sixMonthsController,
                  onPressed: () => _showPersonsByDuration('Six Months'),
                ),
                _buildAnimatedReportCard(
                  title: _getString('oneYearRegistrations'),
                  color: Colors.teal,
                  icon: AnimatedIcons.ellipsis_search,
                  animationController: _oneYearController,
                  onPressed: () => _showPersonsByDuration('One Year'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedReportCard({
    required String title,
    required Color color,
    required AnimatedIconData icon,
    required AnimationController animationController,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.1).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeInOut,
          ),
        ),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedIcon(
                icon: icon,
                progress: animationController,
                size: 40,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRegisteredMembers() async {
    List<Person> persons = await _dbHelper.getAllPersons();
    _showReportDialog(
      title: _getString('allRegisteredMembers'),
      persons: persons,
      showDaysRemaining: false,
    );
  }

  Future<void> _showExpiredRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiredPersons();
    _showReportDialog(
      title: _getString('expiredMembers'),
      persons: persons,
      showDaysRemaining: false,
    );
  }

  Future<void> _showExpiringRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiringPersons(10);
    _showReportDialog(
      title: _getString('expiringMembers'),
      persons: persons,
      showDaysRemaining: true,
    );
  }

  Future<void> _showPersonsByDuration(String duration) async {
    List<Person> persons = await _dbHelper.getPersonsByDuration(duration);
    _showReportDialog(
      title: duration,
      persons: persons,
      showDaysRemaining: false,
    );
  }

  void _showReportDialog({
    required String title,
    required List<Person> persons,
    required bool showDaysRemaining,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(title, style: const TextStyle(color: Colors.yellow)),
        content: SizedBox(
          width: double.maxFinite,
          child: persons.isEmpty
              ? Text(
            _getString('noRecordsFound'),
            style: const TextStyle(color: Colors.white),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: persons.length,
            itemBuilder: (context, index) {
              return _buildPersonCard(persons[index], showDaysRemaining);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              _getString('close'),
              style: const TextStyle(color: Colors.yellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Person person, bool showDaysRemaining) {
    int daysRemaining = 0;

    if (showDaysRemaining) {
      DateTime today = DateTime.now();
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(person.startDate);
      int durationMonths = DatabaseHelper().durationToMonths(person.duration);
      DateTime endDate = DateTime(
        startDate.year,
        startDate.month + durationMonths,
        startDate.day,
      );
      daysRemaining = endDate.difference(today).inDays;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      color: const Color(0xFF3B3B3B), // Dark card color
      child: ListTile(
        leading: person.imagePath != null && person.imagePath!.isNotEmpty
            ? CircleAvatar(
          backgroundImage: FileImage(File(person.imagePath!)),
          radius: 25,
        )
            : const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.yellow,
          child: Icon(Icons.person, color: Colors.black),
        ),
        title: Text(
          '${person.firstName} ${person.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: showDaysRemaining
            ? Text(
          '$daysRemaining ${_getString('daysRemaining')}',
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }
}
