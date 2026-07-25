import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../constants/api.dart';
import '../db/models/DoctorModel.dart';

/// Isolated doctor reference data. Does not touch Agent/referrer or request business logic.
class DoctorController extends GetxController {
  final doctors = <DoctorModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchDoctors() async {
    isLoading.value = true;
    try {
      final dbRef = FirebaseDatabase.instance.ref("$doctorApi/");
      final snapshot = await dbRef.get();
      doctors.clear();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          doctors.add(
            DoctorModel.fromJson(Map<String, dynamic>.from(value)),
          );
        });
        doctors.sort(
          (a, b) => a.name
              .toString()
              .toLowerCase()
              .compareTo(b.name.toString().toLowerCase()),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<DoctorModel> addDoctor(String name, String designation) async {
    final dbRef = FirebaseDatabase.instance.ref("$doctorApi/");
    final newDoctor = DoctorModel(
      id: const Uuid().v4(),
      name: name.trim(),
      designation: designation.trim(),
    );
    await dbRef.child(newDoctor.id).set(newDoctor.toJson());
    await fetchDoctors();
    return newDoctor;
  }

  List<DoctorModel> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<DoctorModel>.from(doctors);
    return doctors.where((doctor) {
      final name = doctor.name.toString().toLowerCase();
      final designation = doctor.designation?.toString().toLowerCase() ?? '';
      return name.contains(q) || designation.contains(q);
    }).toList();
  }
}
