import 'dart:ui';
import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
      'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

class ColorConstants {
  static Color lightGray = hexToColor('#D3D3D3');
  static Color lightPurple = hexToColor('#CDB9F6');
  static Color darkPurple = hexToColor('#513194');
  static Color white = hexToColor('#FFFFFF');
}
