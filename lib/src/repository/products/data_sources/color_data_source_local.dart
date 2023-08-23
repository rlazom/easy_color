import 'dart:async';

import 'package:flutter/material.dart' show debugPrint;
import 'package:translator_plus/translator_plus.dart';

import '../../../services/shared_preferences_service.dart';

class ColorDataSourceLocal {
  final SharedPreferencesService shared = SharedPreferencesService();

  ColorDataSourceLocal();

  Future<Map?> getColorMap(String colorNameStr) async {
    debugPrint('ProductDataSourceLocal - getColorMap()...');

    debugPrint('ProductDataSourceLocal - getColorMap() - translating color[AUTO] = "$colorNameStr" to color[EN]...');
    Translation translation = await GoogleTranslator().translate(colorNameStr, from: 'es', to: 'en');
    String colorName = translation.text;
    debugPrint('getColorMap() - translating color[AUTO] = "$colorNameStr" to color[EN]...DONE - text: "$colorName", sourceLanguage.name: "${translation.sourceLanguage.name}", sourceLanguage.code:"${translation.sourceLanguage.code}"');

    var result = shared.getColorMap(colorName);

    debugPrint('ProductDataSourceLocal - getColorMap() - RETURN [$result]');
    return result;
  }
}
