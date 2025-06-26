import 'package:cure_app/models/category_shortcut.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryShortcutsWidget extends StatelessWidget {
  final List<CategoryShortcut> categories;
  const CategoryShortcutsWidget({Key? key, required this.categories})
      : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => _launchUrl(category.targetUrl),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(category.iconUrl),
                ),
                const SizedBox(height: 8),
                Text(
                  category.label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
