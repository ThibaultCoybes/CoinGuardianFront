import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/pages/auth/login.dart';
import 'package:coin_guardian/pages/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/background_bubbles/primaryBubble.dart';

class AuthSelectionPage extends StatelessWidget {
  const AuthSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const PrimaryBubble(color: AppColors.purple, left: -10, bottom: -100),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'lib/assets/images/home-background.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 70),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CoinGuardian: Store, Convert, Transfer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Securely manage your cryptos. Easy storage, conversion, and transfers. Join us now!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Builder(
                  builder: (BuildContext context) {
                    return CustomButton(
                      label: "Create an account",
                      onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()), 
                        );
                      },
                      backgroundColor: AppColors.purple,
                      textColor: AppColors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Builder(
                  builder: (BuildContext context) {
                    return CustomButton(
                      label: "Sign in",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()), 
                        );
                      },
                      backgroundColor: AppColors.lightGrey,
                      textColor: AppColors.darkGrey,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

