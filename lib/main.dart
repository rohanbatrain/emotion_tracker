import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup/backend_url_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart' as login;
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/logout_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget _initialScreen = SplashScreen(); // Use the splash screen as the initial screen

  @override
  void initState() {
    super.initState();
    _checkIfBackendUrlSaved();
  }

  Future<void> _checkIfBackendUrlSaved() async {
    // Simulate a splash screen delay by waiting for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url');
    final authToken = prefs.getString('auth_token');
    if (!mounted) return;

    setState(() {
      if (backendUrl == null || backendUrl.isEmpty) {
        _initialScreen = BackendUrlScreen();
      } else if (authToken != null && authToken.isNotEmpty) {
        _initialScreen = HomeScreen();
      } else {
        _initialScreen = RegisterScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Brain Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _initialScreen,
        '/login': (context) => login.LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/backend_url': (context) => BackendUrlScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/logout': (context) => LogoutScreen(),
      },
    );
  }
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the logo with proper aspect ratio
            Image.asset(
              'assets/splash.png', // Replace with your logo image
              width: 250, // Adjust width to keep aspect ratio intact
              height: 187.5, // Adjust height based on aspect ratio (250 * 3/4 = 187.5)
            ),
            SizedBox(height: 30), // Space between logo and text
            // Title of the application
            Text(
              'Emotion Tracker',
              style: TextStyle(
                fontSize: 32, // Larger font for a more professional feel
                fontWeight: FontWeight.w600, // Use a lighter weight for modern style
                color: Colors.blue, // You can change the color to match your branding
                letterSpacing: 1.5, // Add spacing for a cleaner look
                fontFamily: 'Roboto', // Consider using a modern, clean font
              ),
            ),
            SizedBox(height: 20), // Additional spacing for balance
            // A loading indicator for a smooth transition
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
