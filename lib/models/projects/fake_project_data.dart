import 'package:cloud_firestore/cloud_firestore.dart';

final project1 = <String, dynamic>{
  "company_id": "3ndmjoe8yhfhn2",
  "name": "I-275 Reconstruction",
  "is_active": true,
  "address": "I-275, Livonia, MI 48152",
  "number": "38742",
  "stage": "In Progress",
};
final project2 = <String, dynamic>{
  "company_id": "3ndmjoe8yhfhn2",
  "name": "I-696 Reconstruction",
  "is_active": true,
  "address": "I-696, Warren, MI 48091",
  "number": "38743",
  "stage": "In Progress",
};

void populateProjects() {
  final projects = FirebaseFirestore.instance.collection("projects");
  for (var project in [
    <String, dynamic>{"id": "dkm87fh3fdh30j", "content": project1},
    <String, dynamic>{"id": "d8j3h8d7h3d8h", "content": project2}
  ]) {
    projects.doc(project["id"]).set(project["content"]);
  }
}
