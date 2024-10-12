import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Person> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    List<Person> favorites = await _dbHelper.getFavoritePersons();
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _toggleFavorite(Person person) async {
    await _dbHelper.toggleFavorite(person);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(person.isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites')),
    );
  }

  Future<void> _deletePerson(int id) async {
    await _dbHelper.deletePerson(id);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Person deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
      appBar: AppBar(
        title: const Text('Favorite Members'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite members yet.',
                style: TextStyle(color: Colors.yellow, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final person = _favorites[index];
                return Card(
                  color: Colors.yellow.shade300,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: person.imagePath != null
                        ? Image.file(
                            File(person.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person,
                            size: 50, color: Colors.black),
                    title: Text(
                      '${person.firstName} ${person.lastName}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Age: ${person.age}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this person?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deletePerson(person.id!);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
