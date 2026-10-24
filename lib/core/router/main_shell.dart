import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Glass (blur + transparent + glossy) floating tab bar, sirf icons:
/// Home, Analytics, [+ Add], Recently deleted, Settings.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = <_TabData>[
    _TabData(Icons.home_mini_sharp, Icons.home_rounded, 'Home'),
    _TabData(
      Icons.pie_chart_rounded,
      Icons.auto_graph_rounded,
      'Analytics',
    ),
    _TabData(
      Icons.archive_rounded,
      Icons.delete_rounded,
      'Recently deleted',
    ),
    _TabData(Icons.person, Icons.settings_rounded, 'Settings'),
  ];

  void _onTab(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      // Same tab dobara dabane par us tab ke root par wapas jao
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6E6E73);
    final buttonColor = isDark ? Colors.white : Colors.black;
    final buttonIconColor = isDark ? Colors.black : Colors.white;
    final current = navigationShell.currentIndex;

    // Glass ki settings: ye numbers badal kar look tune kar sakte ho
    const blurSigma = 22.0; // zyada = zyada blur
    final glassTop = Colors.white.withValues(
      alpha: isDark ? 0.16 : 0.60,
    ); // zyada = kam transparent
    final glassBottom = Colors.white.withValues(alpha: isDark ? 0.05 : 0.28);
    final borderColor = Colors.white.withValues(alpha: isDark ? 0.18 : 0.70);
    final glossTop = Colors.white.withValues(alpha: isDark ? 0.14 : 0.50);

    final radius = BorderRadius.circular(32);

    Widget tab(int index) {
      return Expanded(
        child: _NavItem(
          data: _tabs[index],
          selected: current == index,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onTap: () => _onTab(index),
        ),
      );
    }

    return Scaffold(
      // Body bar ke peeche tak failti hai, isliye bar sach mein floating dikhti hai
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Container(
            height: 64,
            // Shadow clip ke bahar rakhi hai taake kate nahi
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: borderColor, width: 1),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [glassTop, glassBottom],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          tab(0),
                          tab(1),
                          _CenterButton(
                            color: buttonColor,
                            iconColor: buttonIconColor,
                            isDark: isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/add');
                            },
                          ),
                          tab(2),
                          tab(3),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final IconData selectedIcon;
  final String label; // sirf accessibility ke liye, screen par nahi dikhta

  const _TabData(this.icon, this.selectedIcon, this.label);
}

class _NavItem extends StatelessWidget {
  final _TabData data;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? data.selectedIcon : data.icon,
              key: ValueKey(selected),
              size: 28,
              color: selected ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _CenterButton({
    required this.color,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Halki glossy gradient taake button bhi glass bar se match kare
    final top = isDark ? Colors.white : const Color(0xFF3C3C40);
    final bottom = isDark ? const Color(0xFFD8D8DC) : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Semantics(
        button: true,
        label: 'Add subscription',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, bottom],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.5 : 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.add_rounded, color: iconColor, size: 26),
          ),
        ),
      ),
    );
  }
}