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

class runningPage extends StatefulWidget {
  const runningPage({super.key});

  @override
  State<runningPage> createState() => _RunningPageState();
}

class _RunningPageState extends State<runningPage> {
  late StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  bool runStarted = false;
  double _curSpeed = 0;
  double _totalDist = 0;
  //Duration _pace = Duration(minutes: 0, seconds: 0);
  Duration _timeElapsed = Duration(minutes: 0, seconds: 0);
  IconData _icon = FontAwesomeIcons.person;

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> startRun() async {
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
    runStarted = true;
    startTimer();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position pos) {
      setState(() {
        _totalDist += 1;
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
        }
      });
    });
  }

  Future<void> _updateRuns() async {
    if (user != null) {
      List<double?> runs;
      final uid = user!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = doc.data();
      runs = userData?['runs'];
      runs.add(_totalDist);
      runs.add(_timeElapsed as double?);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'runs': runs,
      });
    }
  }

  void stopRun() async {
    //call to firebase and update runs
    await _updateRuns();

    _positionStream?.cancel();
    _positionStream = null;

    // Stop the periodic timer
    _timer?.cancel();
    _timer = null;

    setState(() {
      runStarted = false;
      _timeElapsed = Duration(minutes: 0, seconds: 0);
      _totalDist = 0;
      _curSpeed = 0;
      _icon = FontAwesomeIcons.person;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
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
                Icon(
                  _icon,
                  color: Colors.white, // White icon
                  size: 60,
                ),
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
                  onTap: runStarted == true ? stopRun : startRun,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: Colors.white, // Blue background
                    child: SizedBox(
                      width: 120,
                      height: 60,
                      child: Center(
                        child: Text(
                          runStarted == false ? 'Start Run' : 'Stop Run',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
