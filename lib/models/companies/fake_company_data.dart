import 'package:cloud_firestore/cloud_firestore.dart';

final company1 = <String, dynamic>{
  "name": "Angelo Iafrate Construction",
  "isActive": true,
  "logoUrl":
      "https://iafrate.com/wp-content/uploads/2023/01/Iafrate-Original-Color-Switch.png",
  "address": "26300 Sherwood Ave,\n Warren, MI 48091",
};

final company2 = <String, dynamic>{
  "name": "Dan's Excavating Inc",
  "is_active": true,
  "logo_url": "https://www.dansexc.com/images/logo-red.png",
  "address": "12955 23 Mile Rd,\n Shelby Twp, MI 48315",
};

final company3 = <String, dynamic>{
  "name": "Ajax Paving",
  "is_active": true,
  "logo_url":
      "https://www.ajaxpaving.com/wp-content/uploads/2019/03/ajax-paving-logo.png",
  "address": "1957 Crooks Rd,\n Troy, MI 48084",
};

void populateCompanies() {
  final companies = FirebaseFirestore.instance.collection("companies");
  for (final company in [
    <String, dynamic>{"id": "3ndmjoe8yhfhn2", "content": company1},
    <String, dynamic>{"id": "dj3hd7539djhdd", "content": company2},
    <String, dynamic>{"id": "d8j3wh8d7h3d8h", "content": company3}
  ]) {
    companies.doc(company["id"]).set(company["content"]);
  }
}
