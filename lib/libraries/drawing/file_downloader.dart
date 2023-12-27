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
    int dataSize;
    String lowerCaseUrl = url.toLowerCase();
    if (lowerCaseUrl.contains('sd')) {
      dataSize = (2.5 * 1024 * 1024).toInt(); // two megabytes
    } else if (lowerCaseUrl.contains('uhd')) {
      dataSize = 10 * 1024 * 1024; // ten megabytes
    } else if (lowerCaseUrl.contains('hd')) {
      dataSize = 6 * 1024 * 1024; // four megabytes
    } else if (lowerCaseUrl.contains('smallthumbnail')){
      dataSize = 256 * 1024; // one megabyte as default
    } else {
      dataSize = 1024  * 1024; // one megabyte as default
    }
    try {
      final Uint8List? data = await drawingRef.getData(dataSize);
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
