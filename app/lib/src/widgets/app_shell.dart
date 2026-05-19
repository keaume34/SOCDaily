// Responsive app scaffold: floating pill nav on mobile, side rail on tablet/web.
// Mastercard-inspired: warm cream canvas, floating white nav pill, atmospheric shadows.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class AppShellDestination {
  const AppShellDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppShellDestination> destinations;

  static const double _wideBreakpoint = 768;

  void _onTap(int i) => navigationShell.goBranch(
        i,
        initialLocation: i == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _wideBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _SideRail(
              selectedIndex: navigationShell.currentIndex,
              destinations: destinations,
              onTap: _onTap,
              isDark: isDark,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FloatingNavPill(
        selectedIndex: navigationShell.currentIndex,
        destinations: destinations,
        onTap: _onTap,
        isDark: isDark,
      ),
    );
  }
}

// ── Floating pill nav bar (mobile) ──
class _FloatingNavPill extends StatelessWidget {
  const _FloatingNavPill({
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
    required this.isDark,
  });

  final int selectedIndex;
  final List<AppShellDestination> destinations;
  final ValueChanged<int> onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF222220).withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < destinations.length; i++)
            _NavPillItem(
              icon: i == selectedIndex
                  ? destinations[i].selectedIcon
                  : destinations[i].icon,
              label: destinations[i].label,
              selected: i == selectedIndex,
              onTap: () => onTap(i),
              isDark: isDark,
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _NavPillItem extends StatelessWidget {
  const _NavPillItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? theme.colorScheme.primary
        : (isDark ? Colors.white.withOpacity(0.45) : MCColors.slateGray);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(isDark ? 0.12 : 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SofiaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: -0.26,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Side rail (tablet/desktop) ──
class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
    required this.isDark,
  });

  final int selectedIndex;
  final List<AppShellDestination> destinations;
  final ValueChanged<int> onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1917)
            : MCColors.canvasCream,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : MCColors.dividerCream,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MCColors.inkBlack,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontFamily: 'SofiaSans',
                  color: MCColors.canvasCream,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < destinations.length; i++) ...[
            _RailItem(
              icon: i == selectedIndex
                  ? destinations[i].selectedIcon
                  : destinations[i].icon,
              label: destinations[i].label,
              selected: i == selectedIndex,
              onTap: () => onTap(i),
              isDark: isDark,
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : (isDark ? Colors.white.withOpacity(0.45) : MCColors.slateGray);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(isDark ? 0.10 : 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SofiaSans',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
