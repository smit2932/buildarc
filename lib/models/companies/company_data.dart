import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyData {
  final String? id;
  final String? name;
  final bool? isActive;
  final String? logoUrl;
  final String? address;

  CompanyData({
    this.id,
    this.name,
    this.isActive,
    this.logoUrl,
    this.address,
  });

  factory CompanyData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return CompanyData(
      id: snapshot.id,
      name: data?['name'],
      isActive: data?['is_active'],
      logoUrl: data?['logo_url'],
      address: data?['address'],
    );
  }

  static Map<String, Object?> toFirestore(
      Object? companyData, SetOptions? options) {
    if (companyData is CompanyData) {
      return {
        if (companyData.name != null) "name": companyData.name,
        if (companyData.isActive != null) "is_active": companyData.isActive,
        if (companyData.logoUrl != null) "logo_url": companyData.logoUrl,
        if (companyData.address != null) "address": companyData.address,
      };
    } else {
      throw ArgumentError("companyData is not an instance of CompanyData");
    }
  }
}
