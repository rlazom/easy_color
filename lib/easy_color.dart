import 'package:easy_color/src/common/extensions.dart';
import 'package:easy_color/src/repository/colors/color_repository.dart';
import 'package:easy_color/src/services/shared_preferences_service.dart';
import 'package:flutter/material.dart' show Color, Colors;

class EasyColor {
  final SharedPreferencesService _sharedPreferencesService = SharedPreferencesService();
  static final ColorRepository _repository = ColorRepository();

  EasyColor();

  Future initialize() async {
    await _sharedPreferencesService.initialize();
  }

  Future<Map?> getColorMap(colorNameStr, {bool saveClosestColor = false}) async {
    Map? colorMap = await _repository.getColorMap(colorNameStr, saveClosestColor: saveClosestColor);
    return colorMap;
  }

  Future<Color> getColor(colorNameStr, {bool saveClosestColor = false}) async {
    Map? colorMap = await getColorMap(colorNameStr, saveClosestColor: saveClosestColor);
    String? colorHex = colorMap?['hex'];
    return colorHex == null ? Colors.transparent : colorHex.hexToColor();
  }

  Color hexToColor(String val) =>
      Color(int.parse(val.substring(1, 7), radix: 16) + 0xFF000000);
}
