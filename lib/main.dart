import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_house/views/resetpassword/reset_email_screen.dart';
import 'providers/user_provider.dart';
import 'providers/home_provider.dart';
import 'views/splash/splash_screen.dart';
import 'views/registration/email_input_screen.dart';
import 'views/registration/registration_screen.dart';
import 'views/login/login_screen.dart';
import 'views/home/home_list_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tuya Smart Home',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/emailInput': (context) => EmailInputScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeListView(),
        '/resetPassword': (context) => ResetEmailScreen(),
      },
    );
  }
}
