import 'package:flutter/material.dart' show debugPrint;

import '../../common/enums.dart';
import '../../common/extensions.dart';

abstract class RepMasterRepository {
  final dynamic remote;
  final dynamic local;

  const RepMasterRepository({required this.remote, required this.local,});

  Future getAllItemsData({required Map<SourceType, Function> allSources, SourceType? source, bool singleResult = false, bool allowNull = false, param}) async {
    List result = [];

    Map<SourceType, Function> sources = {};
    if (source != null) {
      sources = {source: allSources[source]!};
    } else {
      sources = allSources;
    }

    dynamic response;
    for (var entry in sources.entries) {
      SourceType sourceType = entry.key;
      Function fn = entry.value;
      try {
        response = await (param == null ? fn() : fn(param));
      } catch (e) {
        debugPrint('RepMasterRepository - getAllItemsData() - CATCH');
        debugPrint('..sourceType: "${sourceType.toString().toShortString()}"');
        debugPrint('..fn: "${fn.toString()}", "${e.toString()}"');
        response = null;
        rethrow;
      }

      if (response != null) {
        if(singleResult) {
          return response;
        }
        result.addAll(response);
        break;
      }
    }

    return (allowNull && result.isEmpty) ? null : result;
  }

}