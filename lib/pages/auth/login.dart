import 'dart:convert';
import 'package:coin_guardian/pages/auth/totp/setup_authenticator.dart';
import 'package:coin_guardian/pages/auth/totp/verif_totp.dart';
import 'package:coin_guardian/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';
import 'package:coin_guardian/components/background_bubbles/secondaryBubble.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/custom-input.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> loginUser() async {
    const String apiUrl = "http://localhost:3000/api/auth/login";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8"
      },
      body: jsonEncode(<String, String>{
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String email = responseData['email'];
      final int userId = responseData['userId'];

      try {
        final FlutterSecureStorage secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'email', value: email);
        await secureStorage.write(key: 'userId', value: userId.toString());
      } catch (e) {
        print('Failed to write to secure storage: $e');
      }

      verifyAuhtyId();
    } else {
      showErrorDialog('Failed to login user. Please try again.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Login failed'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> verifyAuhtyId() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? userId = await secureStorage.read(key: 'userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found in local storage")),
      );
      return;
    }

    String apiUrl = "http://localhost:3000/api/totp/check-authy-token/$userId";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        bool exists = responseData["exists"];
        if (!exists) {
          String email = responseData["email"];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetupAuthenticationPage(email: email),
            ),
          );
        }
      } else if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        bool exists = responseData["exists"];
        if (exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VerifyAuthenticationPage(pageRedirect: HomePage(),),
            ),
          );
        }
      }
    } catch (err) {
      print('Exception during API call: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred")),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _previousStep() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PrimaryBubble(color: AppColors.purple, left: -10, bottom: -100),
          const SecondaryBubble(color: AppColors.purple, left: 330, top: 45),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/main-logo.svg',
                      height: 200.0,
                      width: 200.0,
                    ),
                    const SizedBox(height: 18.0),
                    const Text(
                      "Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 54.0),
                    CustomInput(
                      label: "Email",
                      controller: _emailController,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 6.0),
                    CustomInput(
                      label: "Password",
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 18.0),
                    CustomButton(
                      label: "Sign in",
                      onPressed: loginUser,
                      backgroundColor: AppColors.purple,
                      textColor: AppColors.white,
                    )
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
