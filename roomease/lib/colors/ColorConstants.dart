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
  static Color lighterGray = hexToColor('#ECECEC');

  static Color lightPurple = hexToColor('#CDB9F6');
  static Color lavender = hexToColor('#f6dbff');
  static Color darkPurple = hexToColor('#513194');

  static Color white = hexToColor('#FFFFFF');
  static Color black = hexToColor('#000000');

  static Color skyBlue = hexToColor('#d4eeff');
  static Color lightBlue = hexToColor('#e6feff');

  static Color lightPink = hexToColor('#ffebfb');
  static Color pink = hexToColor('#ffd4f6');
  static Color lightRed = hexToColor('#ffdbe2');
  static Color red = hexToColor('#C21807');

  static Color lightGreen = hexToColor('#ccffcc');
}
