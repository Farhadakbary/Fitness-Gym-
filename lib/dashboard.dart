import 'package:clup_management/Settings.dart';
import 'package:clup_management/about.dart';
import 'package:clup_management/all_member.dart';
import 'package:clup_management/favorite.dart';
import 'package:clup_management/reports.dart';
import 'package:clup_management/workout.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Add_Member.dart';
import 'database_helper.dart';
import 'person.dart';

class Dashboard extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const Dashboard({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int totalRegistered = 0;
  int reRegisteredWithin10Days = 0;
  int notReRegistered = 0;
  Map<String, int> durationCounts = {};

  List<String> imagePaths = [
    'images/arm.jpg',
    'images/leg.jpg',
    'images/chest.jpg',
    'images/desc.jpg',
    'images/desc1.jpg',
    'images/desc2.jpg',
    'images/desc3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<Person> persons = await _dbHelper.getAllPersons();

    int total = persons.length;
    int reRegistered = 0;
    int notReRegisteredCount = 0;

    Map<String, int> tempDurationCounts = {
      'One Month': 0,
      'Three Months': 0,
      'Six Months': 0,
      'One Year': 0,
    };

    DateTime today = DateTime.now();

    for (var person in persons) {
      // Count duration
      if (tempDurationCounts.containsKey(person.duration)) {
        tempDurationCounts[person.duration] =
            tempDurationCounts[person.duration]! + 1;
      } else {
        tempDurationCounts[person.duration] = 1;
      }

      if (person.isExpiringWithin(10)) {
        reRegistered += 1;
      }

      if (person.hasExpired()) {
        notReRegisteredCount += 1;
      }
    }

    setState(() {
      totalRegistered = total;
      reRegisteredWithin10Days = reRegistered;
      notReRegistered = notReRegisteredCount;
      durationCounts = tempDurationCounts;
    });
  }

  Widget buildStatCard(String title, String value, Color color) {
    return Card(
      color: color,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
      drawer: Drawer(
      backgroundColor: Colors.yellow.shade100,
      child: Column(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text(
              'UNIC GYM',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'U',
                style: TextStyle(fontSize: 40.0, color: Colors.purple),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('images/desc.jpg'),fit: BoxFit.cover)
              // gradient: LinearGradient(
              //     colors: [Colors.yellow, Colors.black],
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('All Members',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllMember()))
                  .then((_) => fetchData());
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.black),
            title: const Text('Favorites',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Favorite()))
                  .then((_) => fetchData());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.black),
            title: const Text('Programs',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkoutPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.black),
            title: const Text('Reports',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black),
            title: const Text('Settings',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        updateTheme: widget.onThemeChanged,
                        updateFontSize: (fontSize) {},
                      ))).then((_) => fetchData());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_rounded, color: Colors.black),
            title: const Text('About',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.navigate_next_rounded, color: Colors.black),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
    ),
    appBar: AppBar(
        title: const Text('UNIC GYM'),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Slider
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayInterval: const Duration(seconds: 3),
                  viewportFraction: 0.8,
                ),
                items: imagePaths.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.asset(imagePath, fit: BoxFit.cover);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Cards for Statistics
              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      'Total Registered',
                      '$totalRegistered',
                      Colors.yellow.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildStatCard('Re-registered within 10 days',
                        '$reRegisteredWithin10Days', Colors.yellow.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildStatCard('Not Re-registered',
                        '$notReRegistered', Colors.yellow.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Membership Duration Distribution
              const Text(
                'Membership Duration Distribution',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Column(
                children: durationCounts.entries.map((entry) {
                  return Card(
                    color: Colors.yellow.shade400,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(), // صفحه افزودن شخص
            ),
          ).then((_) => fetchData());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.yellow,
      ),
    );
  }
}
