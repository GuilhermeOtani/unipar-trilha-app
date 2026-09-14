import 'package:flutter/material.dart';

abstract final class AppColors {
  static const greenLight = Color(0xFF86CB92);
  static const green = Color(0xFF71B46D);
  static const blue = Color(0xFF404E7C);
  static const indigo = Color(0xFF251F47);
  static const plum = Color(0xFF260F26);
  static const navy950 = Color(0xFF0E082E);
  static const navy900 = Color(0xFF14183B);
  static const cyan = Color(0xFF1BB2E1);
  static const purple = Color(0xFF4A299A);
  static const successSurface = Color(0xFF143B21);
  static const dangerSurface = Color(0xFF34203B);
  static const textSoft = Color(0xFF9398C2);
  static const textLight = Color(0xFFE6EAED);
  static const navActive = Color(0xFFAE76FE);
  static const statusError = Color(0xFFFA777D);
  static const statusSuccess = Color(0xFF00BF15);
  static const notification = Color(0xFFF14538);
  static const white = Color(0xFFFFFFFF);

  static const backgroundApp = navy950;
  static const surfaceDefault = navy900;
  static const surfaceBrand = indigo;
  static const actionPrimary = greenLight;
  static const actionPrimaryHover = green;
  static const actionSecondary = purple;
  static const accentInfo = cyan;
  static const feedbackSuccessSurface = successSurface;
  static const feedbackDangerSurface = dangerSurface;
  static const textPrimary = textLight;
  static const textSecondary = textSoft;
  static const textOnAction = navy950;
  static const iconDefault = textSoft;
  static const iconActive = navActive;
  static const iconSuccess = statusSuccess;
  static const iconDanger = statusError;
}
