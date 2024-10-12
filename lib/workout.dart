// WorkoutPage.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // Initial exercises map with English category names
  Map<String, List<String>> exercises = {
    'Arms': [
      'Dumbbell Exercise',
      'Pull-Up Exercise',
      'Bicep Exercise',
      'Tricep Exercise',
    ],
    'Legs': [
      'Squat',
      'Lunges',
      'Leg Press',
      'Hamstring Stretch',
    ],
    'Chest': [
      'Chest Press',
      'Push-Up',
      'Dumbbell Chest Fly',
      'Chest Stretch',
    ],
    'First Month': [
      'Brisk Walking',
      'Light Jogging',
      'Stretching Exercises',
      'Basic Yoga',
    ],
    'Second': ['Chest Press', 'Upper Chest', 'Bicep', 'Tricep']
  };

  // Map to store image paths for each category
  final Map<String, String> categoryImages = {
    'Arms': 'images/arm.jpg',
    'Legs': 'images/leg.jpg',
    'Chest': 'images/chest.jpg',
    'First Month': 'images/beg.jpg',
    'Second': 'images/second.jpg'
  };

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        title: const Text('Training Programs'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: exercises.keys.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            String category = exercises.keys.elementAt(index);
            String imagePath =
                categoryImages[category] ?? 'assets/images/default.jpg';

            return GestureDetector(
              onTap: () {
                _showExercisesBottomSheet(context, category);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        tooltip: 'Add New Category',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Displays the bottom sheet with exercises and options to add/remove
  void _showExercisesBottomSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // To make full-screen dialogs if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // To manage state within the bottom sheet
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Exercises in $category',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  // List of Exercises
                  Expanded(
                    child: exercises[category]!.isEmpty
                        ? const Center(
                      child: Text(
                        'No exercises added.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      itemCount: exercises[category]!.length,
                      itemBuilder: (context, index) {
                        String exercise = exercises[category]![index];
                        return ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(
                            exercise,
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Confirm deletion
                              _confirmDeleteExercise(
                                  context, category, index);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Exercise "$exercise" selected')),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Add Exercise Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddExerciseDialog(context, category, setState);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows a dialog to confirm deletion of an exercise
  void _confirmDeleteExercise(
      BuildContext context, String category, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: const Text('Are you sure you want to delete this exercise?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  exercises[category]!.removeAt(index);
                });
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the bottom sheet
                _showExercisesBottomSheet(context, category); // Refresh bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exercise deleted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog to add a new exercise
  void _showAddExerciseDialog(
      BuildContext context, String category, Function setState) {
    final TextEditingController exerciseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Exercise'),
          content: TextField(
            controller: exerciseController,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newExercise = exerciseController.text.trim();
                if (newExercise.isNotEmpty) {
                  setState(() {
                    exercises[category]!.add(newExercise);
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _showExercisesBottomSheet(context, category); // Refresh bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                        Text('Exercise "$newExercise" added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid exercise name')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to add a new workout category
  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newCategory = '';
    List<String> newExercises = [];
    TextEditingController exerciseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Name Field
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the category name';
                          }
                          if (exercises.containsKey(value)) {
                            return 'This category has already been added';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          newCategory = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Select Image
                      Row(
                        children: [
                          _selectedImage == null
                              ? Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.image,
                                size: 40, color: Colors.grey),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _pickImage(setState);
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Select Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Exercises Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Exercises',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Add Exercise Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: exerciseController,
                              decoration: const InputDecoration(
                                labelText: 'New Exercise',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              String exercise =
                              exerciseController.text.trim();
                              if (exercise.isNotEmpty) {
                                setState(() {
                                  newExercises.add(exercise);
                                  exerciseController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // List of Added Exercises
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: newExercises.isEmpty
                            ? const Center(
                            child: Text('No exercises added'))
                            : ListView.builder(
                          itemCount: newExercises.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(newExercises[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    newExercises.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (newExercises.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text('Please add at least one exercise')),
                    );
                    return;
                  }
                  if (_selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select an image')),
                    );
                    return;
                  }
                  formKey.currentState!.save();
                  setState(() {
                    exercises[newCategory] = newExercises;
                    categoryImages[newCategory] = _selectedImage!.path;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                        Text('Category "$newCategory" added successfully')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((_) {
      exerciseController.dispose(); // Dispose controller after dialog
    });
  }

  Future<void> _pickImage(
      void Function(void Function()) setState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
}
