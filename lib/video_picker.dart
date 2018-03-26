import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class VideoPicker {
  static const MethodChannel _channel =
      const MethodChannel('video_picker');

  static Future<File> pickVideo() async {
    final String path = await _channel.invokeMethod('pickVideo');
    return new File(path);
  }

}
