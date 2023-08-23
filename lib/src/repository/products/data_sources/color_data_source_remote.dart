import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:easy_color/src/common/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' show debugPrint;
import 'package:translator_plus/translator_plus.dart';

import '../../../services/shared_preferences_service.dart';

class ColorDataSourceRemote {
  final SharedPreferencesService shared = SharedPreferencesService();

  ColorDataSourceRemote();

  Future<Map?> getColorMap (String colorNameStr) async {
    debugPrint('ColorDataSourceRemote - getColorMap()...');

    debugPrint('ColorDataSourceRemote - getColorMap() - translating color[AUTO] = "$colorNameStr" to color[EN]...');
    Translation translation = await GoogleTranslator().translate(colorNameStr, from: 'es', to: 'en');
    String colorName = translation.text;
    debugPrint('getColorMap() - translating color[AUTO] = "$colorNameStr" to color[EN]...DONE - text: "$colorName", sourceLanguage.name: "${translation.sourceLanguage.name}", sourceLanguage.code:"${translation.sourceLanguage.code}"');

    const appName = 'color-names.herokuapp.com';
    const domainUrl = 'https://$appName/v1/names/';

    Map? colorMap;
    String url = '$domainUrl?name=$colorName';
    http.Response response;
    try {
      debugPrint('getColorMap() - fetching color data from $appName...');
      response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      debugPrint('getColorMap() - fetching color data from $appName...DONE');
    } on TimeoutException catch (_) {
      debugPrint('getColorMap() - fetching color data from $appName...ERROR: "TimeoutException"');
      return null;
    } catch(e) {
      debugPrint('getColorMap() - fetching color data from $appName...ERROR: "$e"');
      return null;
    }

    debugPrint('getColorMap() - response.statusCode: "${response.statusCode}"');
    if(response.statusCode == 200) {
      debugPrint('getColorMap() - parsing RESPONSE data...');
      List colors = json.decode(response.body)['colors'] as List;
      debugPrint('colors: "${colors.length}"');

      List finalList = [];
      // Set remoteColorNamesList = colors.map((e) => e['name']).toList().toSet();
      // debugPrint('remoteColorNamesList: "$remoteColorNamesList"');

      if(colors.isNotEmpty) {
        debugPrint('Getting colors in cache...');
        List<Map> sharedPrefColorList = shared.getAllColorMap();
        Set colorNamesList = sharedPrefColorList.map((e) => e['name']).toList().toSet();
        debugPrint('Getting colors in cache... DONE - [${sharedPrefColorList.length}]');

        List newColors = colors.where((element) => !colorNamesList.contains(element['name'])).toList();
        debugPrint('new colors: "${newColors.length}"');

        if(newColors.isNotEmpty) {
          debugPrint('Adding new "${newColors.length}" colors to cache list...');
          sharedPrefColorList.addAll(List<Map>.from(newColors));

          debugPrint('Saving "${newColors.length}" + cached "${colorNamesList.length}" colors to cache...');
          // final finalList = sharedPrefColorList.map((map) => Map<String, dynamic>.from(map)).toList();
          finalList = sharedPrefColorList.map((map) => Map<String, dynamic>.from(map)).toList();
          shared.setAllColorMap(json.encode(finalList));
          debugPrint('Saving new "${finalList.length}" colors to cache... DONE');
        }
      }
      var match = colors.firstWhereOrNull((e) => e['name'].toString().toLowerCase().trim() == colorName.toLowerCase().trim());
      // var match = null;

      if(match != null) {
        colorMap = match;
      } else {
        // colorMap = colors.first;

        String valueStr = colorName.toLowerCase().trim();

        List nameList = colors.map((e) => e['name'].toLowerCase().trim()).toList();
        List<String> colorNameList = List<String>.from(nameList);

        debugPrint('findMostSimilarString() - value: "$valueStr" in LIST: [${colorNameList.length}]...');
        String matchString = valueStr.findMostSimilarString(colorNameList);
        debugPrint('matchString: "$matchString"');

        match = colors.firstWhereOrNull((e) => e['name'].toString().toLowerCase().trim() == matchString.toLowerCase().trim());
        colorMap = match;

        List allColorNames = finalList.map((e) => e['name'].toString().toLowerCase().trim()).toList();
        if(!allColorNames.contains(valueStr)) {
          Map newColor = Map<String, dynamic>.from(match);
          newColor['name'] = valueStr;
          shared.addColorMap(newColor);
        }
      }
    }
    return colorMap;
  }
}
