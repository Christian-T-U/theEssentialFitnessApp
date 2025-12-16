import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  int _dtoi(String day) {
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

  String _itod(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
    }
    return 'Sunday';
  }

  Future<void> _addExercise() async {
    if (selectedDay == null) return;
    final String name = nameController.text.trim();
    if (name.isEmpty) return;
    final int reps = int.tryParse(repsController.text) ?? 0;
    final int sets = int.tryParse(setsController.text) ?? 0;
    final double weight = double.tryParse(weightController.text) ?? 0;
    final int day = _dtoi(selectedDay!);
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

  Future<void> _updateExercise(
    int idx,
    double weight,
    int sets,
    int reps,
  ) async {
    exerciseArray![idx + 2] = reps;
    exerciseArray![idx + 3] = sets;
    exerciseArray![idx + 4] = weight;

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

          GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 64),
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
                          icon: const Icon(Icons.add, color: Colors.lightGreen),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: exerciseArray!.length ~/ 5,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        int idx = i * 5;

                        final day = exerciseArray![idx];
                        final name = exerciseArray![idx + 1];
                        final reps = exerciseArray![idx + 2];
                        final sets = exerciseArray![idx + 3];
                        final weight = exerciseArray![idx + 4];

                        final listReps = TextEditingController(
                          text: reps.toString(),
                        );
                        final listSets = TextEditingController(
                          text: sets.toString(),
                        );
                        final listWeight = TextEditingController(
                          text: weight.toString(),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_itod(day)} - $name",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: listSets,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Sets",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: listReps,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Reps",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: listWeight,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Weight",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _deleteExercise(idx);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    label: const Text("Delete Exercise"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: IconButton(
                                    icon: Icon(Icons.save, color: Colors.green),
                                    onPressed: () {
                                      _updateExercise(
                                        idx,
                                        double.parse(listWeight.text),
                                        int.parse(listSets.text),
                                        int.parse(listReps.text),
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
                  )
                else
                  Expanded(
                    child: const Text(
                      "No exercises created.",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
