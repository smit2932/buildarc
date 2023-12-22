import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

abstract class FileDownloader {
  Future<Uint8List> downloadFile(String url, String filename);
}

class FirebaseFileDownloader implements FileDownloader {
  static final FirebaseFileDownloader _singleton =
      FirebaseFileDownloader._internal();

  factory FirebaseFileDownloader() {
    return _singleton;
  }

  FirebaseFileDownloader._internal();

  @override
  Future<Uint8List> downloadFile(String url, String filename) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    final drawingRef = storageRef.child(url );

    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await drawingRef.getData(oneMegabyte);
      if (data != null) {
        return data;
      } else {
        throw Exception("No data");
      }
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }
}
