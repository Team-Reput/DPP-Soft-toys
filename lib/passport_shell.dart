import 'package:dpp_soft_toys/main.dart' show kDesktopBreakpoint;
import 'package:dpp_soft_toys/screens/brand_screen_desktop.dart';
import 'package:dpp_soft_toys/screens/brand_screen_mobile.dart';
import 'package:dpp_soft_toys/screens/care_screen_desktop.dart';
import 'package:dpp_soft_toys/screens/care_screen_mobile.dart';
import 'package:dpp_soft_toys/screens/desktop_side_nav.dart';
import 'package:dpp_soft_toys/screens/home_screen_desktop.dart';
import 'package:dpp_soft_toys/screens/home_screen_mobile.dart';
import 'package:dpp_soft_toys/screens/impact_screen_desktop.dart';
import 'package:dpp_soft_toys/screens/impact_screen_mobile.dart';
import 'package:dpp_soft_toys/screens/journey_screen_desktop.dart';
import 'package:dpp_soft_toys/screens/journey_screen_mobile.dart';
import 'package:dpp_soft_toys/theme/app_colors.dart';
import 'package:dpp_soft_toys/theme/desktop_header.dart';
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

  static const List<Widget> _mobileScreens = [
    HomeScreenMobile(),
    ImpactScreenMobile(),
    JourneyScreenMobile(),
    CareScreenMobile(),
    BrandScreenMobile(),
  ];

  static const List<Widget> _desktopScreens = [
    HomeScreenDesktop(),
    ImpactScreenDesktop(),
    JourneyScreenDesktop(),
    CareScreenDesktop(),
    BrandScreenDesktop(),
  ];

  void _onTabTap(int i) => setState(() => _tabIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
          return isDesktop ? _buildDesktop() : _buildMobile();
        },
      ),
    );
  }

  /// Mirrors the source Mobile HTML: brand header on top, content fills the
  /// space between it and the bottom tab bar, edge-to-edge.
  Widget _buildMobile() {
    return ColoredBox(
      color: AppColors.cream,
      child: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: IndexedStack(index: _tabIndex, children: _mobileScreens),
            ),
            BottomTabBar(currentIndex: _tabIndex, onTap: _onTabTap),
          ],
        ),
      ),
    );
  }

  /// Mirrors the source Desktop HTML: a full-width header on top, a fixed
  /// left sidebar nav, and the active screen filling the remaining space.
  Widget _buildDesktop() {
    return ColoredBox(
      color: const Color(0xFFF7F4EB),
      child: Column(
        children: [
          const DesktopHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DesktopSideNav(currentIndex: _tabIndex, onTap: _onTabTap),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(55),
                      ScreenUtil().setHeight(42),
                      ScreenUtil().setWidth(55),
                      0,
                    ),
                    child: IndexedStack(
                      index: _tabIndex,
                      children: _desktopScreens,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
