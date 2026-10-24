import 'package:dpp_soft_toys/main.dart';
import 'package:dpp_soft_toys/screens/brand_screen.dart';
import 'package:dpp_soft_toys/screens/care_screen.dart';
import 'package:dpp_soft_toys/screens/home_screen.dart';
import 'package:dpp_soft_toys/screens/impact_screen.dart';
import 'package:dpp_soft_toys/screens/journey_screen.dart';
import 'package:dpp_soft_toys/theme/app_colors.dart';
import 'package:dpp_soft_toys/widgets/app_header.dart';
import 'package:dpp_soft_toys/widgets/bottom_tab_bar.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On desktop/wide windows this fills the space either side of the
      // centered content column; on phones it's never visible.
      backgroundColor: AppColors.bgBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
          final content = ColoredBox(
            color: AppColors.cream,
            child: SafeArea(
              child: Column(
                children: [
                  const AppHeader(),
                  Expanded(
                    child: IndexedStack(index: _tabIndex, children: _screens),
                  ),
                  BottomTabBar(
                    currentIndex: _tabIndex,
                    onTap: (i) => setState(() => _tabIndex = i),
                  ),
                ],
              ),
            ),
          );

          if (!isDesktop) return content;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
              child: content,
            ),
          );
        },
      ),
    );
  }
}
