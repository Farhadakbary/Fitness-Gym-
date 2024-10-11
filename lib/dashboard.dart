import 'package:clup_management/Settings.dart';
import 'package:clup_management/about.dart';
import 'package:clup_management/all_member.dart';
import 'package:clup_management/favorite.dart';
import 'package:clup_management/workout.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, RouteAware {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  int totalRegistered = 0;
  int reRegisteredWithin10Days = 0;
  int notReRegistered = 0;

  Map<String, int> durationCounts = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    fetchData(); // Refresh data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade500, // Dark gray background
      drawer: Drawer(
        backgroundColor: Colors.yellow.shade200,
        child: Column(
          children: <Widget>[
            // Drawer Header
            const UserAccountsDrawerHeader(
              accountName: Text(
                'UNIC GYM',
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
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
                gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('All Members',
                  style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {
                // Navigate to AllMember
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllMember())).then((_) {
                  fetchData(); // Refresh data when returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text('Favorites',
                  style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Favorite())).then((_) {
                  fetchData(); // Refresh data when returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.black),
              title:
                  const Text('Programs', style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const WorkoutPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.black),
              title:
                  const Text('Reports', style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                              updateTheme: (isDarkMode) {
                                widget.onThemeChanged(isDarkMode);
                              },
                              updateFontSize: (fontSize) {
                                // Update your app font size here
                              },
                            ))).then((_) {
                  fetchData(); // Refresh data when returning
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded, color: Colors.black),
              title: const Text('About', style: TextStyle(color: Colors.black)),
              trailing:
                  const Icon(Icons.navigate_next_rounded, color: Colors.black),
              splashColor: Colors.white24,
              onTap: () {
                // Navigate to About
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
              const Text(
                'Registration Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Pie Chart for Registration Statistics
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: showingPieSections(),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Indicators for Pie Chart
              const Column(
                children: [
                  Indicator(
                    color: Colors.green,
                    text: 'Registered',
                    isSquare: true,
                    textColor: Colors.black,
                  ),
                  Indicator(
                    color: Colors.yellow,
                    text: 'Less than 10 days remaining',
                    isSquare: true,
                    textColor: Colors.black,
                  ),
                  Indicator(
                    color: Colors.red,
                    text: 'Not Re-registered',
                    isSquare: true,
                    textColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Second Chart Title
              const Text(
                'Membership Duration Distribution',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Second Chart: Doughnut Chart
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: showingDurationPieSections(),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Indicators for Duration Pie Chart
              Column(
                children: durationCounts.entries.map((entry) {
                  return Indicator(
                    color: getDurationColor(entry.key),
                    text: '${entry.key}: ${entry.value}',
                    isSquare: true,
                    textColor: Colors.black,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ).then((_) {
            // Refresh data when returning from HomePage
            fetchData();
          });
        },
      ),
    );
  }

  // Generate Pie Chart Sections for Registration Statistics
  List<PieChartSectionData> showingPieSections() {
    return [
      PieChartSectionData(
        color: Colors.green,
        value: totalRegistered.toDouble(),
        title: '$totalRegistered',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: reRegisteredWithin10Days.toDouble(),
        title: '$reRegisteredWithin10Days',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: notReRegistered.toDouble(),
        title: '$notReRegistered',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ];
  }

  // Generate Pie Chart Sections for Duration Distribution
  List<PieChartSectionData> showingDurationPieSections() {
    List<PieChartSectionData> sections = [];

    durationCounts.forEach((duration, count) {
      if (count == 0) return; // Skip if count is zero
      sections.add(
        PieChartSectionData(
          color: getDurationColor(duration),
          value: count.toDouble(),
          title: '$count',
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    });

    return sections;
  }

  // Assign colors based on duration
  Color getDurationColor(String duration) {
    switch (duration) {
      case 'One Month':
        return Colors.blue;
      case 'Three Months':
        return Colors.orange;
      case 'Six Months':
        return Colors.purple;
      case 'One Year':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}

// Indicator Widget
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        )
      ],
    );
  }
}
