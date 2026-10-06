import 'package:dealer/core/theme/colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  /// Indices that can't be switched to right now (e.g. every tab but
  /// Auction, during a trial session). A locked item still renders —
  /// it's just dimmed and routes its tap to [onLockedTap] instead of
  /// [onTap].
  final Set<int> lockedIndices;
  final void Function(int index)? onLockedTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.lockedIndices = const {},
    this.onLockedTap,
  });

  static const activeColor = AppColors.primary;

  static const _icons = [
    Icons.home_rounded,
    Icons.gavel,
    Icons.upload,
    Icons.history,
    Icons.person,
  ];
  static const _labels = ['Home', 'Auction', 'Sell', 'Listings', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _icons.length; i++)
              _NavItem(
                icon: _icons[i],
                label: _labels[i],
                isActive: currentIndex == i,
                isLocked: lockedIndices.contains(i),
                onTap: lockedIndices.contains(i)
                    ? () => onLockedTap?.call(i)
                    : () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLocked = false,
  });

  static const activeColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final active = isActive && !isLocked;
    final iconColor = isLocked ? Colors.grey.shade400 : activeColor;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.55 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: active ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: active ? Colors.transparent : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 4,
                          )
                        ],
                ),
                child: isLocked
                    ? Icon(Icons.lock_outline_rounded,
                        size: 14, color: iconColor)
                    : Icon(
                        icon,
                        size: 18,
                        color: active ? Colors.white : iconColor,
                      ),
              ),
              if (active) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
