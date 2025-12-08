import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _loaded = false;
  List<dynamic> sortedLeaderboard = [];
  int? playerPosition;
  int _distanceSet = 1;

  @override
  void initState() {
    getLeaderboard(_distanceSet);
    super.initState();
  }

  void _reloadLeaderboard() {
    setState(() {
      _loaded = false;
      sortedLeaderboard = [];
      playerPosition = null;
      _distanceSet;
    });
    getLeaderboard(_distanceSet);
  }

  Future<void> getLeaderboard(int mi) async {
    List<dynamic> leaderboard = [];
    final users = await FirebaseFirestore.instance.collection("users").get();
    String name = "";

    if (mi == 1) {
      name = "bestRun1mi";
    } else if (mi == 2) {
      name = "bestRun2mi";
    } else if (mi == 5) {
      name = "bestRun5mi";
    } else {
      name = "bestRun10mi";
    }

    for (var doc in users.docs) {
      final data = doc.data();

      if (data[name].isNotEmpty) {
        String playerName = data["nametag"];
        Timestamp date = data[name][0];
        int time = data[name][1];

        leaderboard.addAll([
          playerName,
          time,
          "${date.toDate().month}/${date.toDate().day}/${date.toDate().year}",
        ]);
      }
    }
    for (int i = 0; i < leaderboard.length; i += 3) {
      bool inserted = false;
      for (int j = 0; j < sortedLeaderboard.length; j += 3) {
        if (leaderboard[j + 1] < sortedLeaderboard[j + 1]) {
          sortedLeaderboard.insert(j, leaderboard[i]);
          sortedLeaderboard.insert(j + 1, leaderboard[i + 1]);
          sortedLeaderboard.insert(j + 2, leaderboard[i + 2]);
          inserted = true;
          break;
        }
      }
      if (inserted == false) {
        sortedLeaderboard.addAll([
          leaderboard[i],
          leaderboard[i + 1],
          leaderboard[i + 2],
        ]);
      }
    }
    double pos = 0;
    for (int i = 0; i < sortedLeaderboard.length; i += 3) {
      if (sortedLeaderboard[i] == nametag!) {
        pos = (i / 3) + 1;
        break;
      }
    }
    if (pos != 0) {
      playerPosition = pos.floor();
    }
    setState(() {
      _loaded = true;
    });
    return;
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
              Navigator.pop(context);
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

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "-Leaderboards-",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 16),
                _loaded == false
                    ? SizedBox(height: 102)
                    : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Your Placement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                                fontFamily: "Noto Sans Black",
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              playerPosition == null
                                  ? "UNRANKED"
                                  : "#$playerPosition",

                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        _distanceSet = 1;
                        _reloadLeaderboard();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            _distanceSet == 1 ? Colors.red : Colors.white,
                        foregroundColor:
                            _distanceSet == 1 ? Colors.white : Colors.blue,
                      ),
                      child: Text("1 mi", style: TextStyle(fontSize: 25)),
                    ),

                    TextButton(
                      onPressed: () {
                        _distanceSet = 2;
                        _reloadLeaderboard();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            _distanceSet == 2 ? Colors.red : Colors.white,
                        foregroundColor:
                            _distanceSet == 2 ? Colors.white : Colors.blue,
                      ),
                      child: Text("2 mi", style: TextStyle(fontSize: 25)),
                    ),

                    TextButton(
                      onPressed: () {
                        _distanceSet = 5;
                        _reloadLeaderboard();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            _distanceSet == 5 ? Colors.red : Colors.white,
                        foregroundColor:
                            _distanceSet == 5 ? Colors.white : Colors.blue,
                      ),
                      child: Text("5 mi", style: TextStyle(fontSize: 25)),
                    ),

                    TextButton(
                      onPressed: () {
                        _distanceSet = 10;
                        _reloadLeaderboard();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            _distanceSet == 10 ? Colors.red : Colors.white,
                        foregroundColor:
                            _distanceSet == 10 ? Colors.white : Colors.blue,
                      ),
                      child: Text("10 mi", style: TextStyle(fontSize: 25)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedLeaderboard.length ~/ 3,
                    itemBuilder: (context, index) {
                      int base = index * 3;
                      String name = sortedLeaderboard[base];
                      int time = sortedLeaderboard[base + 1];
                      String day = sortedLeaderboard[base + 2];
                      int placement = (index + 1);
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
                              "$placement.",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              "$name | ${(time / 60).toInt().toString()}:${time % 60} | $day",
                            ),
                          ),
                        ),
                      );
                    },
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
