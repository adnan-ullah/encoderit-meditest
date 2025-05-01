import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:healthcare_homelab/constants/api.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_info.dart';
import '../db/models/CategoryModel.dart';

class CostController extends GetxController {
  final categoryName = <String>[].obs;
  final toCategory = <String, dynamic>{}.obs;

  Future<void> fetchCategories() async {
    final dbRef = FirebaseDatabase.instance.ref("$categoryApi/");
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      categoryName.clear();
      toCategory.clear();
      final categories = snapshot.value as Map;
      categories.forEach((key, value) {
        final category =
            CategoryModel.fromJson(Map<String, dynamic>.from(value));
        categoryName.add(category.name);
        toCategory[category.name] = category.id;
      });
    }
  }

  Future<void> addCategory(String name, String type) async {
    final dbRef = FirebaseDatabase.instance.ref("$categoryApi/");
    final newCategory =
        CategoryModel(id: const Uuid().v4(), name: name, type: type);
    await dbRef.child(newCategory.id).set(newCategory.toJson());
    await fetchCategories();
  }
}