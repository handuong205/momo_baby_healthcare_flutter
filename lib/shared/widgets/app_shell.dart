import 'package:flutter/material.dart';
import 'package:momo_baby_healthcare_flutter/core/colors/app_colors.dart';

import 'app_header.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    //here you can add your screens for each tab in the bottom navigation bar
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          // Header tự xử lý SafeArea + background
          const AppHeader(
            title: 'Trang chủ',
            subtitle: 'Chào mẹ & bé yêu ✨',
            statusText: 'Tuần 24',
          ),

          // Content
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
