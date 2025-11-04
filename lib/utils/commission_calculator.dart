import '../constants/commission_types.dart';
import '../db/models/AdminUserModel.dart';
import '../db/models/TestData.dart';

/// Helper class for calculating commissions dynamically
class CommissionCalculator {
  /// Calculate total payable amount by commission type from a list of tests
  static Map<String, int> calculatePayableByType(List<TestData> testList) {
    final Map<String, int> payableAmounts = {};

    for (final test in testList) {
      if (test.is_payable == null) {
        continue;
      }

      final testPrice = int.tryParse(test.testprice.toString()) ?? 0;
      final testDiscount = int.tryParse(test.discount.toString()) ?? 0;
      final payableAmount = testPrice - testDiscount;

      if (test.is_payable == true) {
        final commissionType = CommissionTypes.getCommissionTypeFromTestCategory(test.category);
        final type = commissionType ?? CommissionTypes.others;
        
        payableAmounts[type] = (payableAmounts[type] ?? 0) + payableAmount;
      }
    }

    return payableAmounts;
  }

  /// Calculate total unpayable amount by commission type from a list of tests
  static Map<String, int> calculateUnpayableByType(List<TestData> testList) {
    final Map<String, int> unpayableAmounts = {};

    for (final test in testList) {
      if (test.is_payable == null || test.is_payable == true) {
        continue;
      }

      final testPrice = int.tryParse(test.testprice.toString()) ?? 0;
      final testDiscount = int.tryParse(test.discount.toString()) ?? 0;
      final unpayableAmount = testPrice - testDiscount;

      final commissionType = CommissionTypes.getCommissionTypeFromTestCategory(test.category);
      final type = commissionType ?? CommissionTypes.others;
      
      unpayableAmounts[type] = (unpayableAmounts[type] ?? 0) + unpayableAmount;
    }

    return unpayableAmounts;
  }

  /// Calculate agent commission based on payable amounts and user commissions
  static int calculateAgentCommission({
    required Map<String, int> payableByType,
    required AdminUserModel adminUser,
  }) {
    int totalCommission = 0;

    payableByType.forEach((commissionType, payableAmount) {
      final commissionPercent = int.tryParse(adminUser.getCommission(commissionType)?.toString() ?? '0') ?? 0;
      final commissionAmount = (payableAmount * commissionPercent) ~/ 100;
      totalCommission += commissionAmount;
    });

    return totalCommission;
  }

  /// Calculate assigning commission for a specific type
  static int calculateAssigningCommission({
    required String commissionType,
    required int payableAmount,
    required AdminUserModel adminUser,
  }) {
    final commissionPercent = int.tryParse(adminUser.getCommission(commissionType)?.toString() ?? '0') ?? 0;
    return (payableAmount * commissionPercent) ~/ 100;
  }

  /// Calculate all assigning commissions by type
  static Map<String, int> calculateAllAssigningCommissions({
    required Map<String, int> payableByType,
    required AdminUserModel adminUser,
  }) {
    final Map<String, int> commissions = {};

    payableByType.forEach((commissionType, payableAmount) {
      commissions[commissionType] = calculateAssigningCommission(
        commissionType: commissionType,
        payableAmount: payableAmount,
        adminUser: adminUser,
      );
    });

    return commissions;
  }

  /// Legacy method: Calculate pathology commission (backward compatibility)
  static int calculatePathologyCommission({
    required int payablePathologyAmount,
    required AdminUserModel adminUser,
  }) {
    return calculateAssigningCommission(
      commissionType: CommissionTypes.pathology,
      payableAmount: payablePathologyAmount,
      adminUser: adminUser,
    );
  }

  /// Legacy method: Calculate imaging commission (backward compatibility)
  static int calculateImagingCommission({
    required int payableImagingAmount,
    required AdminUserModel adminUser,
  }) {
    return calculateAssigningCommission(
      commissionType: CommissionTypes.imaging,
      payableAmount: payableImagingAmount,
      adminUser: adminUser,
    );
  }

  /// Get commission for a specific type as integer
  static int getCommissionValue(AdminUserModel adminUser, String commissionType) {
    return int.tryParse(adminUser.getCommission(commissionType)?.toString() ?? '0') ?? 0;
  }

  /// Calculate pathology assigning commission (sum of: Hematology, Biochemistry, Hormone, Serology, Immunology, Others, Pathology)
  static int calculatePathologyAssigningCommission({
    required Map<String, int> payableByType,
    required AdminUserModel adminUser,
  }) {
    int totalCommission = 0;
    
    // List of commission types that belong to pathology
    final pathologyTypes = [
      CommissionTypes.hematology,
      CommissionTypes.biochemistry,
      CommissionTypes.hormone,
      CommissionTypes.serology,
      CommissionTypes.immunology,
      CommissionTypes.others,
      CommissionTypes.pathology, // Include for backward compatibility
    ];

    for (final commissionType in pathologyTypes) {
      final payableAmount = payableByType[commissionType] ?? 0;
      if (payableAmount > 0) {
        final commission = calculateAssigningCommission(
          commissionType: commissionType,
          payableAmount: payableAmount,
          adminUser: adminUser,
        );
        totalCommission += commission;
      }
    }

    return totalCommission;
  }

  /// Calculate radiology assigning commission (sum of: Radiology and Imaging)
  static int calculateRadiologyAssigningCommission({
    required Map<String, int> payableByType,
    required AdminUserModel adminUser,
  }) {
    int totalCommission = 0;
    
    // List of commission types that belong to radiology
    final radiologyTypes = [
      CommissionTypes.radiology,
      CommissionTypes.imaging,
    ];

    for (final commissionType in radiologyTypes) {
      final payableAmount = payableByType[commissionType] ?? 0;
      if (payableAmount > 0) {
        final commission = calculateAssigningCommission(
          commissionType: commissionType,
          payableAmount: payableAmount,
          adminUser: adminUser,
        );
        totalCommission += commission;
      }
    }

    return totalCommission;
  }
}

