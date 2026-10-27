import 'package:dpp_soft_toys/app_initializer.dart';
import 'package:dpp_soft_toys/providers/dpp_provider.dart';
import 'package:dpp_soft_toys/providers/nav_provider.dart';
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
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => DppProvider()),
      ],
      child: const ForestFriendsApp(),
    ),
  );
}

class ForestFriendsApp extends StatelessWidget {
  const ForestFriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(440, 932),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Forest Friends · Teddy Pet Toy Passport',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.cream,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.forest,
              surface: AppColors.cream,
            ),
          ),
          home: const AppInitializer(),
        );
      },
    );
  }
}

const double kDesktopBreakpoint = 700;

