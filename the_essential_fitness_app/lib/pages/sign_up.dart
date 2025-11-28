import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../common/global.dart';
import './home.dart';
import './sign_up.dart';
import 'tos.dart';

class signUpPage extends StatefulWidget {
  const signUpPage({super.key});

  @override
  _signUpPageState createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _nametag = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password1 = TextEditingController();

  bool _tos = false;

  @override
  void dispose() {
    _email.dispose();
    _nametag.dispose();
    _password.dispose();
    _password1.dispose();
    super.dispose();
  }

  void setTos() {
    setState(() {
      _tos = !_tos;
    });
  }

  void checkAll() {
    String email = _email.text.trim();
    String nametag = _nametag.text.trim();
    String password = _password.text.trim();
    String password1 = _password1.text.trim();

    if (email == '' || password == '' || password1 == '' || nametag == '') {
      print('Error: One of the fields was not filled in.');
      return;
    }

    if (!_tos) {
      print('Error: You must agree to the TOS.');
      return;
    }

    if (password != password1) {
      _password.clear();
      _password1.clear();
      print('passwords dont match');
      return;
    }

    _signUp(email, nametag, password);
  }

  Future<void> _signUp(String email, String nametag, String password) async {
    try {
      // Create a new user with Firebase Authentication
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the user ID
      User? user = result.user;

      // Optionally, create a matching user document in Firestore
      if (user != null) {
        final today = DateTime.now();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nametag': nametag,
          'height': 0,
          'weight': 0,
          'streak': 0,
          'tasksComplete': false,
          'registered': today,
          'tutorial': false,
          'exercises': [],
          'runs': [],
        });
        print('✅ User created successfully: ${user.uid}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('❌ The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('❌ The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        print('❌ The email address is not valid.');
      } else {
        print('❌ FirebaseAuthException: ${e.message}');
      }
    } catch (e) {
      print('❌ General error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/app_background.jpg', fit: BoxFit.cover),
          ),

          // SafeArea for all content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          _email,
                          'Email',
                          TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _nametag,
                          'nametag',
                          TextInputType.text,
                        ),

                        const SizedBox(height: 16),
                        _buildTextField(
                          _password,
                          'Password',
                          TextInputType.text,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          _password1,
                          'Confirm Password',
                          TextInputType.text,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),

                        // TOS checkbox and text
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: setTos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                              ),
                              child: Icon(
                                _tos
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'By checking this you confirm that you have read and agree to the Terms of Service.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => tosPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Click here to view ToS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                              decorationThickness: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: checkAll,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                //Expanded(
                //Text(_errorMessage, style: TextStyle(color: Colors.red)),
                //),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    bool obscureText = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blueAccent,
          selectionHandleColor: Colors.blue,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
      ),
    );
  }
}
