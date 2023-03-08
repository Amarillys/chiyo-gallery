import 'package:flutter/material.dart';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/utils/image_util.dart';

class ThemeUtil {
  static TextStyle getSubTextStyle() {
    return TextStyle(color: ImageUtil.mapColorFromString(GlobalConfig.get(ConfigMap.descFontColor)), fontSize: 17);
  }

  static TextStyle getDescTextStyle() {
    return TextStyle(color: ImageUtil.mapColorFromString(GlobalConfig.get(ConfigMap.descFontColor)), fontSize: 12);
  }
}