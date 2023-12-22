import 'dart:convert';
import 'dart:io';
import 'package:ardennes/libraries/drawing/file_downloader.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class ImageFromFirebase extends StatelessWidget {
  final String imageUrl;

  const ImageFromFirebase({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebImageFromFirebase(imageUrl: imageUrl);
    } else {
      return CachedImageFromFirebase(imageUrl: imageUrl);
    }
  }
}

class WebImageFromFirebase extends StatelessWidget {
  final String imageUrl;

  const WebImageFromFirebase({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getDownloadUrl(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Load the image from the URL
            return Image.network(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        // While the image is loading, you can display a placeholder
        return const CircularProgressIndicator();
      },
    );
  }

  Future<String> _getDownloadUrl() async {
    final storageRef = FirebaseStorage.instance.ref();
    final pathReference = storageRef.child(imageUrl);
    final downloadUrl = await pathReference.getDownloadURL();
    return downloadUrl;
  }
}

class CachedImageFromFirebase extends StatelessWidget {
  const CachedImageFromFirebase({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _getCachedImage(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Load the image from the cache
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        // While the image is loading, you can display a placeholder
        return const CircularProgressIndicator();
      },
    );
  }

  Future<Uint8List> _getCachedImage() async {
    if (kIsWeb) {
      return _downloadFile(null);
    }

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${_generateCacheFileName(imageUrl)}';
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      final imageData = await imageFile.readAsBytes();
      return imageData;
    } else {
      return _downloadFile(imageFile);
    }
  }

  Future<Uint8List> _downloadFile(File? imageFile) async {
    final imageData = await FirebaseFileDownloader()
        .downloadFile(imageUrl, _generateCacheFileName(imageUrl));
    if (imageFile != null) {
      await imageFile.writeAsBytes(imageData);
    }
    return imageData;
  }

  String _generateCacheFileName(String url) {
    var bytes = utf8.encode(url); // UTF8 encode the url
    var digest = sha256.convert(bytes); // Hash it
    return digest.toString(); // Convert the hash to a string
  }
}
