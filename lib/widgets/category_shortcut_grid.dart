import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cure_app/providers/categories_provider.dart';
import 'package:cure_app/models/category_shortcut.dart';

class CategoryShortcutGrid extends StatelessWidget {
  const CategoryShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoriesProvider>(context);

    if (categoriesProvider.categories.isEmpty) {
      return const SizedBox.shrink(); // إخفاء لو مفيش داتا
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: categoriesProvider.categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final CategoryShortcut item = categoriesProvider.categories[index];

          return GestureDetector(
            onTap: () async {
              if (await canLaunchUrl(Uri.parse(item.targetUrl))) {
                await launchUrl(Uri.parse(item.targetUrl),
                    mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تعذر فتح الرابط")),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(item.iconUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
