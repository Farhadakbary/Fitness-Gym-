import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';
import 'package:clup_management/favorite.dart';
import 'package:clup_management/EditMember.dart';
import 'package:intl/intl.dart';

class AllMember extends StatefulWidget {
  const AllMember({super.key});

  @override
  State<AllMember> createState() => _AllMemberState();
}

enum SortOption { name, registrationDate }

class _AllMemberState extends State<AllMember> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Person> _allPersons = [];
  List<Person> _filteredPersons = [];
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.name;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    List<Person> persons = await _dbHelper.getAllPersons();
    setState(() {
      _allPersons = persons;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredPersons = _allPersons.where((person) {
      final fullName = '${person.firstName} ${person.lastName}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();

    if (_currentSortOption == SortOption.name) {
      _filteredPersons.sort((a, b) {
        final nameA = '${a.firstName} ${a.lastName}'.toLowerCase();
        final nameB = '${b.firstName} ${b.lastName}'.toLowerCase();
        return nameA.compareTo(nameB);
      });
    } else if (_currentSortOption == SortOption.registrationDate) {
      _filteredPersons.sort((a, b) {
        DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.startDate);
        DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.startDate);
        return dateA.compareTo(dateB);
      });
    }

    setState(() {});
  }

  Future<void> _deletePerson(int id) async {
    await _dbHelper.deletePerson(id);
    _loadPersons();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Person deleted')),
    );
  }

  Future<void> _toggleFavorite(Person person) async {
    await _dbHelper.toggleFavorite(person);
    _loadPersons();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(person.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites')),
    );
  }

  Future<void> _editPerson(Person person) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMember(person: person),
      ),
    );

    if (isUpdated != null && isUpdated) {
      _loadPersons();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person updated')),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onSortSelected(SortOption option) {
    setState(() {
      _currentSortOption = option;
      _applyFilters();
    });
  }

  bool _isExpired(String startDateStr, String durationStr) {
    try {
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDateStr);
      int durationMonths = int.parse(durationStr);
      DateTime endDate = DateTime(
        startDate.year,
        startDate.month + durationMonths,
        startDate.day,
      );
      return endDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Color _getCardColor(bool isExpired) {
  //   if (isExpired) {
  //     return Colors.grey.shade800;
  //   }
  //   return Colors.black;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
      appBar: AppBar(
        title: const Text('All Members'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Favorite()),
              );
            },
            tooltip: 'View Favorites',
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: _onSortSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.registrationDate,
                child: Text('Sort by Registration Date'),
              ),
            ],
            tooltip: 'Sort Members',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredPersons.isEmpty
          ? const Center(
              child: Text(
                'No members found.',
                style: TextStyle(color: Colors.yellow, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _filteredPersons.length,
              itemExtent: 80,
              itemBuilder: (context, index) {
                final person = _filteredPersons[index];
                bool isExpired = _isExpired(person.startDate, person.duration);

                return GestureDetector(
                  onTap: () {
                    _editPerson(person);
                  },
                  child: Card(
                    color: Colors.yellow.shade300,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: person.imagePath != null
                          ? CircleAvatar(
                              backgroundImage:
                                  FileImage(File(person.imagePath!)),
                              radius: 25,
                              backgroundColor: Colors.grey.shade800,
                            )
                          : const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.yellow,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                      title: Text(
                        '${person.firstName} ${person.lastName}',
                        style:const TextStyle(
                          color:  Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              person.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  person.isFavorite ? Colors.red : Colors.black,
                            ),
                            onPressed: () async {
                              await _toggleFavorite(person);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text(
                                      'Are you sure you want to delete this person?',style:TextStyle(fontSize: 20)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        'No',
                                        style: TextStyle(color: Colors.red,fontSize: 20),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deletePerson(person.id!);
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(color: Colors.green,fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
