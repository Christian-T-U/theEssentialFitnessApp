import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../common/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'home.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String? selectedDay;

  final List<String> items = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  int _dayConvert(String day) {
    switch (day) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
    }
    return 7;
  }

  Future<void> _addExercise() async {
    if (selectedDay == null) return;
    final String name = nameController.text.trim();
    if (name.isEmpty) return;
    final int reps = int.tryParse(repsController.text) ?? 0;
    final int sets = int.tryParse(setsController.text) ?? 0;
    final double weight = double.tryParse(weightController.text) ?? 0;
    final int day = _dayConvert(selectedDay!);
    exerciseArray!.addAll([day, name, reps, sets, weight]);
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'exercises': exerciseArray,
    });
    setState(() {});
    nameController.clear();
    setsController.clear();
    repsController.clear();
    weightController.clear();
  }

  Future<void> _deleteExercise(int idx) async {
    if (exerciseArray == null) return;
    if (idx < 0 || idx + 4 >= exerciseArray!.length) return;
    for (int i = 0; i < 5; i++) {
      exerciseArray!.removeAt(idx);
    }
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'exercises': exerciseArray,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/app_background.jpg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(Icons.home, color: Colors.blue, size: 28),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 110,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Day",
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedDay,
                                    items:
                                        items.map((day) {
                                          return DropdownMenuItem(
                                            value: day,
                                            child: Text(day),
                                          );
                                        }).toList(),
                                    onChanged: (v) {
                                      setState(() => selectedDay = v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: "Exercise Name",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: setsController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Sets",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: repsController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Reps",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: weightController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Weight (lbs)",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              onPressed: _addExercise,
                              icon: const Icon(Icons.add),
                              label: const Text("Add Exercise"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (exerciseArray != null && exerciseArray!.isNotEmpty)
                      ListView.builder(
                        itemCount: exerciseArray!.length ~/ 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          int idx = i * 5;

                          final base = exerciseArray![idx];
                          final name = exerciseArray![base + 1];
                          final reps = exerciseArray![base + 2];
                          final sets = exerciseArray![base + 3];
                          final weight = exerciseArray![base + 4];

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              ),
                              subtitle: Text(
                                "$name  •  $sets x $reps @ ${weight}lbs",
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteExercise(idx),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      const Text(
                        "No exercises created.",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
