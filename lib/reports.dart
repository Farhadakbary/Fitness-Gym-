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
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.yellow,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient:RadialGradient(
            colors: [Colors.yellow, Colors.black54],

          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ReportButton(
              title: 'Registered Members',
              color: Colors.yellow,
              onPressed: _showRegisteredMembers,
            ),
            const SizedBox(height: 20),
            ReportButton(
              title: 'Expired Registrations',
              color: Colors.red,
              onPressed: _showExpiredRegistrations,
            ),
            const SizedBox(height: 20),
            ReportButton(
              title: 'Expiring Registrations',
              color: Colors.orange,
              onPressed: _showExpiringRegistrations,
            ),
          ],
        ),
      ),
    );
  }

  /// Displays all registered members
  Future<void> _showRegisteredMembers() async {
    List<Person> persons = await _dbHelper.getAllPersons();

    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: 'Registered Members',
        persons: persons,
        showDaysRemaining: false,
      ),
    );
  }

  /// Displays members whose registrations have expired
  Future<void> _showExpiredRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiredPersons();

    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: 'Expired Registrations',
        persons: persons,
        showDaysRemaining: false,
      ),
    );
  }

  /// Displays members whose registrations are about to expire within 10 days
  Future<void> _showExpiringRegistrations() async {
    List<Person> persons = await _dbHelper.getExpiringPersons(10);

    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: 'Expiring Registrations',
        persons: persons,
        showDaysRemaining: true,
      ),
    );
  }
}

/// A reusable button widget for reports
class ReportButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const ReportButton({
    super.key,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: color, // Text color
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// A dialog widget to display report information
class ReportDialog extends StatelessWidget {
  final String title;
  final List<Person> persons;
  final bool showDaysRemaining;

  const ReportDialog({
    super.key,
    required this.title,
    required this.persons,
    this.showDaysRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      content: SizedBox(
        width: double.maxFinite,
        child: persons.isEmpty
            ? const Text('No records found.', style: TextStyle(color: Colors.black))
            : ListView.builder(
          shrinkWrap: true,
          itemCount: persons.length,
          itemBuilder: (context, index) {
            Person person = persons[index];
            int daysRemaining = 0;

            if (showDaysRemaining) {
              DateTime today = DateTime.now();
              DateTime startDate = DateFormat('yyyy-MM-dd').parse(person.startDate);
              int durationMonths = DatabaseHelper().durationToMonths(person.duration);
              DateTime endDate = DateTime(startDate.year, startDate.month + durationMonths, startDate.day);
              daysRemaining = endDate.difference(today).inDays;
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
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
                    color: Colors.black,
                  ),
                ),
                subtitle: showDaysRemaining
                    ? Text(
                  '$daysRemaining days remaining',
                  style: const TextStyle(color: Colors.black),
                )
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
