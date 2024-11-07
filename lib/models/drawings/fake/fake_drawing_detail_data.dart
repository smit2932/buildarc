import 'dart:math';

import 'package:ardennes/models/drawings/fake/fake_drawing_detail_log.dart';
import 'package:ardennes/models/fake_helper/document_id_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sampleDrawingDetail1 = {
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
      "published_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
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

final sampleDrawingDetail2 = {
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
      "published_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
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

void populateSampleDrawingsDetails() {
  final projects = FirebaseFirestore.instance.collection("drawings");
  for (var drawings in [
    <String, dynamic>{
      "document_id": "3jd7395jf736h295h",
      "content": sampleDrawingDetail1
    },
    <String, dynamic>{
      "document_id": "9573hfkj295hjfk2o93jn",
      "content": sampleDrawingDetail2
    }
  ]) {
    projects.doc(drawings["document_id"]).set(drawings["content"]);
  }
}

List<dynamic> populateDrawingsDetailNoorAcademy() {
  final Timestamp issuanceDate =
      Timestamp.fromDate(DateTime.parse("2023-12-15"));

  final random = Random(getDeterministicRandomSeed("drawings"));

  final projects = [
    "dkm87fh3fdh30j", // I-275 Reconstruction
    "d8j3h8d7h3d8h" // I-696 Reconstruction
  ];

  final versions = [
    {"id": "0", "name": "Initial Set"},
    {"id": "1", "name": "Version Two"}
  ];

  final collections = ["Story One", "Zone Two", "ungrouped"];

  final disciplines = [
    {"name": "Architecture", "prefix": "A"},
    {"name": "Geotechnical", "prefix": "G"},
    {"name": "Civil", "prefix": "C"}
  ];

  final versionData = List.generate(40, (i) {
    final selectedVersion = versions[random.nextInt(versions.length)];
    return {
      "version_name": selectedVersion["name"],
      "issuance_date": issuanceDate,
      "publish_session_id": "83jfnh4i5763gj",
      "published_by_user_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
      "status": "published",
      "files": {
        "pdf_path": "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}.pdf",
        "micro_thumbnail_image":
            "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SmallThumbnail.jpg",
        "thumbnail_image":
            "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_Thumbnail.jpg",
        "sd_image": "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SD.jpg",
        "hd_image": "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_HD.jpg",
        "uhd_image": "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_UHD.jpg",
        "sheet_number_clip":
            "drawing_images/3ndmjoe8yhfhn2/ARCH_page_${i + 1}_SmallThumbnail.jpg",
      },
    };
  });

  final drawingsData =
      List<Map<String, dynamic>>.generate(versionData.length, (i) {
    final discipline = disciplines[random.nextInt(disciplines.length)];
    final selectedVersion = versions[random.nextInt(versions.length)];

    final tags = <String>[];
    if (random.nextBool()) tags.add("tag1");
    if (random.nextBool()) tags.add("tag2");
    if (tags.isEmpty) tags.add("tag1"); // Ensure at least one tag

    return {
      "project_id": projects[random.nextBool() ? 0 : 1],
      "collection": collections[random.nextInt(collections.length)],
      "number": "${discipline['prefix']}-${i + 1}",
      "discipline": discipline['name'],
      "tags": tags,
      "versions": {
        selectedVersion["id"]: versionData[i],
      },
    };
  });

  // Then use this data to populate Firestore
  for (var drawing in drawingsData) {
    final documentId = generateDocumentId(20, random);
    FirebaseFirestore.instance.collection("drawings").doc(documentId).set({
      "project": drawing["project_id"],
      "collection": drawing["collection"],
      "number": drawing["number"],
      "discipline": drawing["discipline"],
      "tags": drawing["tags"],
      "versions": drawing["versions"],
    });
    populateDrawingDetailActivityLogs(documentId);
  }

  return drawingsData;
}
