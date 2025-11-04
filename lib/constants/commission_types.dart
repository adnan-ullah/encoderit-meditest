/// Commission types used in the application
class CommissionTypes {
  // Commission type keys
  static const String hematology = 'HEMATOLOGY';
  static const String biochemistry = 'BIOCHEMISTRY';
  static const String hormone = 'HORMONE';
  static const String serology = 'SEROLOGY';
  static const String immunology = 'IMMUNOLOGY';
  static const String radiology = 'RADIOLOGY';
  static const String imaging = 'IMAGING';
  static const String others = 'OTHERS';

  // Legacy commission types (for backward compatibility)
  static const String pathology = 'PATHOLOGY';
  static const String imagine = 'IMAGINE'; // Note: keeping typo for backward compatibility

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

  // Legacy mapping: old category values to new commission types
  // category 1 -> PATHOLOGY (which maps to multiple subtypes)
  // category 2 -> RADIO/IMAGE (which maps to RADIOLOGY/IMAGING)
  static String? getCommissionTypeFromCategory(int? category) {
    switch (category) {
      case 1:
        return pathology; // Legacy pathology category
      case 2:
        return imaging; // Legacy imaging/radiology category
      default:
        return null;
    }
  }

  // Map test category to specific commission type
  // This can be extended based on your test categorization logic
  static String? getCommissionTypeFromTestCategory(dynamic testCategory) {
    if (testCategory == null) return others;
    
    // If category is numeric (legacy system or new mapping)
    if (testCategory is int) {
      // Legacy mappings (1 = PATHOLOGY, 2 = RADIO/IMAGE/IMAGING)
      if (testCategory == 1) return pathology;
      if (testCategory == 2) return imaging;
      
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
      
      // Legacy mappings
      if (upperCategory == 'PATHOLOGY' || upperCategory == '1') return pathology;
      if (upperCategory == 'RADIO/IMAGE' || upperCategory == 'RADIOLOGY' || upperCategory == '2') {
        return imaging;
      }
      
      // New type mappings - direct match
      if (allTypes.contains(upperCategory)) {
        return upperCategory;
      }
    }
    
    return others; // Default fallback
  }

  // Validate if a commission type is valid
  static bool isValidType(String type) {
    return allTypes.contains(type.toUpperCase()) || 
           type.toUpperCase() == pathology || 
           type.toUpperCase() == imagine;
  }

  // Normalize commission type string
  static String normalize(String type) {
    return type.toUpperCase();
  }
}

