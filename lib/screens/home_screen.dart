
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<_TabInfo> _tabs = [
    _TabInfo('Dashboard', Icons.dashboard, '/dashboard'),
    _TabInfo('Xe', Icons.directions_car, '/manage/vehicles'),
    _TabInfo('Khách hàng', Icons.people, '/manage/customers'),
    _TabInfo('Dịch vụ', Icons.miscellaneous_services, '/manage/services'),
    _TabInfo('Phụ tùng', Icons.build, '/manage/parts'),
    _TabInfo('Nhân viên', Icons.engineering, '/manage/staff'),
    _TabInfo('Báo cáo', Icons.analytics, '/manage/reports'),
    _TabInfo('Cài đặt', Icons.settings, '/settings'),
  ];

  void _onTabTapped(int index) {
    final tab = _tabs[index];
    final currentUri = GoRouterState.of(context).uri.toString();
    if (currentUri != tab.route) {
      GoRouter.of(context).go(tab.route);
    }
    setState(() => _selectedIndex = index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync selected tab with current route
    String location = '/';
    try {
      location = GoRouterState.of(context).uri.toString();
    } catch (_) {
      final routeName = ModalRoute.of(context)?.settings.name;
      if (routeName != null && routeName.isNotEmpty) {
        location = routeName;
      }
    }
    final idx = _tabs.indexWhere((tab) => location.startsWith(tab.route));
    if (idx != -1 && idx != _selectedIndex) {
      setState(() => _selectedIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor.withOpacity(0.95), Theme.of(context).primaryColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 12),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              iconSize: 30,
              items: _tabs
                  .map((tab) => BottomNavigationBarItem(
                        icon: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                            vertical: _tabs[_selectedIndex] == tab ? 2 : 0,
                            horizontal: _tabs[_selectedIndex] == tab ? 8 : 0,
                          ),
                          decoration: _tabs[_selectedIndex] == tab
                              ? BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                )
                              : null,
                          child: Icon(tab.icon, size: 30),
                        ),
                        label: tab.label,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final String route;
  const _TabInfo(this.label, this.icon, this.route);
}
