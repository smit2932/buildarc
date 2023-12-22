import 'dart:math';

import 'package:ardennes/models/drawings/fake/fake_drawing_detail_log.dart';
import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final drawingDetail1 = {
  "project": "dkm87fh3fdh30j",
  "collection": "Story One",
  "number": "A-001",
  "discipline": "Architectural",
  "tags": ["tag1", "tag2"],
  "versions": {
    "0": {
      "version_name": "Initial Set",
      "issuance_date": Timestamp.now(),
      "publish_session_id": "83jfnh4i5763gj",
      "published_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
      "status": "published",
      "files": {
        "pdf_path":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-pdf_path.pdf",
        "micro_thumbnail_image":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-micro_thumbnail_image.jpg",
        "thumbnail_image":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-thumbnail_image.jpg",
        "sd_image":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-sd_image.jpg",
        "hd_image":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-hd_image.jpg",
        "uhd_image":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-uhd_image.jpg",
        "sheet_number_clip":
            "https://firebasestorage.googleapis.com/v0/b/ardennes-sheet_number_clip.jpg",
      },
    }
  },
};

final drawingDetail2 = {
  "project": "dkm87fh3fdh30j",
  "collection": "Story One",
  "number": "A-002",
  "discipline": "Architectural",
  "tags": ["tag1"],
  "versions": {
    "0": {
      "version_name": "Initial Set",
      "issuance_date": Timestamp.now(),
      "publish_session_id": "83jfnh4i5763gj",
      "published_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
      "status": "published",
      "files": {
        "pdf_path":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1.pdf",
        "micro_thumbnail_image":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_SmallThumbnail.jpg",
        "thumbnail_image":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_Thumbnail.jpg",
        "sd_image":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_SD.jpg",
        "hd_image":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_HD.jpg",
        "uhd_image":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_UHD.jpg",
        "sheet_number_clip":
            "gs://ardennes-85ab2.appspot.com/drawing_images/3ndmjoe8yhfhn2/ARCH_page_1_SmallThumbnail.jpg",
      },
    }
  }
};

void populateDrawingsDetail() {
  final projects = FirebaseFirestore.instance.collection("drawings");
  for (var drawings in [
    <String, dynamic>{
      "document_id": "3jd7395jf736h295h",
      "content": drawingDetail1
    },
    <String, dynamic>{
      "document_id": "9573hfkj295hjfk2o93jn",
      "content": drawingDetail2
    }
  ]) {
    projects.doc(drawings["document_id"]).set(drawings["content"]);
  }
  // j6fyy1LtqG4ukn9OqqgM has markups
}

List<dynamic> populateDrawingsDetailNoorAcademy() {
  final Timestamp issuanceDate =
      Timestamp.fromDate(DateTime.parse("2023-12-15"));

  final random = Random(
      getDeterministicRandomSeed("drawings")); // Seeded random number generator

  final versions = List.generate(
      40,
      (i) => {
            "version_name": "Initial Set",
            "issuance_date": issuanceDate,
            "publish_session_id": "83jfnh4i5763gj",
            "published_by_user_id": "TnUKs6PMt8UAltnGgANpYL4EZK15",
            "status": "published",
            "files": {
              "pdf_path":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}.pdf",
              "micro_thumbnail_image":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SmallThumbnail.jpg",
              "thumbnail_image":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_Thumbnail.jpg",
              "sd_image":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SD.jpg",
              "hd_image":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_HD.jpg",
              "uhd_image":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_UHD.jpg",
              "sheet_number_clip":
                  "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SmallThumbnail.jpg",
            },
          });

  for (var version in versions) {
    final documentId = generateDocumentId(20, random);
    FirebaseFirestore.instance.collection("drawings").doc(documentId).set({
      "project": "dkm87fh3fdh30j",
      "collection": "Story One",
      "number": "A-${versions.indexOf(version) + 1}",
      "discipline": "Architecture",
      "tags": ["tag1"],
      "versions": {
        "0": version,
      },
    });
    populateFakeDrawingDetailActivityLogs(documentId);
  }

  return List<Map<String, dynamic>>.generate(
      versions.length,
      (i) => {
            "project": "dkm87fh3fdh30j",
            "collection": "Story One",
            "number": "A-${i + 1}",
            "discipline": "Architecture",
            "tags": ["tag1"],
            "versions": {
              "0": versions[i],
            },
          });
}
