import 'package:dealer/core/route/router.gr.dart';
import 'package:dealer/core/theme/colors.dart';
import 'package:dealer/features/dashboard/presentation/logic/dasboardlogic.dart';
import 'package:dealer/features/login/presentation/logic/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFFF7F8FA),
            surfaceTintColor: Color(0xFFF7F8FA),
            title: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeroCard(isLandscape: isLandscape),
                const SizedBox(height: 18),
                const _SectionLabel('ACCOUNT'),
                const SizedBox(height: 10),
                _ModernTile(
                  icon: Icons.manage_accounts_rounded,
                  label: 'Edit Profile',
                  subtitle: 'Name, photo, contact details',
                  iconColor: AppColors.primary,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _ModernTile(
                  icon: Icons.verified_user_rounded,
                  label: 'KYC & Documents',
                  subtitle: 'Manage verification documents',
                  iconColor: const Color(0xFF27AE60),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                const _SectionLabel('GENERAL'),
                const SizedBox(height: 10),
                _ModernTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  subtitle: 'Manage alert preferences',
                  iconColor: const Color(0xFFF39C12),
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _ModernTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Help & Support',
                  subtitle: 'FAQs, contact our team',
                  iconColor: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                const SizedBox(height: 30),
                const _LogoutButton(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD — gradient background, avatar, name/role, stat pills
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends ConsumerWidget {
  final bool isLandscape;
  const _HeroCard({required this.isLandscape});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logic = ref.watch(dLogic);
    final name = logic.user?.fullName ?? '';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .take(2)
        .join();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, isLandscape ? 20 : 28, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: isLandscape ? 68 : 88,
                width: isLandscape ? 68 : 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.30),
                      Colors.white.withOpacity(0.14),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: isLandscape ? 22 : 30,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: isLandscape ? 10 : 14),
          Text(
            logic.user?.fullName ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLandscape ? 15 : 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Senior Dealer',
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: isLandscape ? 11.5 : 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: isLandscape ? 14 : 20),
          Row(
            children: [
              const Expanded(
                child: _StatPill(
                  icon: Icons.task_alt_rounded,
                  value: '42',
                  label: 'Done',
                ),
              ),
              _StatDivider(),
              const Expanded(
                child: _StatPill(
                  icon: Icons.star_rounded,
                  value: '4.8',
                  label: 'Rating',
                ),
              ),
              _StatDivider(),
              const Expanded(
                child: _StatPill(
                  icon: Icons.calendar_month_rounded,
                  value: '12',
                  label: 'Months',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 17),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Color(0xFF9AA0A6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODERN TILE — icon chip + label + subtitle + chevron
// ─────────────────────────────────────────────────────────────────────────────

class _ModernTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModernTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F1F4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF9AA0A6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_right_rounded,
                  color: Color(0xFFC4C8CE), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT BUTTON
//
// Now a ConsumerWidget that watches logoutNotifierProvider directly,
// instead of the original design of stashing `context`/`ref` as
// constructor fields (which is unusual — a StatelessWidget can always
// reach its own BuildContext via its build() method's parameter, and
// ConsumerWidget's build() already provides `ref`, so neither needed to
// be threaded in manually).
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(logoutNotifierProvider.notifier).logout();
    if (!context.mounted) return;
    ref.read(routeService).pushAndRemoveUntil(const LoginRoute(), context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutNotifierProvider);
    final isLoggingOut = logoutState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoggingOut ? null : () => _handleLogout(context, ref),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoggingOut)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                    ),
                  )
                else
                  const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  isLoggingOut ? 'Logging out…' : 'Logout',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
