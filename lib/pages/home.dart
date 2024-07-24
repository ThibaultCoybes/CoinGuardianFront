import 'dart:convert';
import 'package:coin_guardian/assets/colors.dart';
import 'package:coin_guardian/components/custom-button.dart';
import 'package:coin_guardian/components/navigation-bar.dart';
import 'package:coin_guardian/pages/auth/binance_api_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<dynamic> coins = [];
  bool isLoading = true;
  bool isApiKeyVerified = false;
  int _selectedIndex = 0;
  double totalUSD = 0.0;

  @override
  void initState() {
    super.initState();
    verifyApiKeyOnLoad();
  }

  Future<void> verifyApiKeyOnLoad() async {
    String? userId = await secureStorage.read(key: 'userId');
    String? token = await secureStorage.read(key: 'jwt');

    if (userId == null || token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID or JWT Token not found in local storage")),
      );
      return;
    }

    String apiUrl = "http://localhost:3000/api/binanceApi/check-api-key/$userId";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print({response.body});
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        bool exists = responseData["exists"];
        
        if (!exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BinanceKeyInputPage(),
            ),
          );
        } else {
          setState(() {
            isApiKeyVerified = true;
          });
          fetchUserBinanceData();
        }
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/totp-verification');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BinanceKeyInputPage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserBinanceData() async {
    if (!isApiKeyVerified) return;

    String? token = await secureStorage.read(key: "jwt");

    if (token == null) {
      return;
    }

    String apiUrl = "http://localhost:3000/api/binanceApi/fetch-binance-data";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        setState(() {
          coins = (decodedData['balances'] as List).map((coin) {
            double free = coin['free'] is String ? double.tryParse(coin['free']) ?? 0 : coin['free'];
            String asset = coin['asset'] as String;
            double cryptoValue = coin['valueInUSD'];

            return {
              'free': free,
              'asset': asset,
              'cryptoValue': cryptoValue,
            };
          }).toList();

          totalUSD = decodedData['totalUSD']; 
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, '/totp-verification');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch Binance data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Widget> verifyImageSrc(String assetName) async {
    try {
      await rootBundle.load("lib/assets/images/crypto_icons/${assetName}.png");
      return Image.asset("lib/assets/images/crypto_icons/${assetName}.png", width: 25, height: 25,);
    } catch (e) {
      return Icon(Icons.image);
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(flex : 3,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 70, left: 30, right: 30),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.purple, 
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Wallet",
                  style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Balance in USD: ", 
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w400, fontSize: 14),
                ),
                Text("${totalUSD.toStringAsFixed(2)}\$", style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 20),)
              ],
            ),
          ),),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "Deposit",
                      onPressed: () {
                      },
                      backgroundColor: AppColors.purple,
                      textColor: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: "Withdraw",
                      onPressed: () {
                      },
                      backgroundColor: AppColors.white,
                      textColor: AppColors.purple,
                      hasBorder: true,
                      borderColor: AppColors.purple,
                      borderWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 21,),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Row(
              children: [
                Text("Your Coins", style:
                  TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.darkGrey
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var coin in coins)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 4), 
                        ),
                      ],
                    ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                          children: [
                            FutureBuilder<Widget>(
                              future: verifyImageSrc(coin['asset'].toString().toLowerCase()),
                              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                                return Row(
                                  children: [
                                    snapshot.data ?? const SizedBox(), 
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.04,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          coin['asset'],
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          coin['free'].toString(),
                                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                          Text(
                            "${coin['cryptoValue'].toStringAsFixed(4)} \$",
                            style: const TextStyle(fontSize: 16, color: AppColors.darkGrey),
                          ),
                        ],
                      ),
                    ),
                ]
              ),
            )
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, context: context,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
