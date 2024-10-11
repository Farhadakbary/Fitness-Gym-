import 'package:intl/intl.dart';

class Person {
  int? id;
  String firstName;
  String lastName;
  int age;
  String? imagePath;
  bool isFavorite;
  double fee;
  String startDate;
  String duration;

  Person({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.imagePath,
    this.isFavorite = false,
    required this.fee,
    required this.startDate,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0,
      'fee': fee,
      'startDate': startDate,
      'duration': duration,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      age: map['age'],
      imagePath: map['imagePath'],
      isFavorite: map['isFavorite'] == 1,
      fee: map['fee'] != null ? map['fee'].toDouble() : 1000.0,
      startDate: map['startDate'] ?? '',
      duration: map['duration'] ?? 'One Month',
    );
  }

  DateTime get endDate {
    DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
    switch (duration) {
      case 'One Month':
        return DateTime(start.year, start.month + 1, start.day);
      case 'Three Months':
        return DateTime(start.year, start.month + 3, start.day);
      case 'Six Months':
        return DateTime(start.year, start.month + 6, start.day);
      case 'One Year':
        return DateTime(start.year + 1, start.month, start.day);
      default:
        return DateTime(start.year, start.month + 1, start.day);
    }
  }

  bool isExpiringWithin(int days) {
    DateTime today = DateTime.now();
    DateTime expiration = endDate;
    Duration difference = expiration.difference(today);
    return difference.inDays <= days && difference.inDays >= 0;
  }

  bool hasExpired() {
    DateTime today = DateTime.now();
    DateTime expiration = endDate;
    return today.isAfter(expiration);
  }
}
