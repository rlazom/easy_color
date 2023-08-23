import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:easy_color/src/common/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharePrefsAttribute {
  allColors,
}

class SharedPreferencesService {
  /// singleton boilerplate
  static final SharedPreferencesService _sharedPreferencesService = SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _sharedPreferencesService;
  }

  SharedPreferencesService._internal();
  /// singleton boilerplate

  late SharedPreferences _prefs;
  SharedPreferences get prefs => _prefs;

  Future initialize() async => _prefs = await SharedPreferences.getInstance();

  /// COLORS
  List<Map> getAllColorMap() {
    List<Map> list = [];
    String? colorsStr = prefs.getString(SharePrefsAttribute.allColors.name.toShortString());
    if(colorsStr != null) {
      List tList = json.decode(colorsStr) as List;
      list = List.from(tList);
    }
    return list;
  }

  void setAllColorMap(var json) {
    prefs.setString(SharePrefsAttribute.allColors.name.toShortString(), json);
  }

  Map? getColorMap(String colorName) {
    Set<Map> list = getAllColorMap().toSet();
    Map? match = list.firstWhereOrNull((e) => e['name'].toString().toLowerCase().trim() == colorName.toLowerCase().trim());
    return match;
  }

  void addColorMap(Map map) {
    List<Map> list = getAllColorMap();
    Set listStr = list.map((e) => e['name']).toList().toSet();
    if(!listStr.contains(map['name'])) {
      list.add(map);
      prefs.setString(SharePrefsAttribute.allColors.name.toShortString(), json.encode(list.toList()));
    }
  }

  void removeColorMap(String colorName) {
    Set<Map> list = getAllColorMap().toSet();
    list.removeWhere((element) => element['name'] == colorName);
    prefs.setString(SharePrefsAttribute.allColors.name.toShortString(), json.encode(list.toList()));
  }

  removeColors() {
    prefs.remove(SharePrefsAttribute.allColors.name.toShortString());
  }
}
