import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({Key? key, required this.child}) : super(key: key);

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _checkConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      // في حالة الخطأ، افترض أن الاتصال متوفر
      setState(() {
        _isConnected = true;
      });
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected = results.any((result) => result != ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          widget.child,
          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red,
                child: SafeArea(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'لا يوجد اتصال بالإنترنت',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// الاستخدام في main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيقي',
      home: OfflineBanner(
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة الرئيسية'),
      ),
      body: const Center(
        child: Text('محتوى التطبيق'),
      ),
    );
  }
}
