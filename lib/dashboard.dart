import 'package:clup_management/Settings.dart';
import 'package:clup_management/about.dart';
import 'package:clup_management/all_member.dart' hide AppLanguage;
import 'package:clup_management/favorite.dart';
import 'package:clup_management/reports.dart';
import 'package:clup_management/workout.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'Add_Member.dart';
import 'database_helper.dart';
import 'person.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String language = 'English';

  final Map<String, Map<String, String>> translations = {
    'English': {
      'unic_gym': 'UNIC GYM',
      'all_members': 'All Members',
      'favorites': 'Favorites',
      'programs': 'Programs',
      'reports': 'Reports',
      'settings': 'Settings',
      'about': 'About',
      'total_registered': 'Total Registered',
      're_registered_within_10_days': 'Re-registered within 10 days',
      'not_re_registered': 'Not Re-registered',
      'membership_duration_distribution': 'Membership Duration Distribution',
      'no_records_found': 'No records found.',
    },
    'Dari': {
      'unic_gym': 'یونیک جیم',
      'all_members': 'تمام اعضا',
      'favorites': 'مورد علاقه‌ها',
      'programs': 'برنامه‌ها',
      'reports': 'گزارش‌ها',
      'settings': 'تنظیمات',
      'about': 'درباره',
      'total_registered': 'کل ثبت‌نام شده',
      're_registered_within_10_days': 'ده روز مانده',
      'not_re_registered': 'دوباره ثبت‌نام نشده',
      'membership_duration_distribution': 'توزیع مدت عضویت',
      'no_records_found': 'هیچ کس ثبت نام نشد.',
      'One Month': 'یک ماهه',
      'Three Months': 'سه ماهه',
      'Six Months': 'شیش ماهه',
      'One Year': 'یک ساله',
    },
  };

  @override
  void initState() {
    super.initState();
    fetchData();
    loadLanguage(); // Load language on initialization
  }

  Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'English';
    });
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

    final t = translations[language]!;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
      drawer: Drawer(
        backgroundColor: Colors.yellow.shade100,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                t['unic_gym']!,
                style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              accountEmail: null,
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'U',
                  style: TextStyle(fontSize: 40.0, color: Colors.purple),
                ),
              ),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/desc.jpg'), fit: BoxFit.cover)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: Text(
                t['all_members']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllMember()))
                    .then((_) {
                  fetchData();
                  loadLanguage(); // Reload language in case it changed
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: Text(
                t['favorites']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Favorite()))
                    .then((_) {
                  fetchData();
                  loadLanguage();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.black),
              title: Text(
                t['programs']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkoutPage())).then((_) {
                  loadLanguage();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.black),
              title: Text(
                t['reports']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportPage())).then((_) {
                  loadLanguage();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: Text(
                t['settings']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                          updateTheme: widget.onThemeChanged,
                          updateFontSize: (fontSize) {}, currentLanguage: AppLanguage.english, updateLanguage: (AppLanguage ) {  },
                        )))
                    .then((_) {
                  fetchData();
                  loadLanguage(); // Reload language after settings
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded, color: Colors.black),
              title: Text(
                t['about']!,
                style: const TextStyle(color: Colors.black),
              ),
              trailing:
              const Icon(Icons.navigate_next_rounded, color: Colors.black),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutPage())).then((_) {
                  loadLanguage();
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          t['unic_gym']!,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
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
                  animateToClosest: true,
                  enableInfiniteScroll: true,
                  pageSnapping: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  viewportFraction: 0.8,
                  autoPlayCurve: Curves.decelerate,
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
              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      t['total_registered']!,
                      '$totalRegistered',
                      Colors.yellow.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildStatCard(
                      t['re_registered_within_10_days']!,
                      '$reRegisteredWithin10Days',
                      Colors.yellow.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      t['not_re_registered']!,
                      '$notReRegistered',
                      Colors.yellow.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Membership Duration Distribution
              Text(
                t['membership_duration_distribution']!,
                style: const TextStyle(
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
                        t[entry.key] ?? entry.key,
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
             const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMember(),
            ),
          ).then((_) {
            fetchData();
            loadLanguage(); // Reload language after adding a member
          });
        },
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add),
      ),
    );
  }
}
