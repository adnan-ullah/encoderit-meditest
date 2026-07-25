import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthcare_homelab/constants/colors.dart';
import 'package:healthcare_homelab/db/models/DoctorModel.dart';
import 'package:healthcare_homelab/responsives/dimensions.dart';
import 'package:healthcare_homelab/state_programming/DoctorController.dart';

/// Self-contained "Ref By" doctor picker. Isolated from Agent/referrer logic.
class RefByDoctorField extends StatefulWidget {
  const RefByDoctorField({
    super.key,
    this.initialDoctorId,
    this.initialDoctorName,
    this.initialDoctorDesignation,
    required this.onChanged,
    this.readOnly = false,
  });

  final String? initialDoctorId;
  final String? initialDoctorName;
  final String? initialDoctorDesignation;
  final void Function(
    String? doctorId,
    String? doctorName,
    String? doctorDesignation,
  ) onChanged;
  final bool readOnly;

  @override
  State<RefByDoctorField> createState() => RefByDoctorFieldState();
}

class RefByDoctorFieldState extends State<RefByDoctorField> {
  late final DoctorController _doctorController;
  String? _selectedId;
  String? _selectedName;
  String? _selectedDesignation;
  bool _showError = false;

  /// Call on submit only. Returns true when a doctor is selected.
  bool validate() {
    final isValid =
        _selectedId != null && _selectedId!.trim().isNotEmpty;
    setState(() => _showError = !isValid);
    return isValid;
  }

  @override
  void initState() {
    super.initState();
    _doctorController = Get.isRegistered<DoctorController>()
        ? Get.find<DoctorController>()
        : Get.put(DoctorController());
    _selectedId = widget.initialDoctorId;
    _selectedName = widget.initialDoctorName;
    _selectedDesignation = widget.initialDoctorDesignation;
    _doctorController.fetchDoctors();
  }

