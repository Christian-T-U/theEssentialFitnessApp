import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'sign_in.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bfController = TextEditingController();
  int? _weight;
  int? _bf;

  void loadControllers() {
    if (weightbf != null && weightbf!.length >= 3) {
      _weight = weightbf![weightbf!.length - 2];
      _bf = weightbf![weightbf!.length - 1];
    }

    if (nametag != null) {
      _nameController.text = nametag!;
    }
    if (height != null) {
      _heightController.text = height!.toString();
    }
    if (_weight != null) {
      _weightController.text = _weight!.toString();
    }
    if (_bf != null) {
      _bfController.text = _bf!.toString();
    }
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _saveChanges() async {
    int? numOne = int.tryParse(_heightController.text);
    int? numTwo = int.tryParse(_weightController.text);
    int? numThree = int.tryParse(_bfController.text);

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new valid nametag to save changes.'),
        ),
      );
      return;
    } else if (numOne == null || numOne <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new valid height to save changes.'),
        ),
      );
      return;
    } else if (numTwo == null || numTwo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new valid weight to save changes.'),
        ),
      );
      return;
    } else if (numThree == null || numThree <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new valid bodyfat % to save changes.'),
        ),
      );
      return;
    }

    setState(() {
      nametag = _nameController.text;
      height = int.tryParse(_heightController.text);
      _weight = int.tryParse(_weightController.text);
      _bf = int.tryParse(_bfController.text);
    });

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'nametag': nametag!,
      'height': height!,
    });

    DateTime today = DateTime.now();

    if (weightbf != null && weightbf!.length >= 3) {
      int idx = weightbf!.length;
      Timestamp lastTimestamp = weightbf![idx - 3];
      DateTime lastDay = lastTimestamp.toDate();
      if (sameDay(lastDay, today)) {
        weightbf![idx - 2] = numTwo;
        weightbf![idx - 1] = numThree;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({"weightbf": weightbf});
        return;
      }
    }
    weightbf ??= [];
    weightbf!.add(Timestamp.fromDate(today));
    weightbf!.add(numTwo);
    weightbf!.add(numThree);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'weightbf': weightbf,
    });
  }

  Future<void> _deleteAccount() async {
    try {
      await user!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
        (route) => false,
      );
    } catch (e) {
      print("error: $e");
    }
    try {
      await FirebaseFirestore.instance
          .collection('your_collection_name')
          .doc(user!.uid)
          .delete();
      print("Document deleted successfully!");
    } catch (e) {
      print("error: $e");
    }
  }

  @override
  void initState() {
    loadControllers();
    super.initState();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor: Colors.blue,
                              selectionColor: Colors.blueAccent,
                              selectionHandleColor: Colors.blue,
                            ),
                          ),
                          child: TextField(
                            controller: _nameController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]'),
                              ),
                            ],
                            obscureText: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Nametag",
                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor: Colors.blue,
                              selectionColor: Colors.blueAccent,
                              selectionHandleColor: Colors.blue,
                            ),
                          ),
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Height (in)",
                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor: Colors.blue,
                              selectionColor: Colors.blueAccent,
                              selectionHandleColor: Colors.blue,
                            ),
                          ),
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Weight (lbs)',

                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor: Colors.blue,
                              selectionColor: Colors.blueAccent,
                              selectionHandleColor: Colors.blue,
                            ),
                          ),
                          child: TextField(
                            controller: _bfController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: false,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Bodyfat %',

                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Card(
                          color: Colors.white,
                          child: TextButton(
                            onPressed: _saveChanges,
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.red,
                          child: TextButton(
                            onPressed: _deleteAccount,
                            child: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
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
