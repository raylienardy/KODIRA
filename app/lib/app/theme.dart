import 'package:flutter/material.dart';

/// Design tokens for KODIRA.
class KodiraColors {
  // Primary colors
  static const Color primary900 = Color(0xFF3D33B8);
  static const Color primary700 = Color(0xFF5B4FE9);
  static const Color primary500 = Color(0xFF7C6FF0);
  static const Color primary100 = Color(0xFFEEF0F7);

  // Success colors
  static const Color success700 = Color(0xFF00A88E);
  static const Color success500 = Color(0xFF00C2A8);
  static const Color success100 = Color(0xFFE6F9F5);

  // Reward colors
  static const Color reward700 = Color(0xFFE59400);
  static const Color reward500 = Color(0xFFFFB020);
  static const Color reward100 = Color(0xFFFFF4E0);

  // Alert colors
  static const Color alert700 = Color(0xFFD94A4A);
  static const Color alert500 = Color(0xFFFF6B6B);
  static const Color alert100 = Color(0xFFFFE5E5);

  // Neutral palette
  static const Color neutral900 = Color(0xFF1A1D2B);
  static const Color neutral700 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral300 = Color(0xFF9CA3AF);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF7F8FC);
  static const Color neutral0   = Color(0xFFFFFFFF);

  // Semantic colors
  static const Color info      = Color(0xFF3B82F6);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color error     = Color(0xFFEF4444);
  static const Color successAlt = Color(0xFF10B981);

  // Code syntax colors
  static const Color codeBg       = Color(0xFF1A1D2B);
  static const Color codeKeyword  = Color(0xFFC792EA);
  static const Color codeVariable = Color(0xFF82AAFF);
  static const Color codeString   = Color(0xFFC3E88D);
  static const Color codeNumber   = Color(0xFFF78C6C);
  static const Color codeComment  = Color(0xFF6B7280);
}

class KodiraSpacing {
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
}

class KodiraRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double full = 9999.0;
}

class KodiraShadows {
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(26, 29, 43, 0.05),
    ),
  ];
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color.fromRGBO(26, 29, 43, 0.06),
    ),
  ];
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color.fromRGBO(26, 29, 43, 0.08),
    ),
  ];
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color.fromRGBO(26, 29, 43, 0.12),
    ),
  ];
  static const List<BoxShadow> primary = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 20,
      color: Color.fromRGBO(91, 79, 233, 0.35),
    ),
  ];
}

class KodiraTextStyles {
  static const TextStyle display = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 1.0,
  );
  static const TextStyle code = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );
}
