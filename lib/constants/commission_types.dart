/// Commission types used in the application
class CommissionTypes {
  // Commission type keys (8 actual types)
  static const String hematology = 'HEMATOLOGY';
  static const String biochemistry = 'BIOCHEMISTRY';
  static const String hormone = 'HORMONE';
  static const String serology = 'SEROLOGY';
  static const String immunology = 'IMMUNOLOGY';
  static const String radiology = 'RADIOLOGY';
  static const String imaging = 'IMAGING';
  static const String others = 'OTHERS';

  // Pathology group: Hematology, Biochemistry, Hormone, Serology, Immunology, Others
  static const List<String> pathologyGroup = [
    hematology,
    biochemistry,
    hormone,
    serology,
    immunology,
    others,
  ];

  // Radiology group: Radiology, Imaging
  static const List<String> radiologyGroup = [
    radiology,
    imaging,
  ];

  // All commission types
  static const List<String> allTypes = [
    hematology,
    biochemistry,
    hormone,
    serology,
    immunology,
    radiology,
    imaging,
    others,
  ];

  // Legacy constants (for backward compatibility only - not actual commission types)
  // These are groups, not individual types
  static const String pathology = 'PATHOLOGY'; // Group identifier
  static const String imagine = 'IMAGINE'; // Legacy typo - Group identifier

  // Map test category to specific commission type
  // Legacy category 1 (pathology) maps to HEMATOLOGY (first pathology type)
  // Legacy category 2 (radiology/imaging) maps to RADIOLOGY (first radiology type)
  static String? getCommissionTypeFromTestCategory(dynamic testCategory) {
    if (testCategory == null) return others;
    
    // If category is numeric (legacy system or new mapping)
    if (testCategory is int) {
      // Legacy mappings - map to actual types
      if (testCategory == 1) return hematology; // Legacy pathology -> HEMATOLOGY
      if (testCategory == 2) return radiology; // Legacy radiology/imaging -> RADIOLOGY
      
      // New numeric mappings
      if (testCategory == 3) return hematology;
      if (testCategory == 4) return biochemistry;
      if (testCategory == 5) return hormone;
      if (testCategory == 6) return serology;
      if (testCategory == 7) return immunology;
      if (testCategory == 8) return radiology;
      if (testCategory == 9) return imaging;
      if (testCategory == 10) return others;
      
      return others; // Default fallback for unknown numeric categories
    }
    
    // If category is string, normalize and return
    if (testCategory is String) {
      final upperCategory = testCategory.toUpperCase();
      
      // Legacy group mappings - map to actual types
      if (upperCategory == 'PATHOLOGY' || upperCategory == '1') {
        return hematology; // Map pathology group to first pathology type
      }
      if (upperCategory == 'RADIO/IMAGE' || upperCategory == '2' || upperCategory == 'IMAGINE') {
        return radiology; // Map radiology group to first radiology type
      }
      
      // Direct type mappings
      if (allTypes.contains(upperCategory)) {
        return upperCategory;
      }
    }
    
    return others; // Default fallback
  }

  // Check if a commission type belongs to pathology group
  static bool isPathologyType(String type) {
    return pathologyGroup.contains(type.toUpperCase());
  }

  // Check if a commission type belongs to radiology group
  static bool isRadiologyType(String type) {
    return radiologyGroup.contains(type.toUpperCase());
  }

  // Validate if a commission type is valid
  static bool isValidType(String type) {
    return allTypes.contains(type.toUpperCase());
  }

  // Normalize commission type string
  static String normalize(String type) {
    final normalized = type.toUpperCase();
    // Map legacy group identifiers to actual types
    if (normalized == pathology || normalized == '1') {
      return hematology;
    }
    if (normalized == imagine || normalized == '2') {
      return radiology;
    }
    return normalized;
  }
}

