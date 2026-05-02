import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const Color primaryGreen = Color(0xFF228B22);
  static const Color deepGreen = Color(0xFF196719);
  static const Color cream = Color(0xFFF9F5D2);
  static const Color ink = Color(0xFF1B1B1B);
  static const Color muted = Color(0xFF6B6B6B);

  // Surfaces
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFBF8DE);

  // Hairlines / dividers
  static const Color hairline = Color(0x141B1B1B); // rgba(27,27,27,0.08)
  static const Color hairlineSoft = Color(0x0D1B1B1B); // rgba(27,27,27,0.05)

  // Greens (tints)
  static const Color green12 = Color(0x1F228B22); // rgba(34,139,34,0.12)
  static const Color green08 = Color(0x14228B22); // rgba(34,139,34,0.08)

  // Semantic balance colors
  static const Color balancePositive = primaryGreen;
  static const Color balanceNegative = Color(0xFFB83A2E);

  // Neutrals
  static const Color placeholderGray = Color(0xFFC0C0BC);
}

class AppShadows {
  // Floating action button — green-tinted shadow on the primary-green hamburger.
  // Mirrors design: 0 6px 18px rgba(25,103,25,0.28), 0 2px 4px rgba(25,103,25,0.18)
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x47196719),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x2E196719),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // Subtle 1px-equivalent shadow under cards.
  // Mirrors design: 0 1px 0 rgba(27,27,27,0.04)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A1B1B1B),
      offset: Offset(0, 1),
    ),
  ];
}

class AppText {
  // Modak display face. Used at multiple sizes — splash (50), in-app
  // wordmark (26), section title (36 default).
  static TextStyle title({double size = 36, Color? color}) {
    return GoogleFonts.modak(
      fontSize: size,
      color: color ?? AppColors.primaryGreen,
    );
  }

  static TextStyle headline() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    );
  }

  static TextStyle body() {
    return const TextStyle(
      fontSize: 16,
      color: AppColors.ink,
    );
  }

  static TextStyle caption() {
    return const TextStyle(
      fontSize: 13,
      color: AppColors.muted,
    );
  }

  // Uppercase muted card-section header ("WHERE EVERYONE STANDS").
  static TextStyle sectionLabel() {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppColors.muted,
    );
  }

  // Bold ink hero used for the home month label ("April 2026").
  static TextStyle monthHeader() {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: AppColors.ink,
      height: 1.1,
    );
  }

  // Matrix column header label — the small "EXPENSE" cell.
  static TextStyle tableColumnLabel() {
    return const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.muted,
    );
  }

  // Matrix column header housemate name.
  static TextStyle tableColumnName() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
      height: 1,
    );
  }

  static TextStyle cardItemTitle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      height: 1.2,
    );
  }

  static TextStyle cardItemSub() {
    return const TextStyle(
      fontSize: 12,
      color: AppColors.muted,
      height: 1.2,
    );
  }

  // Per-cell amount in the expense × person matrix.
  static TextStyle tableCell({Color? color}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.ink,
      letterSpacing: -0.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle tableTotalLabel() {
    return const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
      letterSpacing: 0.1,
    );
  }

  static TextStyle tableTotalValue() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.deepGreen,
      letterSpacing: -0.2,
      fontFeatures: [FontFeature.tabularFigures()],
    );
  }

  static TextStyle balancePill({required Color color}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color,
    );
  }

  // Footnotes outside cards (the exception line under the matrix).
  static TextStyle microCaption() {
    return const TextStyle(
      fontSize: 11,
      color: AppColors.muted,
      height: 1.4,
    );
  }

  // Plain-text headline used as a tappable menu item — system font, not Modak.
  static TextStyle menuItem() {
    return const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: AppColors.ink,
      height: 1.1,
    );
  }
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
