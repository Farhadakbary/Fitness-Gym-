import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  Map<String, List<String>> exercises = {
    'بازو': [
      'تمرین دمبل',
      'تمرین بارفیکس',
      'تمرین جلو بازو',
      'تمرین پشت بازو',
    ],
    'پا': [
      'اسکوات',
      'لانگز',
      'پرس پا',
      'کشش همسترینگ',
    ],
    'سینه': [
      'پرس سینه',
      'پوش آپ',
      'پرواز سینه با دمبل',
      'کشش سینه',
    ],
    'ماه اول': [
      'پیاده‌روی سریع',
      'دویدن ملایم',
      'تمرینات کششی',
      'یوگا پایه',
    ],
    'Second': ['پرس سینه', 'بالا سینه', 'جلو بازو', 'پشت بازو']
  };

  final Map<String, String> categoryImages = {
    'بازو': 'images/arm.jpg',
    'پا': 'images/leg.jpg',
    'سینه': 'images/chest.jpg',
    'ماه اول': 'images/beg.jpg',
    'Second': 'images/second.jpg'
  };

  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      appBar: AppBar(
        title: const Text(' Training Programs'),
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
        tooltip: 'افزودن دسته‌بندی جدید',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showExercisesBottomSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'تمرینات $category',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises[category]!.length,
                  itemBuilder: (context, index) {
                    String exercise = exercises[category]![index];
                    return ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(
                        exercise,
                        style: const TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('تمرین "$exercise" انتخاب شد')),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newCategory = '';
    List<String> newExercises = [];
    TextEditingController exerciseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('افزودن دسته‌بندی جدید'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'نام دسته‌بندی',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفاً نام دسته‌بندی را وارد کنید';
                          }
                          if (exercises.containsKey(value)) {
                            return 'این دسته‌بندی قبلاً اضافه شده است';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          newCategory = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      // انتخاب تصویر
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
                            label: const Text(' تصویر'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'تمرینات',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: exerciseController,
                              decoration: const InputDecoration(
                                labelText: 'تمرین جدید',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              String exercise = exerciseController.text.trim();
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

                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: newExercises.isEmpty
                            ? const Center(
                                child: Text('هیچ تمرینی اضافه نشده است'))
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
                Navigator.of(context).pop(); // بستن Dialog
              },
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (newExercises.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('لطفاً حداقل یک تمرین اضافه کنید')),
                    );
                    return;
                  }
                  if (_selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('لطفاً یک تصویر انتخاب کنید')),
                    );
                    return;
                  }
                  formKey.currentState!.save();
                  setState(() {
                    exercises[newCategory] = newExercises;
                    categoryImages[newCategory] = _selectedImage!.path;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('دسته‌بندی "$newCategory" اضافه شد')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              child: const Text('افزودن'),
            ),
          ],
        );
      },
    ).then((_) {
      exerciseController.dispose();
    });
  }

  Future<void> _pickImage(void Function(void Function()) setState) async {
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
