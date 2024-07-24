import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';
import 'package:coin_guardian/components/background_bubbles/secondaryBubble.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/custom-input.dart';
import 'package:coin_guardian/pages/auth/auth_selection.dart';

class VerifyAuthenticationPage extends StatefulWidget {
  final Widget pageRedirect;

  const VerifyAuthenticationPage({Key? key, required this.pageRedirect}) : super(key: key);

  @override
  _VerifyAuthenticationPageState createState() => _VerifyAuthenticationPageState();
}

class _VerifyAuthenticationPageState extends State<VerifyAuthenticationPage> {
  final TextEditingController _tokenController = TextEditingController();

  Future<void> _verifyTOTP() async {
      final FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final email = await secureStorage.read(key: "email");

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/totp/verify-totp'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email.toString(),
        'token': _tokenController.text
      }),
    );

    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = json.decode(response.body);
      await secureStorage.write(key: 'jwt', value: responseData['jwtToken']);
      await Future.delayed(const Duration(seconds: 1));
      handleRedirect(widget.pageRedirect);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify TOTP'),
        ),
      );
    }
  }

  void handleRedirect(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuthSelectionPage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackground,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const PrimaryBubble(color: AppColors.white, left: -10, bottom: -50),
            const SecondaryBubble(color: AppColors.white, left: 330, top: 45),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100,),
                      SvgPicture.asset(
                        'lib/assets/images/secondary_logo.svg',
                        height: 200.0,
                        width: 200.0,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Enter the TOTP code from your Google Authenticator app:',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 54),
                      CustomInput(label: "TOTP Code", controller: _tokenController),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: "Verify",
                        onPressed: _verifyTOTP,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
