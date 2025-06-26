import 'dart:async';
import 'package:cure_app/models/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsBannerWidget extends StatefulWidget {
  final List<AdBanner> ads;
  const AdsBannerWidget({Key? key, required this.ads}) : super(key: key);

  @override
  State<AdsBannerWidget> createState() => _AdsBannerWidgetState();
}

class _AdsBannerWidgetState extends State<AdsBannerWidget> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.ads.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_currentPage < widget.ads.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.ads.length,
        itemBuilder: (context, index) {
          final ad = widget.ads[index];
          return GestureDetector(
            onTap: () => _launchUrl(ad.targetUrl),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.network(
                ad.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
