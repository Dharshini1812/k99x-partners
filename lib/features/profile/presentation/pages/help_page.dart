import 'package:dealer/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const String _address =
      '129/97 Alsa Claremont, St. Marys Road, Alwarpet, Chennai-600018';
  static const String _phone = '+919962334455';
  static const String _displayPhone = '+91 996 233 4455';
  static const String _email = 'support@k99x.com';

  Future<void> _launchUrl(BuildContext context, Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not open the requested application.')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to perform this action.')),
        );
      }
    }
  }

  void _callPhone(BuildContext context) {
    _launchUrl(context, Uri(scheme: 'tel', path: _phone));
  }

  void _sendEmail(BuildContext context) {
    _launchUrl(context, Uri(scheme: 'mailto', path: _email));
  }

  void _openMap(BuildContext context) {
    final query = Uri.encodeComponent(_address);
    _launchUrl(
      context,
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: const Color(0xFFF7F8FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.headset_mic_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "We're here to help!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Have an issue with a vehicle, auction, or document verification? Get in touch with our operations team.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'CONTACT CHANNELS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF9AA0A6),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.phone_rounded,
              iconColor: const Color(0xFF27AE60),
              title: 'Customer Helpline',
              subtitle: _displayPhone,
              actionLabel: 'Call Now',
              onTap: () => _callPhone(context),
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.email_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'Email Support',
              subtitle: _email,
              actionLabel: 'Write Email',
              onTap: () => _sendEmail(context),
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFE74C3C),
              title: 'Head Office',
              subtitle: _address,
              actionLabel: 'View on Maps',
              onTap: () => _openMap(context),
            ),
            const SizedBox(height: 24),

            // Operating Hours Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0F1F4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: Color(0xFF9AA0A6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Support availability: Mon – Sat, 9:30 AM to 6:30 PM IST',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F1F4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555B63),
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFC4C8CE),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
