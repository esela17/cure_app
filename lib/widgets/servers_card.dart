import 'package:flutter/material.dart';
import 'package:cure_app/models/service.dart';
import 'package:cure_app/utils/constants.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final ValueChanged<bool?>
      onCheckboxChanged; // Callback function for checkbox changes

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        // Makes the entire card tappable
        onTap: () {
          // Optional: Navigate to a service details screen when the card is tapped
          // Navigator.pushNamed(context, serviceDetailsRoute, arguments: service.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Service Image (on the right in RTL layouts)
              ClipRRect(
                // Clips the image to have rounded corners
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  service.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover, // Ensures the image covers the box
                  errorBuilder: (context, error, stackTrace) => Container(
                    // Placeholder if image fails to load
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image,
                        color: Colors.grey, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Space between image and text

              // Service Name and Price (takes up the available space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      maxLines: 1, // Limit to one line
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if text overflows
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '${service.price.toStringAsFixed(2)} جنيه مصري', // Format price
                      style: const TextStyle(
                        fontSize: 16,
                        color: kAccentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkbox (on the left in RTL layouts)
              Checkbox(
                value: isSelected,
                onChanged: onCheckboxChanged, // Callback when checked/unchecked
                activeColor: kPrimaryColor, // Color when checkbox is selected
              ),
            ],
          ),
        ),
      ),
    );
  }
}
