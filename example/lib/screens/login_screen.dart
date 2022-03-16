/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:audio_call/screens/main_screen.dart';
import 'package:audio_call/services/auth_service.dart';
import 'package:audio_call/theme/voximplant_theme.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _authService.getUsername().then((value) {
      _loginController.text = value;
    });
    _loginWithToken();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithToken() async {
    print('LoginScreen: login with accessToken');
    try {
      String displayName = await _authService.loginWithAccessToken();
      print('LoginScreen: login with accessToken: displayName: $displayName');
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    } catch (e) {
      _showAlertDialog(e.message);
    }
  }

  Future<void> _loginWithPassword(String user, String password) async {
    print('LoginScreen: login with password: username: $user');
    try {
      String displayName = await _authService.loginWithPassword(
          user + '.voximplant.com', password);
      print('LoginScreen: login with password: displayName: $displayName');
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    } catch (e) {
      _showAlertDialog(e.message);
    }
  }

  void _showAlertDialog(String reason) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login error'),
            content: Text(reason),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voximplant'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Audio call demo',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: TextFormField(
                      decoration: InputDecoration(
                        suffixText: '.voximplant.com',
                        labelText: 'USER LOGIN',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      controller: _loginController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                      ),
                      autocorrect: false,
                      controller: _passwordController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextButton(
                      onPressed: () {
                        _loginWithPassword(
                            _loginController.text, _passwordController.text);
                      },
                      child: Text(
                        'LOG IN',
                        style: TextStyle(
                            fontSize: 20, color: VoximplantColors.button),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
