import 'package:coin_guardian/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';
import 'package:coin_guardian/components/background_bubbles/secondaryBubble.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/pages/auth/totp/verif_totp.dart';
import 'package:coin_guardian/assets/colors.dart';

class SetupAuthenticationPage extends StatefulWidget {
  final String email;

  const SetupAuthenticationPage({Key? key, required this.email}) : super(key: key);

  @override
  _SetupAuthenticationPageState createState() => _SetupAuthenticationPageState();
}

class _SetupAuthenticationPageState extends State<SetupAuthenticationPage> {
  String? secret;
  String? otpauthUrl;
  bool isLoading = true; 
  
  @override
  void initState() {
    super.initState();
    _setupGoogleAuthenticator();
  }

  Future<void> _setupGoogleAuthenticator() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/totp/setup-google-authenticator'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final responseData = jsonDecode(response.body);
          secret = responseData['secret'];
          otpauthUrl = responseData['otpauth_url']; 
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (secret != null) {
      Clipboard.setData(ClipboardData(text: secret!)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Secret key copied to clipboard')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const PrimaryBubble(color: AppColors.white, left: -10, bottom: -100),
            const SecondaryBubble(color: AppColors.white, left: 330, top: 45),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : otpauthUrl == null || otpauthUrl!.isEmpty
                    ? const Center(
                        child: Text(
                          'Failed to generate QR code',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 150),
                            const Text(
                              'Scan this QR code with your Google Authenticator app:',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Image.network(
                                    'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$otpauthUrl',
                                    height: 200.0,
                                    width: 200.0,
                                  ),
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'Or use this secret key:',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: secret != null
                                        ? '*' * (secret!.length - 4) +
                                            secret!.substring(secret!.length - 4)
                                        : '',
                                    readOnly: true,
                                    obscureText: true,
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white24,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.white),
                                  onPressed: _copyToClipboard,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                              label: "Done",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifyAuthenticationPage(pageRedirect: HomePage(),),
                                  ),
                                );
                              },
                              backgroundColor: AppColors.white,
                              textColor: AppColors.purple,
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
