library easy_color;

import 'package:easy_color/src/common/extensions.dart';
import 'package:easy_color/src/repository/products/color_repository.dart';
import 'package:flutter/material.dart'
    show Border, BoxDecoration, BoxShape, Color, Colors;

class EasyColor {
  EasyColor._();

  final ColorRepository _repository = ColorRepository();

  Future<Map?> getColorMap(colorNameStr) async {
    Map? colorMap = await _repository.getColorMap(colorNameStr);
    return colorMap;
  }

  Future<Color> getColor(colorNameStr) async {
    Map? colorMap = await _repository.getColorMap(colorNameStr);
    String? colorHex = colorMap?['hex'];
    return colorHex == null ? Colors.transparent : colorHex.hexToColor();
  }

  Future<BoxDecoration> getColorDecoration(colorNameStr,
      {BoxShape shape = BoxShape.circle, Border? border}) async {
    Map? colorMap = await _repository.getColorMap(colorNameStr);
    String? colorHex = colorMap?['hex'];
    Color color = colorHex == null ? Colors.transparent : colorHex.hexToColor();

    return BoxDecoration(
      shape: shape,
      color: color,
      border: border ?? Border.all(width: 1, color: Colors.white60),
    );
  }
}
