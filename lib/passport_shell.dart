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

/// App shell. One `_screens` list — each of the 5 tabs is now a single
/// responsive screen widget (see `screens/*_screen.dart`) that lays
/// itself out for mobile or desktop internally, so there is no more
/// separate mobile/desktop screen list to keep in sync here. A single
/// top-level [LayoutBuilder] still decides the overall arrangement
/// (bottom tab bar vs. left side rail) to match the two source HTML
/// files, and live window resizing (e.g. on web/desktop) re-lays
/// everything out automatically.
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

  /// Mirrors the source Mobile HTML: brand header on top, content fills the
  /// space between it and the bottom tab bar, edge-to-edge.
  ///
  /// `bottom: false` — [AppNavBar.bottom]'s own padding already adds
  /// `MediaQuery.of(context).padding.bottom` itself (to sit clear of a
  /// home indicator / gesture bar), so leaving the default `SafeArea`
  /// bottom inset on here would reserve that same space twice, shrinking
  /// the `Expanded` content by it and overflowing the Column by a few
  /// pixels on devices with a non-zero bottom inset.
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

  /// Mirrors the source Desktop HTML: a full-width header on top, a fixed
  /// left sidebar nav, and the active screen filling the remaining space.
  ///
  /// The app's one `ScreenUtilInit` (in `main.dart`) is scaled for the
  /// MOBILE design (440×932). Reusing that same scale for the desktop
  /// branches blows every `.w`/`.h`/`.sp`/`.r` value up ~2-3x on a real
  /// desktop window (e.g. the side nav and hero text overflowing) — the
  /// desktop HTML was authored in real CSS pixels with no extra scaling
  /// beyond the >=700px breakpoint reflow. A nested `ScreenUtilInit`,
  /// scoped to just this desktop subtree, with `designSize` set to the
  /// *current* window size, makes every `.w`/`.h`/`.sp`/`.r` call inside
  /// every desktop branch (header, side nav, all 5 screens) resolve to
  /// (almost exactly) the literal number written, i.e. real pixels —
  /// which is what the desktop design actually wants.
  Widget _buildDesktop(BoxConstraints constraints) {
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 900.0;
    return ScreenUtilInit(
      designSize: Size(constraints.maxWidth, height),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFF7F4EB),
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
