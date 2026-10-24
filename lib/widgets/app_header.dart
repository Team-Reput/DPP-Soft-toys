import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top app header — brand mark + "pet passport" pill badge.
/// Mirrors `.apphead` in the source HTML.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      color: AppColors.cream,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: -0.14, // ~-8deg
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEED5AF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐾', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 8),
              Text('avanti paws', style: AppTextStyles.brand),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.passportBorder,
                width: 1,
              ),
            ),
            child: Text('✦ PET PASSPORT', style: AppTextStyles.passportBadge),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(67);
}
