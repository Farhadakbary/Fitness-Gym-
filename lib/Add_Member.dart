import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';
import 'package:clup_management/all_member.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _feeController =
      TextEditingController(text: '1000');

  File? _imageFile;

  DateTime? _selectedDate;

  String? _selectedDuration;
  final List<String> _durations = [
    'One Month',
    'Three Months',
    'Six Months',
    'One Year'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  // Pick a date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateFeeRange(String? duration) {
    double minFee = 1000;
    double maxFee = 1000;

    switch (duration) {
      case 'One Month':
        minFee = 1000;
        maxFee = 1000;
        break;
      case 'Three Months':
        minFee = 2700;
        maxFee = 3000;
        break;
      case 'Six Months':
        minFee = 5000;
        maxFee = 6000;
        break;
      case 'One Year':
        minFee = 10000;
        maxFee = 11000;
        break;
      default:
        minFee = 1000;
        maxFee = 1000;
    }

    setState(() {
      _feeController.text = minFee.toString();
    });
  }

  Future<void> _savePerson() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')),
        );
        return;
      }

      final newPerson = Person(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        age: int.parse(_ageController.text),
        imagePath: _imageFile?.path,
        fee: double.parse(_feeController.text),
        startDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        duration: _selectedDuration ?? 'One Month',
      );

      await _dbHelper.insertPerson(newPerson);

      _firstNameController.clear();
      _lastNameController.clear();
      _ageController.clear();
      _feeController.text = '1000';
      setState(() {
        _imageFile = null;
        _selectedDate = null;
        _selectedDuration = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person added successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AllMember()),
      );
    }
  }

  String _getFeeRange() {
    switch (_selectedDuration) {
      case 'One Month':
        return '1000 AFN';
      case 'Three Months':
        return '2700 - 3000 AFN';
      case 'Six Months':
        return '5000 - 6000 AFN';
      case 'One Year':
        return '10000 - 11000 AFN';
      default:
        return '1000 AFN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('GYM HOME'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllMember()),
              );
            },
            tooltip: 'View All Members',
          ),
        ],
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Person',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    // first name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // last name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        suffixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // age
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        suffixIcon: Icon(Icons.accessibility_sharp),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Duration Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      value: _selectedDuration,
                      items: _durations
                          .map((duration) => DropdownMenuItem(
                                value: duration,
                                child: Text(duration),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDuration = value;
                          _updateFeeRange(value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a duration';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Fee
                    TextFormField(
                      controller: _feeController,
                      decoration: InputDecoration(
                        labelText: 'Fee',
                        border: const OutlineInputBorder(),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        suffixIcon: const Icon(Icons.money),
                        hintText: _getFeeRange(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fee';
                        }
                        final fee = double.tryParse(value);
                        if (fee == null) {
                          return 'Please enter a valid number';
                        }

                        double minFee = 1000;
                        double maxFee = 1000;

                        switch (_selectedDuration) {
                          case 'One Month':
                            minFee = 1000;
                            maxFee = 1000;
                            break;
                          case 'Three Months':
                            minFee = 2700;
                            maxFee = 3000;
                            break;
                          case 'Six Months':
                            minFee = 5000;
                            maxFee = 6000;
                            break;
                          case 'One Year':
                            minFee = 10000;
                            maxFee = 11000;
                            break;
                          default:
                            minFee = 1000;
                            maxFee = 1000;
                        }

                        if (fee < minFee || fee > maxFee) {
                          return 'Fee should be between $minFee and $maxFee AFN';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: _selectedDate == null
                                  ? ''
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!),
                            ),
                            validator: (value) {
                              if (_selectedDate == null) {
                                return 'Please select a start date';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _pickDate,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.yellow,
                          ),
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Image Picker
                    Row(
                      children: [
                        _imageFile != null
                            ? Image.file(
                                _imageFile!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.black54,
                                ),
                              ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.yellow,
                          ),
                          child: const Text('Choose Image'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePerson,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
