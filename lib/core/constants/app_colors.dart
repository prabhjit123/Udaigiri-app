import 'package:flutter/material.dart';

class AppColors {
  // Gradient Colors
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warningGradient = LinearGradient(
    colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Solid Colors
  static const background = Color(0xFF0A0E27);
  static const surface = Color(0xFF1A1D3A);
  static const card = Color(0xFF252849);
  static const accent = Color(0xFF667eea);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B3D1);
  static const textMuted = Color(0xFF6B7280);
}
