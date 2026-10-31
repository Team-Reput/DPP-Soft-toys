import 'package:dpp_soft_toys/main.dart' show kDesktopBreakpoint;
import 'package:dpp_soft_toys/screens/brand_screen.dart';
import 'package:dpp_soft_toys/screens/care_screen.dart';
import 'package:dpp_soft_toys/screens/home_screen.dart';
import 'package:dpp_soft_toys/screens/impact_screen.dart';
import 'package:dpp_soft_toys/screens/journey_screen.dart';
import 'package:dpp_soft_toys/theme/app_colors.dart';
import 'package:dpp_soft_toys/widgets/app_header.dart';
import 'package:dpp_soft_toys/widgets/bottom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PassportShell extends StatefulWidget {
  const PassportShell({super.key});

  @override
  State<PassportShell> createState() => _PassportShellState();
}

class _PassportShellState extends State<PassportShell> {
  int _tabIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ImpactScreen(),
    JourneyScreen(),
    CareScreen(),
    BrandScreen(),
  ];

  void _onTabTap(int i) => setState(() => _tabIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
          return isDesktop ? _buildDesktop(constraints) : _buildMobile();
        },
      ),
    );
  }

  Widget _buildMobile() {
    return ColoredBox(
      color: AppColors.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: IndexedStack(index: _tabIndex, children: _screens),
            ),
            AppNavBar.bottom(currentIndex: _tabIndex, onTap: _onTabTap),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop(BoxConstraints constraints) {
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 900.0;
    return ScreenUtilInit(
      designSize: Size(constraints.maxWidth, height),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) => ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppNavBar.side(currentIndex: _tabIndex, onTap: _onTabTap),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(55.w, 42.h, 55.w, 0),
                      child: IndexedStack(index: _tabIndex, children: _screens),
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
