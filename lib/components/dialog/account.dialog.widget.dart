import 'dart:convert';

import 'package:coin_guardian/pages/auth/totp/verif_totp.dart';
import 'package:coin_guardian/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/custom-input.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class AccountDialogWidget extends StatelessWidget {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _publicKeyController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  final String email;
  final String firstname;
  final String lastname;
  final String publicKey;
  final String secretKey;

  AccountDialogWidget({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.publicKey,
    required this.secretKey,
    Key? key,
  }) : super(key: key) {
    _firstnameController.text = firstname;
    _lastnameController.text = lastname;
    _emailController.text = email;
    _publicKeyController.text = publicKey;
    _secretKeyController.text = secretKey;
  }

  Future<void> _updateUser(BuildContext context) async {
  try {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await secureStorage.read(key: "jwt");
    String? userId = await secureStorage.read(key: 'userId');

    final response = await http.put(
      Uri.parse("http://localhost:3000/api/user/update/$userId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "firstname": _firstnameController.text,
        "lastname": _lastnameController.text,
        "email": _emailController.text,
        "publicKey": _publicKeyController.text,
        "secretKey": _secretKeyController.text
      })
    );

    if (response.statusCode == 401) {
      Navigator.pushReplacementNamed(context, '/totp-verification');
    } else {
      // Close any open dialog or pop the current screen
      Navigator.of(context).pop();
      
      // Reload the current page
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ProfilePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update user: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(
                  "lib/assets/images/crypto_icons/btc.png",
                  height: 70,
                  width: 70,
                ),
              ),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomInput(
                      label: "First Name",
                      controller: _firstnameController,
                    ),
                    CustomInput(
                      label: "Last Name",
                      controller: _lastnameController,
                    ),
                    CustomInput(
                      label: "Email",
                      controller: _emailController,
                    ),
                    CustomInput(
                      label: "Public Binance Key",
                      controller: _publicKeyController,
                    ),
                    CustomInput(
                      label: "Secret Binance Key",
                      controller: _secretKeyController,
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: CustomButton(
                        label: "Modify",
                        onPressed: () => _updateUser(context),
                        backgroundColor: AppColors.purple,
                        textColor: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: CustomButton(
                        label: "Cancel",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        backgroundColor: AppColors.lightGrey,
                        textColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
