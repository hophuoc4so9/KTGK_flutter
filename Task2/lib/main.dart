import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotuanphuoc_2224802010872_lab4/controllers/auth_services.dart';
import 'package:hotuanphuoc_2224802010872_lab4/firebase_options.dart';
import 'package:hotuanphuoc_2224802010872_lab4/home.dart';
import 'package:hotuanphuoc_2224802010872_lab4/login_page.dart';
import 'package:hotuanphuoc_2224802010872_lab4/screens/settings_screen.dart';
import 'package:hotuanphuoc_2224802010872_lab4/sign_up_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      theme: ThemeData(
        textTheme: GoogleFonts.soraTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange.shade800,
        ),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const CheckUser(),
        "/login": (context) => const LoginPage(),
        "/signup": (context) => const SignupPage(),
        "/home": (context) => const HomeScreen(),
        
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}
class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthServices().isUserLoggedIn().then((isLoggedIn) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();

    
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}