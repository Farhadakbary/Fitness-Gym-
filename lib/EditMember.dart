// EditMember.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clup_management/database_helper.dart';
import 'package:clup_management/person.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditMember extends StatefulWidget {
  final Person person;

  const EditMember({super.key, required this.person});

  @override
  State<EditMember> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _feeController;

  // For image
  File? _imageFile;

  // For date
  DateTime? _selectedDate;

  // For duration
  String? _selectedDuration;
  final List<String> _durations = [
    'One Month',
    'Three Months',
    'Six Months',
    'One Year'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _firstNameController = TextEditingController(text: widget.person.firstName);
    _lastNameController = TextEditingController(text: widget.person.lastName);
    _ageController = TextEditingController(text: widget.person.age.toString());
    _feeController = TextEditingController(text: widget.person.fee.toString());

    _imageFile = widget.person.imagePath != null ? File(widget.person.imagePath!) : null;

    _selectedDate = widget.person.startDate.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(widget.person.startDate)
        : DateTime.now();

    _selectedDuration = widget.person.duration;
  }

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
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);

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

  // Update fee based on duration
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

  // Save updated person to the database
  Future<void> _savePerson() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a start date')),
        );
        return;
      }

      final updatedPerson = Person(
        id: widget.person.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        age: int.parse(_ageController.text),
        imagePath: _imageFile?.path,
        isFavorite: widget.person.isFavorite,
        fee: double.parse(_feeController.text),
        startDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        duration: _selectedDuration ?? 'One Month',
      );

      int result = await _dbHelper.updatePerson(updatedPerson);

      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Person updated successfully')),
        );

        Navigator.pop(context, true); // Indicate that an update occurred
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update person')),
        );
      }
    }
  }

  // Get fee range description
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
        title: const Text('Edit Member'),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Edit Member',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 20),
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                // Age
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                    labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    suffixIcon: Icon(Icons.arrow_drop_down),
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
                    labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
                              fontWeight: FontWeight.bold, color: Colors.black),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
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
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
