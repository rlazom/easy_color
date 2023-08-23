import 'dart:async';

import '../../common/enums.dart';
import '../rep_master/rep_master_repository.dart';
import 'data_sources/color_data_source_local.dart';
import 'data_sources/color_data_source_remote.dart';

class ColorRepository extends RepMasterRepository {
  ColorRepository()
      : super(
          local: ColorDataSourceLocal(),
          remote: ColorDataSourceRemote(),
        );

  Future<Map?> getColorMap(String colorNameStr, {SourceType? source, bool saveClosestColor = false}) async {
    // debugPrint('ProductRepository - getColorMap()...');

    Map<SourceType, Function> allSources = {
      SourceType.local: local.getColorMap,
      SourceType.remote: remote.getColorMap,
    };

    Map? result = await getAllItemsData(
        allSources: allSources,
        source: source,
        param: {'colorNameStr': colorNameStr, 'saveClosestColor': saveClosestColor},
        singleResult: true,
        allowNull: true);
    return result;
  }
}
