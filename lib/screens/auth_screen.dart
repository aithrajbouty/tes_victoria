import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tes_victoria_care/auth.dart';
import 'package:tes_victoria_care/screens/check_in_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLogin = true;
  final _passwordController = TextEditingController();
  late String _email;
  late String _password;
  final User? user = Auth().currentUser;
  String? errorMessage = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      print('DONT PROCEED');
      return;
    }
    _formKey.currentState!.save();

    try {
      _isLogin
          ? await Auth().signInWithEmailAndPassword(
              email: _email,
              password: _password,
            )
          : await Auth().createUserWithEmailAndPassword(
              email: _email, password: _password);
      Navigator.of(context).pushReplacementNamed(CheckInScreen.routeName);
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
      // setState(() {
      errorMessage = e.message;
      // });
      print('INI ERRORNYA: $errorMessage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [titleText(), authForm(), authButton(), changeAuthType()],
        ),
      ),
    );
  }

  Container titleText() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        _isLogin ? 'Login' : 'Register',
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
    );
  }

  Form authForm() {
    return Form(
      key: _formKey,
      child: Container(
        height: _isLogin ? 180 : 250,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 10,
        ),
        color: const Color.fromRGBO(240, 239, 235, 1),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please input email';
                  }
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              if (!_isLogin)
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: !_isLogin
                      ? (value) {
                          if (value!.isEmpty ||
                              value != _passwordController.text) {
                            return ('Passwords do not match!');
                          }
                        }
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton authButton() {
    return ElevatedButton(
      onPressed: _submit,
      child: Text(
        _isLogin ? 'Login' : 'Register',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Row changeAuthType() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'No account yet?' : 'Already has an account?',
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
            });
          },
          child: Text(
            _isLogin ? 'Register Here' : 'Login Here',
          ),
        ),
      ],
    );
  }
}