  @override
  void didUpdateWidget(covariant RefByDoctorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDoctorId != widget.initialDoctorId ||
        oldWidget.initialDoctorName != widget.initialDoctorName ||
        oldWidget.initialDoctorDesignation !=
            widget.initialDoctorDesignation) {
      _selectedId = widget.initialDoctorId;
      _selectedName = widget.initialDoctorName;
      _selectedDesignation = widget.initialDoctorDesignation;
    }
  }

  void _applySelection(DoctorModel? doctor) {
    setState(() {
      _selectedId = doctor?.id?.toString();
      _selectedName = doctor?.name?.toString();
      _selectedDesignation = doctor?.designation?.toString();
      _showError = false;
    });
    widget.onChanged(_selectedId, _selectedName, _selectedDesignation);
  }

  Future<void> _openDoctorPicker() async {
    if (widget.readOnly) return;
    if (_doctorController.doctors.isEmpty) {
      await _doctorController.fetchDoctors();
    }

    final DoctorModel? selected = await showDialog<DoctorModel>(
      context: context,
      builder: (_) => _DoctorSearchDialog(
        doctorController: _doctorController,
      ),
    );

    if (selected != null) {
      _applySelection(selected);
    }
  }

  void _showAddDoctorDialog() {
    if (widget.readOnly) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final designationController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: DM.p28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DM.p24),
              ),
              clipBehavior: Clip.antiAlias,
              child: ColoredBox(
                color: Colors.white,
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        DM.p22,
                        DM.p22,
                        DM.p14,
                        DM.p20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appTheme,
                            appTheme.withValues(alpha: .78),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: DM.p48,
                            height: DM.p48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .22),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: DM.p25,
                            ),
                          ),
                          SizedBox(width: DM.p14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Doctor',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: DM.p21,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: DM.p3),
                                Text(
                                  'Enter doctor information below',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .88),
                                    fontSize: DM.p12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(DM.p22),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _doctorInputDecoration(
                                label: 'Doctor Name',
                                hint: 'e.g. Dr. Rahman',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Doctor name is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: DM.p16),
                            TextFormField(
                              controller: designationController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _doctorInputDecoration(
                                label: 'Designation',
                                hint: 'e.g. MBBS, FCPS',
                                icon: Icons.workspace_premium_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Designation is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: DM.p22),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isSaving
                                        ? null
                                        : () => Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: appTheme,
                                      side: BorderSide(color: appTheme),
                                      padding: EdgeInsets.symmetric(
                                        vertical: DM.p13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(DM.p12),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                SizedBox(width: DM.p12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: isSaving
                                        ? null
                                        : () async {
                                            if (!formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            setDialogState(
                                                () => isSaving = true);
                                            try {
                                              final doctor =
                                                  await _doctorController
                                                      .addDoctor(
                                                nameController.text,
                                                designationController.text,
                                              );
                                              if (mounted) {
                                                Navigator.pop(dialogContext);
                                                _applySelection(doctor);
                                              }
                                            } catch (_) {
                                              setDialogState(
                                                  () => isSaving = false);
                                              Get.snackbar(
                                                'Error',
                                                'Failed to add doctor',
                                                backgroundColor: redColor,
                                                colorText: whiteColor,
                                              );
                                            }
                                          },
                                    icon: isSaving
                                        ? SizedBox(
                                            width: DM.p17,
                                            height: DM.p17,
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_circle_outline_rounded),
                                    label: Text(
                                      isSaving ? 'Saving...' : 'Add Doctor',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: appTheme,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: DM.p13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(DM.p12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _doctorInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: appTheme),
      filled: true,
      fillColor: appTheme.withValues(alpha: .06),
      labelStyle: TextStyle(color: appTheme),
      contentPadding: EdgeInsets.symmetric(
        horizontal: DM.p14,
        vertical: DM.p15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DM.p12),
        borderSide: BorderSide(color: appTheme.withValues(alpha: .35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DM.p12),
        borderSide: BorderSide(color: appTheme, width: DM.p2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DM.p12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DM.p12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedName != null && _selectedName!.isNotEmpty;
    final designation = _selectedDesignation?.trim() ?? '';
    final displayText = !hasSelection
        ? 'Select doctor'
        : designation.isEmpty
            ? _selectedName!
            : '${_selectedName!} ($designation)';

    return Padding(
      padding: EdgeInsets.all(DM.p1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: DM.p100,
                child: Text(
                  'Ref By',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: DM.p14,
                    color: blackFontColor,
                  ),
                ),
              ),
              SizedBox(width: DM.p5),
              const Text(':'),
              SizedBox(width: DM.p10),
              Expanded(
                child: InkWell(
                  onTap: widget.readOnly ? null : _openDoctorPicker,
                  child: Container(
                    height: DM.p42,
                    padding: EdgeInsets.symmetric(horizontal: DM.p10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: _showError ? Colors.red : appTheme,
                        width: _showError ? DM.p2 : DM.p1,
                      ),
                      borderRadius: BorderRadius.circular(DM.p4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: DM.p14,
                              color: hasSelection
                                  ? blackFontColor
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: appTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: DM.p8),
              MaterialButton(
                onPressed: widget.readOnly ? null : _showAddDoctorDialog,
                minWidth: DM.p42,
                height: DM.p42,
                padding: EdgeInsets.zero,
                color: appTheme,
                disabledColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DM.p8),
                ),
                child: Icon(
                  Icons.add,
                  color: fullWhiteColor,
                ),
              ),
            ],
          ),
          if (_showError)
            Padding(
              padding: EdgeInsets.only(
                left: DM.p120,
                top: DM.p4,
              ),
              child: Text(
                'Ref By is required',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: DM.p10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DoctorSearchDialog extends StatefulWidget {
  const _DoctorSearchDialog({required this.doctorController});

  final DoctorController doctorController;

  @override
  State<_DoctorSearchDialog> createState() => _DoctorSearchDialogState();
}

class _DoctorSearchDialogState extends State<_DoctorSearchDialog> {
  final _searchController = TextEditingController();
  late List<DoctorModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List<DoctorModel>.from(widget.doctorController.doctors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: DM.p20,
        vertical: DM.p24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DM.p24),
      ),
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox(
          width: double.maxFinite,
          height: DM.p680,
          child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                DM.p20,
                DM.p18,
                DM.p10,
                DM.p18,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appTheme, appTheme.withValues(alpha: .78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: DM.p46,
                    height: DM.p46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                      size: DM.p24,
                    ),
                  ),
                  SizedBox(width: DM.p13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Doctor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: DM.p21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: DM.p2),
                        Text(
                          '${_filtered.length} doctor${_filtered.length == 1 ? '' : 's'} available',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .88),
                            fontSize: DM.p12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                DM.p18,
                DM.p18,
                DM.p18,
                DM.p10,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _filtered = widget.doctorController.search(value);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or designation',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: DM.p13,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: appTheme),
                  filled: true,
                  fillColor: appTheme.withValues(alpha: .06),
                  contentPadding: EdgeInsets.symmetric(vertical: DM.p14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DM.p14),
                    borderSide: BorderSide(
                      color: appTheme.withValues(alpha: .3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DM.p14),
                    borderSide: BorderSide(color: appTheme, width: DM.p2),
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filtered = List<DoctorModel>.from(
                                widget.doctorController.doctors,
                              );
                            });
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (widget.doctorController.isLoading.value &&
                    _filtered.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: appTheme),
                  );
                }
                if (_filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(DM.p18),
                          decoration: BoxDecoration(
                            color: appTheme.withValues(alpha: .08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_search_outlined,
                            color: appTheme,
                            size: DM.p36,
                          ),
                        ),
                        SizedBox(height: DM.p12),
                        Text(
                          'No doctor found',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: DM.p16,
                          ),
                        ),
                        SizedBox(height: DM.p4),
                        Text(
                          'Try a different name or designation',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: DM.p12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    DM.p14,
                    DM.p4,
                    DM.p14,
                    DM.p16,
                  ),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: DM.p8),
                  itemBuilder: (context, index) {
                    final doctor = _filtered[index];
                    return Material(
                      color: appTheme.withValues(alpha: .055),
                      borderRadius: BorderRadius.circular(DM.p14),
                      child: InkWell(
                        onTap: () => Navigator.pop(context, doctor),
                        borderRadius: BorderRadius.circular(DM.p14),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DM.p13,
                            vertical: DM.p11,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: appTheme.withValues(alpha: .18),
                            ),
                            borderRadius: BorderRadius.circular(DM.p14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: DM.p22,
                                backgroundColor: appTheme,
                                child: Text(
                                  _doctorInitials(doctor.name.toString()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: DM.p13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: DM.p12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: DM.p15,
                                        fontWeight: FontWeight.w600,
                                        color: blackFontColor,
                                      ),
                                    ),
                                    SizedBox(height: DM.p3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.workspace_premium_outlined,
                                          size: DM.p14,
                                          color: appTheme,
                                        ),
                                        SizedBox(width: DM.p4),
                                        Expanded(
                                          child: Text(
                                            doctor.designation?.toString() ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: DM.p12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: DM.p32,
                                height: DM.p32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: appTheme.withValues(alpha: .25),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: DM.p13,
                                  color: appTheme,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _doctorInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
