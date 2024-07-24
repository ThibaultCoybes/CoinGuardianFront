import 'dart:convert';
import 'package:coin_guardian/components/dialog/account.dialog.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/navigation-bar.dart';
import 'package:coin_guardian/components/profile-tab.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  Future<Map<String, dynamic>>? userData;

  @override
  void initState() {
    super.initState();
    userData = fetchUserData(context);
  }

  Future<Map<String, dynamic>> fetchUserData(BuildContext context) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await secureStorage.read(key: "jwt");

    final response = await http.get(
      Uri.parse('http://localhost:3000/api/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      Navigator.pushReplacementNamed(context, '/totp-verification');
      return {};
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void tabFunction(String name) {
    if (name == "account" && userData != null) {
      userData!.then((data) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AccountDialogWidget(
              email: data['email'],
              firstname: data['firstname'],
              lastname: data['lastname'],
              publicKey: data['api_key'],
              secretKey: data['secret_key'],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double phoneHeight = MediaQuery.of(context).size.height * 0.08;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 30, right: 30, top: phoneHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/images/crypto_icons/btc.png",
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                          "${data['lastname'].toString().toUpperCase()} ${data['firstname'].toString()}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                        Text(
                          "${data['email']}",
                          style: const TextStyle(fontSize: 16, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        ProfileTab(
                          title: "Account",
                          icon: const Icon(Icons.person, color: AppColors.blue),
                          onTap: () => tabFunction("account"),
                        ),
                        ProfileTab(
                          title: "Notifications",
                          icon: const Icon(Icons.notifications, color: AppColors.blue),
                          onTap: () => tabFunction("notif"),
                        ),
                        ProfileTab(
                          title: "Security",
                          icon: const Icon(Icons.security, color: AppColors.blue),
                          onTap: () => tabFunction("security"),
                        ),
                        ProfileTab(
                          title: "Help & Support",
                          icon: const Icon(Icons.help_center, color: AppColors.blue),
                          onTap: () => tabFunction("support"),
                        ),
                        ProfileTab(
                          title: "Terms & Conditions",
                          icon: const Icon(Icons.file_copy, color: AppColors.blue),
                          onTap: () => tabFunction("terms"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        context: context,
      ),
    );
  }
}
