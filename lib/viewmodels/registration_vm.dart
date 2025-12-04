import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/platform_channel/tuya_channel.dart';
import '../providers/user_provider.dart';

class RegistrationVM {
  final BuildContext context;

  RegistrationVM(this.context);

  Future<void> sendCode() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // Run network test first
      final netResult = await TuyaChannel.testNetwork();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Net Check: $netResult"),
          duration: Duration(seconds: 2),
        ),
      );

      await TuyaChannel.sendEmailCode(userProvider.email);
      // Navigate to registration screen
      Navigator.pushNamed(context, '/registration');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending code: $e")));
    }
  }

  Future<void> register() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await TuyaChannel.registerAccount(
        userProvider.email,
        userProvider.verificationCode,
        userProvider.password,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration Successful")));
      // Optionally navigate to login/home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration Failed: $e")));
    }
  }

  Future<bool> login() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await TuyaChannel.login(userProvider.email, userProvider.password);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful")));
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
      return false;
    }
  }
}
