import 'package:flutter/material.dart';
import '../core/platform_channel/tuya_channel.dart';

class ResetPasswordVM {
  final BuildContext context;

  ResetPasswordVM(this.context);

  /// Step 1: Send verification code
  Future<bool> sendEmailCode(String email) async {
    try {
      await TuyaChannel.sendEmailCode(email, type: 3); // 3 = reset password
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Verification code sent!")));
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending code: $e")));
      return false;
    }
  }

  /// Step 2: Reset password using email, code and new password
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Code and password are required!")),
      );
      return;
    }

    try {
      await TuyaChannel.resetPassword(email, code, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully!")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password reset failed: $e")));
    }
  }
}
