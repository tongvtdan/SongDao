import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:songdao/l10n/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.today),
            label: l10n.tabToday,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: l10n.tabCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: l10n.tabPray,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.church),
            label: l10n.tabChurch,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: l10n.tabProgress,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
