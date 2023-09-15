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

  Future<Map?> getColorMap (Map params) async {
    debugPrint('ColorDataSourceRemote - getColorMap()...');
    String colorNameStr = params['colorNameStr'];
    bool saveClosestColor = params['saveClosestColor'];

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

      debugPrint('Getting colors in cache...');
      List<Map> sharedPrefColorList = shared.getAllColorMap();
      Set colorNamesList = sharedPrefColorList.map((e) => e['name']).toList().toSet();
      debugPrint('Getting colors in cache... DONE - [${sharedPrefColorList.length}]');

      List newColors = colors.isEmpty ? [] : colors.where((element) => !colorNamesList.contains(element['name'])).toList();
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

      var match;
      // if(colors.isNotEmpty) {
        match = colors.firstWhereOrNull((e) => e['name'].toString().toLowerCase().trim() == colorName.toLowerCase().trim());

        if(match != null) {
          colorMap = match;
          debugPrint('EXACT MATCH: TRUE');
        } else {
          // colorMap = colors.first;
          debugPrint('EXACT MATCH: FALSE');

          String valueStr = colorName.toLowerCase().trim();

          List tColors = List.from(colors.isEmpty ? sharedPrefColorList : colors);
          List nameList = tColors.map((e) => e['name'].toLowerCase().trim()).toList();
          List<String> colorNameList = List<String>.from(nameList);

          debugPrint('findMostSimilarString() - value: "$valueStr" in LIST: [${colorNameList.length}]...');
          String matchString = valueStr.findMostSimilarString(colorNameList);
          debugPrint('matchString: "$matchString"');

          match = tColors.firstWhereOrNull((e) => e['name'].toString().toLowerCase().trim() == matchString.toLowerCase().trim());
          colorMap = match;
          debugPrint('colorMap: "$colorMap"');

          List allColorNames = finalList.map((e) => e['name'].toString().toLowerCase().trim()).toList();
          if(!allColorNames.contains(valueStr) && colorMap != null) {
            debugPrint('EXACT MATCH: FALSE');
            if(saveClosestColor) {
              debugPrint('Saving Closest Color...');
              debugPrint('Saving in cache valueStr: "$valueStr" with matchString: "$matchString" data');
              Map newColor = Map<String, dynamic>.from(colorMap);
              newColor['name'] = valueStr;
              shared.addColorMap(newColor);
              debugPrint('Saving Closest Color...DONE');
            }
          } else {
            debugPrint('EXACT MATCH: TRUE');
          }
        }
      // }
    }
    return colorMap;
  }
}
