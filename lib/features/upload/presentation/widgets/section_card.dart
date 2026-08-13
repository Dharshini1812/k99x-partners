import 'package:dealer/features/upload/presentation/widgets/upload_colors.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  Widget? apply;
  bool? isReg = false;
  void Function()? onTap;

  SectionCard(
      {super.key,
      required this.title,
      required this.children,
      this.apply,
      this.isReg,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UploadColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UploadColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReg == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: UploadText.sectionTitle),
                SizedBox(
                  height: 25,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                    onPressed: onTap,
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          else
            Text(title, style: UploadText.sectionTitle),
          const SizedBox(height: 10),
          const Divider(height: 1, color: UploadColors.border),
          const SizedBox(height: 14),
          ...children.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: UploadSpacing.sm),
              child: c,
            ),
          ),
        ],
      ),
    );
  }
}
