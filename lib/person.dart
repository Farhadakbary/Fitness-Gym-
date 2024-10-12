import 'package:intl/intl.dart';

class Person {
  final int? id;
  final String firstName;
  final String lastName;
  final int age;
  final String duration;
  final double fee;
  final String startDate;
  final String? imagePath;
  bool isFavorite;

  Person({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.duration,
    required this.fee,
    required this.startDate,
    this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'duration': duration,
      'fee': fee,
      'startDate': startDate,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      age: map['age'],
      duration: map['duration'],
      fee: map['fee'],
      startDate: map['startDate'],
      imagePath: map['imagePath'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  bool isExpiringWithin(int days) {
    try {
      DateTime today = DateTime.now();
      DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
      int durationMonths = durationToMonths(duration);
      DateTime endDate = DateTime(start.year, start.month + durationMonths, start.day);
      Duration difference = endDate.difference(today);
      return difference.inDays <= days && difference.isNegative == false;
    } catch (e) {
      print('Error in isExpiringWithin: $e');
      return false;
    }
  }

  bool hasExpired() {
    try {
      DateTime today = DateTime.now();
      DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
      int durationMonths = durationToMonths(duration);
      DateTime endDate = DateTime(start.year, start.month + durationMonths, start.day);
      return endDate.isBefore(today);
    } catch (e) {
      print('Error in hasExpired: $e');
      return false;
    }
  }
  int durationToMonths(String duration) {
    switch (duration.toLowerCase()) {
      case 'one month':
        return 1;
      case 'three months':
        return 3;
      case 'six months':
        return 6;
      case 'one year':
        return 12;
      default:
        return 1;
    }
  }
}
