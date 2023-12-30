import 'dart:async';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class UIImageProvider {

  Future<ui.Image> getImage(String url) async {
    final storageRef = FirebaseStorage.instance.ref();
    final pathReference = storageRef.child(url);
    final downloadUrl = await pathReference.getDownloadURL();
    final http.Response response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}, $url');
    }
    final Uint8List bytes = response.bodyBytes;

    final codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
