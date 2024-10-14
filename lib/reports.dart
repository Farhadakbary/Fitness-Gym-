import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReportCard(
                title: 'All Registered Members',
                color: Colors.yellow,
                icon: Icons.people,
                onPressed: _showRegisteredMembers,
              ),
              const SizedBox(height: 20),
              _buildReportCard(
                title: 'Expiring Members',
                color: Colors.orange,
                icon: Icons.hourglass_empty,
                onPressed: _showExpiringRegistrations,
              ),
              const SizedBox(height: 20),
              _buildReportCard(
                title: 'Expired Members',
                color: Colors.red,
                icon: Icons.cancel,
                onPressed: _showExpiredRegistrations,
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
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
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 30),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Future<void> _showRegisteredMembers() async {
    List<Person> persons = await _dbHelper.getAllPersons();
    _showReportDialog(
      title: 'Registered Members',
      persons: persons,
      showDaysRemaining: false,
    );
  }

  Future<void> _showExpiredRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiredPersons();
    _showReportDialog(
      title: 'Expired Registrations',
      persons: persons,
      showDaysRemaining: false,
    );
  }

  Future<void> _showExpiringRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiringPersons(10);
    _showReportDialog(
      title: 'Expiring Registrations',
      persons: persons,
      showDaysRemaining: true,
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
              ? const Text('No records found.', style: TextStyle(color: Colors.white))
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
            child: const Text('Close', style: TextStyle(color: Colors.yellow)),
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
      DateTime endDate = DateTime(startDate.year, startDate.month + durationMonths, startDate.day);
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
          '$daysRemaining days remaining',
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }
}