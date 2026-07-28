import 'package:dealer/features/upload/presentation/widgets/upload_media_card.dart';
import 'package:flutter/material.dart';

class VehiclePhotoPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const VehiclePhotoPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Vehicle Photos",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Upload all required vehicle images.",
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        UploadCard(
          title: "Front View",
          subtitle: "Capture front side",
          onTap: () {},
        ),
        UploadCard(
          title: "Rear View",
          subtitle: "Capture rear side",
          onTap: () {},
        ),
        UploadCard(
          title: "Left Side",
          subtitle: "Capture left profile",
          onTap: () {},
        ),
        UploadCard(
          title: "Right Side",
          subtitle: "Capture right profile",
          onTap: () {},
        ),
        UploadCard(
          title: "Dashboard",
          subtitle: "Dashboard image",
          onTap: () {},
        ),
        UploadCard(
          title: "Odometer",
          subtitle: "Mileage reading",
          onTap: () {},
        ),
        UploadCard(
          title: "VIN Number",
          subtitle: "VIN plate",
          onTap: () {},
        ),
        UploadCard(
          title: "Engine Bay",
          subtitle: "Open bonnet",
          onTap: () {},
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text("Back"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text("Next"),
              ),
            )
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
