import 'dart:convert';

import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/custom-input.dart';
import 'package:coin_guardian/pages/auth/login.dart';
import 'package:coin_guardian/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';
import 'package:coin_guardian/components/background_bubbles/secondaryBubble.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class BinanceKeyInputPage extends StatelessWidget {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _publicKeyController = TextEditingController();
  final TextEditingController _privateKeyController = TextEditingController();

  Future<void> verifiBinanceKey(BuildContext context) async {
    String? token = await secureStorage.read(key: "jwt");

    if(token == null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }

    String apiUrl = "http://localhost:3000/api/binanceApi/validate-binance-key";

    try {
      final response = await http.post( Uri.parse(apiUrl), 
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          "publicKey": _publicKeyController.text,
          "privateKey": _privateKeyController.text
        })
      );

      if(response.statusCode == 200){
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if(responseData["success"]){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }

      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackground,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const PrimaryBubble(color: AppColors.white, left: -10, bottom: -100),
            const SecondaryBubble(color: AppColors.white, left: 330, top: 45),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      'lib/assets/images/secondary_logo.svg',
                      height: 200.0,
                      width: 200.0,
                    ),
                    const SizedBox(height: 18.0),
                  const Text(
                    'Enter your Binance API keys',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  CustomInput(
                    label: "Public key",
                    controller: _publicKeyController,
                    icon: Icons.vpn_key,
                  ),
                  const SizedBox(height: 8.0),
                  CustomInput(
                    label: "Private key",
                    controller: _privateKeyController,
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  CustomButton(
                    label: "Validate",
                    onPressed: () => { verifiBinanceKey(context) }, 
                    backgroundColor: AppColors.white, 
                    textColor: AppColors.purple
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('See How'),
                            content: const Text('To obtain your Binance API keys, go to your Binance account settings and navigate to API Management.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('See How', style: TextStyle(color: AppColors.white)),
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
