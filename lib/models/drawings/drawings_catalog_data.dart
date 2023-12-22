import 'package:ardennes/models/drawings/drawing_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingVersion {
  final int id;
  final String name;
  final int sheetsCount;
  final String createdByUserId;
  final DateTime issuanceDate;

  DrawingVersion({
    required this.id,
    required this.name,
    required this.sheetsCount,
    required this.createdByUserId,
    required this.issuanceDate,
  });

  factory DrawingVersion.fromMap(Map<String, dynamic> map) {
    return DrawingVersion(
      id: map['id'],
      name: map['name'],
      sheetsCount: map['sheets_count'],
      createdByUserId: map['created_by_user_id'],
      issuanceDate: (map['issuance_date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sheets_count': sheetsCount,
      'created_by_user_id': createdByUserId,
      'issuance_date': Timestamp.fromDate(issuanceDate),
    };
  }
}

class DrawingCollection {
  final String name;
  final Map<String, Map<String, int>> versions;
  final String createdByUserId;
  final DateTime createOn;

  DrawingCollection({
    required this.name,
    required this.versions,
    required this.createdByUserId,
    required this.createOn,
  });

  factory DrawingCollection.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, dynamic>> originalVersions = Map<String, Map<String, dynamic>>.from(map['versions']);

    Map<String, Map<String, int>> convertedVersions = originalVersions.map((key, value) {
      return MapEntry(key, value.map((innerKey, innerValue) {
        return MapEntry(innerKey, int.parse(innerValue.toString()));
      }));
    });

    return DrawingCollection(
      name: map['name'],
      versions: convertedVersions,
      createdByUserId: map['created_by_user_id'],
      createOn: (map['create_on'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'versions': versions,
      'created_by_user_id': createdByUserId,
      'create_on': Timestamp.fromDate(createOn),
    };
  }
}

class DrawingDiscipline {
  final String designator;
  final String name;
  final Map<String, Map<String, int>> versions;

  DrawingDiscipline({
    required this.designator,
    required this.name,
    required this.versions,
  });

  factory DrawingDiscipline.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, dynamic>> originalVersions = Map<String, Map<String, dynamic>>.from(map['versions']);

    Map<String, Map<String, int>> convertedVersions = originalVersions.map((key, value) {
      return MapEntry(key, value.map((innerKey, innerValue) {
        return MapEntry(innerKey, int.parse(innerValue.toString()));
      }));
    });

    return DrawingDiscipline(
      designator: map['designator'],
      name: map['name'],
      versions: convertedVersions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'designator': designator,
      'name': name,
      'versions': versions,
    };
  }
}

class DrawingTag {
  final String name;
  final Map<String, Map<String, int>> versions;

  DrawingTag({
    required this.name,
    required this.versions,
  });

  factory DrawingTag.fromMap(Map<String, dynamic> map) {
    Map<String, Map<String, dynamic>> originalVersions = Map<String, Map<String, dynamic>>.from(map['versions']);

    Map<String, Map<String, int>> convertedVersions = originalVersions.map((key, value) {
      return MapEntry(key, value.map((innerKey, innerValue) {
        return MapEntry(innerKey, int.parse(innerValue.toString()));
      }));
    });

    return DrawingTag(
      name: map['name'],
      versions: convertedVersions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'versions': versions,
    };
  }
}

class PublishedLog {
  final String sessionId;
  final List<String> fileNames;
  final String collection;
  final String versionSet;
  final int versionId;
  final int sheetsCount;
  final String status;
  final DateTime issuanceDate;
  final DateTime publishedOnDate;
  final String publishedByUserId;

  PublishedLog({
    required this.sessionId,
    required this.fileNames,
    required this.collection,
    required this.versionSet,
    required this.versionId,
    required this.sheetsCount,
    required this.status,
    required this.issuanceDate,
    required this.publishedOnDate,
    required this.publishedByUserId,
  });

  factory PublishedLog.fromMap(Map<String, dynamic> map) {
    return PublishedLog(
      sessionId: map['session_id'],
      fileNames: List<String>.from(map['file_names']),
      collection: map['collection'],
      versionSet: map['version_set'],
      versionId: map['version_id'],
      sheetsCount: map['sheets_count'],
      status: map['status'],
      issuanceDate: (map['issuance_date'] as Timestamp).toDate(),
      publishedOnDate: (map['published_on_date'] as Timestamp).toDate(),
      publishedByUserId: map['published_by_user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'file_names': fileNames,
      'collection': collection,
      'version_set': versionSet,
      'version_id': versionId,
      'sheets_count': sheetsCount,
      'status': status,
      'issuance_date': Timestamp.fromDate(issuanceDate),
      'published_on_date': Timestamp.fromDate(publishedOnDate),
      'published_by_user_id': publishedByUserId,
    };
  }
}

class DrawingsCatalogData {
  final String projectId;
  final List<DrawingVersion> versions;
  final List<DrawingCollection> collections;
  final List<DrawingDiscipline> disciplines;
  final List<DrawingTag> tags;
  List<DrawingItem> drawingItems;

  DrawingsCatalogData({
    required this.projectId,
    required this.versions,
    required this.collections,
    required this.disciplines,
    required this.tags,
    required this.drawingItems,
  });
  factory DrawingsCatalogData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();

    return DrawingsCatalogData(
      projectId: data?['project_id'],
      versions: data?['versions'] is Iterable
          ? List.from(data?['versions'])
          .map((version) => DrawingVersion.fromMap(version))
          .toList()
          : [],
      collections: data?['collections'] is Iterable
          ? List.from(data?['collections'])
          .map((collection) => DrawingCollection.fromMap(collection))
          .toList()
          : [],
      disciplines: data?['disciplines'] is Iterable
          ? List.from(data?['disciplines'])
          .map((discipline) => DrawingDiscipline.fromMap(discipline))
          .toList()
          : [],
      tags: data?['tags'] is Iterable
          ? List.from(data?['tags'])
          .map((tag) => DrawingTag.fromMap(tag))
          .toList()
          : [],
      drawingItems: [],
    );
  }
  static Map<String, dynamic> toFirestore(DrawingsCatalogData drawingsCatalogData, SetOptions? options) {
    return {
      'project_id': drawingsCatalogData.projectId,
      'versions': drawingsCatalogData.versions.map((x) => x.toMap()).toList(),
      'collections': drawingsCatalogData.collections.map((x) => x.toMap()).toList(),
      'disciplines': drawingsCatalogData.disciplines.map((x) => x.toMap()).toList(),
      'tags': drawingsCatalogData.tags.map((x) => x.toMap()).toList(),
    };
  }
}
