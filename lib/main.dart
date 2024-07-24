import 'package:coin_guardian/pages/auth/auth_selection.dart';
import 'package:coin_guardian/pages/auth/login.dart';
import 'package:coin_guardian/pages/auth/register.dart';
import 'package:coin_guardian/pages/auth/totp/verif_totp.dart';
import 'package:coin_guardian/pages/graphic.dart';
import 'package:coin_guardian/pages/history.dart';
import 'package:coin_guardian/pages/home.dart';
import 'package:coin_guardian/pages/profile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Poppins"),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthSelectionPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/graphic': (context) => GraphicPage(),
        '/history': (context) => HistoryPage(),
        '/settings': (context) => ProfilePage(),
        '/totp-verification': (context) => const VerifyAuthenticationPage(pageRedirect: HomePage(),)
      },
    );
  }
}
