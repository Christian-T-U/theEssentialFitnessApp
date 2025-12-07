import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../common/global.dart';
import 'running.dart';
import 'workout.dart';
import 'leaderboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isVisible = false;
  bool _isVisible1 = false;
  List<dynamic> todaysGoals = [];

  void temp() {
    print('pressed');
  }

  Future<void> _loadTodayGoals() async {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    if (exerciseArray != null) {
      if (exerciseArray!.isNotEmpty) {
        for (int i = 0; i < exerciseArray!.length; i += 5) {
          if (exerciseArray![i] == dayOfWeek) {
            todaysGoals.add(exerciseArray![i]);
            todaysGoals.add(exerciseArray![i + 1]);
            todaysGoals.add(exerciseArray![i + 2]);
            todaysGoals.add(exerciseArray![i + 3]);
            todaysGoals.add(exerciseArray![i + 4]);
          }
        }
        setState(() {
          todaysGoals;
        });
      }
    }
  }

  @override
  void initState() {
    _loadTodayGoals();

    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isVisible = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _isVisible1 = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/app_background.jpg', fit: BoxFit.cover),
          ),
          AnimatedSlide(
            offset: _isVisible ? Offset(0, 0) : Offset(0, -1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: temp,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: Colors.white,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(Icons.settings, color: Colors.blue, size: 24),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedSlide(
                    offset: _isVisible ? Offset(0, 0) : Offset(0, -1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          nametag ?? "Error: nametag didn't load",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: AnimatedSlide(
                    offset: _isVisible ? Offset(0, 0) : Offset(0, 10),
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeInOut,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Tip: ${tip!}",
                          style: TextStyle(fontSize: 16, color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSlide(
                  offset: _isVisible ? Offset(0, 0) : Offset(0, 30),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => runningPage(),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.directions_run,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExercisesPage(),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderboardPage(),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderboardPage(),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Icon(
                                  Icons.bar_chart,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSlide(
                    offset:
                        _isVisible1 ? const Offset(0, 0) : const Offset(0, 35),
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.easeInOut,
                    child:
                        todaysGoals.isEmpty
                            ? const Center(
                              child: Text(
                                "No goals for today!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: todaysGoals.length ~/ 5,
                              itemBuilder: (context, index) {
                                final base = index * 5;
                                final name = todaysGoals[base + 1];
                                final reps = todaysGoals[base + 2];
                                final sets = todaysGoals[base + 3];
                                final weight = todaysGoals[base + 4];

                                return SizedBox(
                                  width: 200,
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),

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
                                    ),
                                  ),
                                );
                              },
                            ),
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
