import 'dart:convert';
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';
import 'package:coin_guardian/components/background_bubbles/secondaryBubble.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/custom-input.dart';
import 'package:coin_guardian/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final PageController _pageController = PageController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  int _currentStep = 0;
  bool _isLoading = false;

  Future<void> registerUser() async {
    const String apiUrl = "http://localhost:3000/api/auth/register";
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstname': _firstnameController.text,
        'lastname': _lastnameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: SpinKitFadingCircle(
              color: Colors.green,
              size: 50.0,
            ),
          );
        },
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else if (response.statusCode == 409) {
      showErrorDialog('This email is already registered. Please use a different email.');
    } else {
      showErrorDialog('Failed to register user. Please try again.');
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
              Text('Registration failed'),
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.ease);
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 100), curve: Curves.ease);
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
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
              child: Column(
                children: [
                  SvgPicture.asset(
                    'lib/assets/images/main-logo.svg',
                    height: 200.0,
                    width: 200.0,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Create Account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 49.0),
                  Form(
                    key: _formKey,
                    child: SizedBox(
                      height: 400.0,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Column(
                            children: [
                              CustomInput(
                                label: 'First Name',
                                controller: _firstnameController,
                                validator: _validateName,
                              ),
                              CustomInput(
                                label: 'Last Name',
                                controller: _lastnameController,
                                validator: _validateName,
                              ),
                              CustomInput(
                                label: 'Email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 20.0),
                              CustomButton(
                                label: "Continue",
                                onPressed: _nextStep,
                                backgroundColor: AppColors.purple,
                                textColor: AppColors.white,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              CustomInput(
                                label: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                                validator: _validatePassword,
                              ),
                              CustomInput(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: true,
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _termsAccepted,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _termsAccepted = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _termsAccepted = !_termsAccepted;
                                        });
                                      },
                                      child: const Text(
                                        'I accept the terms and conditions',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _isLoading
                                  ? const SpinKitFadingCircle(
                                      color: Colors.blue,
                                      size: 50.0,
                                    )
                                  : CustomButton(
                                      label: "Register",
                                      onPressed: () {
                                        if (_formKey.currentState!.validate() && _termsAccepted) {
                                          registerUser();
                                        } else if (!_termsAccepted) {
                                          showErrorDialog('You must accept the terms and conditions to register.');
                                        }
                                      },
                                      backgroundColor: AppColors.purple,
                                      textColor: AppColors.white,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
