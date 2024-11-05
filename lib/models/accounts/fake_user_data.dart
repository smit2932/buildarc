import 'package:cloud_firestore/cloud_firestore.dart';

final user1 = <String, dynamic>{
  "company_id": "3ndmjoe8yhfhn2",
  "projects": [
    {"project_id": "dkm87fh3fdh30j", "project_name": "I-275 Reconstruction"},
    {"project_id": "d8j3h8d7h3d8h", "project_name": "I-696 Reconstruction"}
  ]
};

void populateUsers() {
  final users = FirebaseFirestore.instance.collection("users");
  for (var user in [
    <String, dynamic>{
      "document_id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
      "content": user1
    },
  ]) {
    users.doc(user["document_id"]).set(user["content"]);
  }
}
