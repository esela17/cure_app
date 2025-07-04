import 'package:flutter/material.dart';
import 'package:cure_app/utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            kPrimaryColor), // Use your primary color
      ),
    );
  }
}
