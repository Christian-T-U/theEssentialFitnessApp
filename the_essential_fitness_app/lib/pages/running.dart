import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../common/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'home.dart';
import 'package:fl_chart/fl_chart.dart';

class runningPage extends StatefulWidget {
  const runningPage({super.key});

  @override
  State<runningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<runningPage> {
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  bool _runStarted = false;
  double _curSpeed = 0;
  double _totalDist = 0;
  Duration _timeElapsed = Duration(minutes: 0, seconds: 0);
  IconData _icon = FontAwesomeIcons.person;
  double? _distanceSet;
  List<double> distances = [];
  List<double> _barChartX = [];
  List<Timestamp> _barChartY = [];
  bool toggle = false;
  double _max = 0;

  @override
  void initState() {
    _getBarChart();
    super.initState();
  }

  void _getBarChart() {
    if (runs != null && runs!.length > 2) {
      for (int i = 1; i < runs!.length; i += 3) {
        _barChartY.add(runs![i - 1]);
        _barChartX.add(runs![i]);
        if (runs![i] > _max) {
          _max = runs![i];
        }
      }
    }
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _updateRuns() async {
    DateTime today = DateTime.now();

    if (runs != null && runs!.length >= 3) {
      int idx = runs!.length;
      Timestamp lastTimestamp = runs![idx - 3];
      DateTime lastRunDay = lastTimestamp.toDate();
      double lastDist = runs![idx - 2];
      int lastTime = runs![idx - 1];
      if (sameDay(lastRunDay, today)) {
        runs![idx - 2] = lastDist + _totalDist;
        runs![idx - 1] = lastTime + _timeElapsed.inSeconds;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"runs": runs});

        return;
      }
    }
    runs ??= [];
    runs!.add(Timestamp.fromDate(today));
    runs!.add(_totalDist);
    runs!.add(_timeElapsed.inSeconds);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'runs': runs,
    });
  }

  //update in this order... date, time
  /*Future<void> _updateBestRuns() async {
    //executes when dis traveled reaches dist set
    List<dynamic> run = [DateTime.now(), _timeElapsed.inSeconds];
    if (_distanceSet == 1) {
      if (bestRun1mi != null && run[1] < bestRun1mi![1]) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun1mi": run});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun1mi": run});
      }
    } else if (_distanceSet == 2) {
      if (bestRun2mi != null && run[1] < bestRun2mi![1]) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun2mi": run});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun2mi": run});
      }
    } else if (_distanceSet == 5) {
      if (bestRun5mi != null && run[1] < bestRun5mi![1]) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun5mi": run});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun5mi": run});
      }
    } else if (_distanceSet == 10) {
      if (bestRun10mi != null && run[1] < bestRun10mi![1]) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun10mi": run});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"bestRun10mi": run});
      }
    }
  }*/

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "Time Elapsed: $hours:$minutes:$seconds";
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _timeElapsed += Duration(seconds: 1);
      });
    });
  }

  void _cancelAndExit() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    if (_positionStream != null) {
      _positionStream!.cancel();
      _positionStream = null;
    }
    Navigator.pop(context);
  }

  Future<void> endRun() async {
    await _updateRuns();
    await _positionStream?.cancel();
    _positionStream = null;
    _timer?.cancel();
    _timer = null;

    setState(() {
      _runStarted = false;
      _timeElapsed = Duration(minutes: 0, seconds: 0);
      _totalDist = 0.0;
    });
  }

  Future<void> startRun() async {
    if (_distanceSet == null) {
      return;
    }

    bool service = await Geolocator.isLocationServiceEnabled();
    if (!service) {
      print('service disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('permission denied forever');
      return;
    }

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );
    setState(() {
      _runStarted = true;
    });
    startTimer();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position pos) {
      _totalDist += 1.0;
      _curSpeed = pos.speed * 2.23694;
      if (0 == _curSpeed) {
        _icon = FontAwesomeIcons.person;
      } else if (0 < _curSpeed && _curSpeed <= 3) {
        _icon = FontAwesomeIcons.personWalking;
      } else if (3 < _curSpeed && _curSpeed <= 7) {
        _icon = Icons.directions_run;
      } else if (7 < _curSpeed && _curSpeed <= 15) {
        _icon = FontAwesomeIcons.personRunning;
      } else {
        _icon = FontAwesomeIcons.car;
        endRun();
      }
    });
    if (_totalDist == _distanceSet) {
      //_updateBestRuns();
      endRun();
    }
    setState(() {
      _icon;
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
          GestureDetector(
            onTap: _cancelAndExit,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white, // Blue background
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: Icon(
                    Icons.home,
                    color: Colors.blue, // White icon
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "-Run Divisions-",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          _distanceSet = 1;
                        });
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
                      onPressed: () async {
                        setState(() {
                          _distanceSet = 2;
                        });
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
                      onPressed: () async {
                        setState(() {
                          _distanceSet = 5;
                        });
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
                      onPressed: () async {
                        setState(() {
                          _distanceSet = 10;
                        });
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
                Icon(_icon, color: Colors.white, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Speed: ${(_curSpeed).toStringAsFixed(2)} mph',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'distance = ${(_totalDist * 0.00062137).toStringAsFixed(2)} mi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  formatDuration(_timeElapsed),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _runStarted == true ? endRun : startRun,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: _runStarted == false ? Colors.white : Colors.red,
                    child: SizedBox(
                      width: 120,
                      height: 60,
                      child: Center(
                        child: Text(
                          _runStarted == false ? 'Start Run' : 'Stop Run',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _runStarted == false
                                    ? Colors.blue
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //impliment textbutton ------------------------------------
                const SizedBox(height: 16),
                Text(
                  "-Run History (meters)-",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: _max,
                      barGroups: List.generate(_barChartX.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: _barChartX[index],
                              width: 18,
                              color:
                                  Colors
                                      .white, //impliment color function -----------
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }),

                      barTouchData: BarTouchData(
                        enabled: true, // enable touch
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor:
                              Colors.white, // background color of tooltip
                          tooltipPadding: EdgeInsets.all(8),
                          tooltipMargin: 4,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = _barChartY[groupIndex];
                            final dist = _barChartX[groupIndex];
                            return BarTooltipItem(
                              '${date.toDate().month}/${date.toDate().day}/${date.toDate().year}\nDist: $dist',
                              TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ),

                      titlesData: FlTitlesData(
                        show: true,

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),

                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
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
