import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/services/supplier_service.dart';
import 'package:ccpladmin/features/masters/presentation/providers/masters_providers.dart';

class AddNewSupplierScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editSupplier;
  const AddNewSupplierScreen({super.key, this.editSupplier});

  @override
  ConsumerState<AddNewSupplierScreen> createState() => _AddNewSupplierScreenState();
}

class _AddNewSupplierScreenState extends ConsumerState<AddNewSupplierScreen> with UIMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SupplierService _service = SupplierService();

  late TextEditingController supplierIdController;
  late TextEditingController supplierNameController;
  late TextEditingController shortNameController;
  
  late TextEditingController officeAddress1Controller;
  late TextEditingController officeAddress2Controller;
  late TextEditingController officeCityController;
  late TextEditingController officeStateController;
  late TextEditingController officePincodeController;

  late TextEditingController factoryAddress1Controller;
  late TextEditingController factoryAddress2Controller;
  late TextEditingController factoryCityController;
  late TextEditingController factoryStateController;
  late TextEditingController factoryPincodeController;

  late TextEditingController contactPersonController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  late FocusNode supplierIdFocusNode;
  late FocusNode supplierNameFocusNode;
  late FocusNode shortNameFocusNode;
  
  late FocusNode officeAddress1FocusNode;
  late FocusNode officeAddress2FocusNode;
  late FocusNode officeCityFocusNode;
  late FocusNode officeStateFocusNode;
  late FocusNode officePincodeFocusNode;

  late FocusNode factoryAddress1FocusNode;
  late FocusNode factoryAddress2FocusNode;
  late FocusNode factoryCityFocusNode;
  late FocusNode factoryStateFocusNode;
  late FocusNode factoryPincodeFocusNode;

  late FocusNode contactPersonFocusNode;
  late FocusNode phoneFocusNode;
  late FocusNode emailFocusNode;

  List<TextEditingController> machineCodeControllers = [];

  bool sameAsOfficeAddress = false;
  bool isSaveLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.editSupplier != null;

    supplierIdController = TextEditingController(text: widget.editSupplier?['supplierId'] ?? '');
    supplierNameController = TextEditingController(text: widget.editSupplier?['supplierName'] ?? '');
    shortNameController = TextEditingController(text: widget.editSupplier?['shortName'] ?? '');
    officeAddress1Controller = TextEditingController(text: widget.editSupplier?['officeAddressLine1'] ?? '');
    officeAddress2Controller = TextEditingController(text: widget.editSupplier?['officeAddressLine2'] ?? '');
    officeCityController = TextEditingController(text: widget.editSupplier?['officeCity'] ?? '');
    officeStateController = TextEditingController(text: widget.editSupplier?['officeState'] ?? '');
    officePincodeController = TextEditingController(text: widget.editSupplier?['officePincode'] ?? '');

    factoryAddress1Controller = TextEditingController(text: widget.editSupplier?['factoryAddressLine1'] ?? '');
    factoryAddress2Controller = TextEditingController(text: widget.editSupplier?['factoryAddressLine2'] ?? '');
    factoryCityController = TextEditingController(text: widget.editSupplier?['factoryCity'] ?? '');
    factoryStateController = TextEditingController(text: widget.editSupplier?['factoryState'] ?? '');
    factoryPincodeController = TextEditingController(text: widget.editSupplier?['factoryPincode'] ?? '');

    contactPersonController = TextEditingController(text: widget.editSupplier?['contactPerson'] ?? '');
    phoneController = TextEditingController(text: widget.editSupplier?['phone'] ?? '');
    emailController = TextEditingController(text: widget.editSupplier?['email'] ?? '');

    List<dynamic> machines = widget.editSupplier?['machineCodesList'] ?? [];
    if (machines.isNotEmpty) {
      for (var m in machines) {
        machineCodeControllers.add(TextEditingController(text: m.toString()));
      }
    } else {
      machineCodeControllers.add(TextEditingController());
    }

    supplierIdFocusNode = FocusNode();
    supplierNameFocusNode = FocusNode();
    shortNameFocusNode = FocusNode();
    officeAddress1FocusNode = FocusNode();
    officeAddress2FocusNode = FocusNode();
    officeCityFocusNode = FocusNode();
    officeStateFocusNode = FocusNode();
    officePincodeFocusNode = FocusNode();
    factoryAddress1FocusNode = FocusNode();
    factoryAddress2FocusNode = FocusNode();
    factoryCityFocusNode = FocusNode();
    factoryStateFocusNode = FocusNode();
    factoryPincodeFocusNode = FocusNode();
    contactPersonFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    supplierIdController.dispose();
    supplierNameController.dispose();
    shortNameController.dispose();
    officeAddress1Controller.dispose();
    officeAddress2Controller.dispose();
    officeCityController.dispose();
    officeStateController.dispose();
    officePincodeController.dispose();
    factoryAddress1Controller.dispose();
    factoryAddress2Controller.dispose();
    factoryCityController.dispose();
    factoryStateController.dispose();
    factoryPincodeController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    for (var controller in machineCodeControllers) {
      controller.dispose();
    }

    supplierIdFocusNode.dispose();
    supplierNameFocusNode.dispose();
    shortNameFocusNode.dispose();
    officeAddress1FocusNode.dispose();
    officeAddress2FocusNode.dispose();
    officeCityFocusNode.dispose();
    officeStateFocusNode.dispose();
    officePincodeFocusNode.dispose();
    factoryAddress1FocusNode.dispose();
    factoryAddress2FocusNode.dispose();
    factoryCityFocusNode.dispose();
    factoryStateFocusNode.dispose();
    factoryPincodeFocusNode.dispose();
    contactPersonFocusNode.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();

    super.dispose();
  }

  void updateFactoryAddress() {
    if (sameAsOfficeAddress) {
      setState(() {
        factoryAddress1Controller.text = officeAddress1Controller.text;
        factoryAddress2Controller.text = officeAddress2Controller.text;
        factoryCityController.text = officeCityController.text;
        factoryStateController.text = officeStateController.text;
        factoryPincodeController.text = officePincodeController.text;
      });
    }
  }

  void toggleSameAsOfficeAddress(bool? value) {
    setState(() {
      sameAsOfficeAddress = value ?? false;
      updateFactoryAddress();
    });
  }

  void addMachineCode() {
    setState(() {
      machineCodeControllers.add(TextEditingController());
    });
  }

  void removeMachineCode(int index) {
    setState(() {
      machineCodeControllers[index].dispose();
      machineCodeControllers.removeAt(index);
    });
  }

  Future<bool> saveSupplier() async {
    setState(() => isSaveLoading = true);
    try {
      final body = {
        'supplierid': supplierIdController.text,
        'suppliername': supplierNameController.text,
        'shortname': shortNameController.text,
        'officeaddressline1': officeAddress1Controller.text,
        'officeaddressline2': officeAddress2Controller.text,
        'officecity': officeCityController.text,
        'officestate': officeStateController.text,
        'officepincode': officePincodeController.text,
        'factoryaddressline1': factoryAddress1Controller.text,
        'factoryaddressline2': factoryAddress2Controller.text,
        'factorycity': factoryCityController.text,
        'factorystate': factoryStateController.text,
        'factorypincode': factoryPincodeController.text,
        'contactperson': contactPersonController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'machines': machineCodeControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      };

      dynamic response;
      if (isEditing) {
        response = await _service.updateSupplier(supplierIdController.text, body);
      } else {
        response = await _service.addSupplier(body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.read(supplierListProvider.notifier).fetchSuppliers();
        setState(() => isSaveLoading = false);
        return true;
      } else {
        Utils.showErrorToast("Failed to save: ${response.body}", context: context);
        setState(() => isSaveLoading = false);
        return false;
      }
    } catch (e) {
      Utils.showErrorToast("Network error: $e", context: context);
      setState(() => isSaveLoading = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  isEditing ? "Edit Supplier" : "Add New Supplier",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Masters'),
                    MyBreadcrumbItem(name: 'Suppliers', route: '/masters/suppliers'),
                    MyBreadcrumbItem(name: isEditing ? 'Edit' : 'Add New', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyCard(
              paddingAll: 24,
              borderRadiusAll: 8,
              shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium("Supplier Information", fontWeight: 600),
                  MySpacing.height(24),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelMedium("Basic Information", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: _buildTextField("Supplier Id", "Enter supplier id", supplierIdController, enabled: !isEditing, focusNode: supplierIdFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(supplierNameFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Supplier Name", "Enter supplier name", supplierNameController, focusNode: supplierNameFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(shortNameFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Short Name", "Enter short name", shortNameController, focusNode: shortNameFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(officeAddress1FocusNode))),
            ],
          ),
          MySpacing.height(24),

          MyText.labelMedium("Office Address", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: _buildTextField("Office Address Line 1", "Enter address line 1", officeAddress1Controller, onChanged: (_) => updateFactoryAddress(), focusNode: officeAddress1FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(officeAddress2FocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Office Address Line 2", "Enter address line 2", officeAddress2Controller, onChanged: (_) => updateFactoryAddress(), isRequired: false, focusNode: officeAddress2FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(officeCityFocusNode))),
            ],
          ),
          MySpacing.height(16),
          Row(
            children: [
              Expanded(child: _buildTextField("Office City", "Enter city", officeCityController, onChanged: (_) => updateFactoryAddress(), focusNode: officeCityFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(officeStateFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Office State", "Enter state", officeStateController, onChanged: (_) => updateFactoryAddress(), focusNode: officeStateFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(officePincodeFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Office Pincode", "Enter pincode", officePincodeController, onChanged: (_) => updateFactoryAddress(), focusNode: officePincodeFocusNode, onFieldSubmitted: (_) {
                if (sameAsOfficeAddress) {
                  FocusScope.of(context).requestFocus(contactPersonFocusNode);
                } else {
                  FocusScope.of(context).requestFocus(factoryAddress1FocusNode);
                }
              })),
            ],
          ),
          MySpacing.height(24),

          Row(
            children: [
              MyText.labelMedium("Factory Address", fontWeight: 600, color: contentTheme.onBackground),
              MySpacing.width(24),
              _buildCheckbox("Same as Office Address", sameAsOfficeAddress, toggleSameAsOfficeAddress),
            ],
          ),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: _buildTextField("Factory Address Line 1", "Enter address line 1", factoryAddress1Controller, enabled: !sameAsOfficeAddress, focusNode: factoryAddress1FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(factoryAddress2FocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Factory Address Line 2", "Enter address line 2", factoryAddress2Controller, isRequired: false, enabled: !sameAsOfficeAddress, focusNode: factoryAddress2FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(factoryCityFocusNode))),
            ],
          ),
          MySpacing.height(16),
          Row(
            children: [
              Expanded(child: _buildTextField("Factory City", "Enter city", factoryCityController, enabled: !sameAsOfficeAddress, focusNode: factoryCityFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(factoryStateFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Factory State", "Enter state", factoryStateController, enabled: !sameAsOfficeAddress, focusNode: factoryStateFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(factoryPincodeFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Factory Pincode", "Enter pincode", factoryPincodeController, enabled: !sameAsOfficeAddress, focusNode: factoryPincodeFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(contactPersonFocusNode))),
            ],
          ),
          MySpacing.height(24),

          MyText.labelMedium("Contact Information", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: _buildTextField("Contact Person", "Enter contact person", contactPersonController, focusNode: contactPersonFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Phone", "Enter phone number", phoneController, focusNode: phoneFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Email", "Enter email address", emailController, focusNode: emailFocusNode, textInputAction: TextInputAction.done, onFieldSubmitted: (_) async {
                if (_formKey.currentState!.validate()) {
                  bool success = await saveSupplier();
                  if (success) {
                    Get.back(result: true);
                  }
                }
              })),
            ],
          ),
          MySpacing.height(24),

          MyText.labelMedium("Machine Codes", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          ...machineCodeControllers.asMap().entries.map((entry) {
            int index = entry.key;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 250,
                  child: _buildTextField("Machine Code ${index + 1}", "Enter machine code", entry.value, isRequired: false),
                ),
                if (machineCodeControllers.length > 1) ...[
                  MySpacing.width(12),
                  Padding(
                    padding: MySpacing.bottom(4),
                    child: IconButton(
                      onPressed: () => removeMachineCode(index),
                      icon: const Icon(LucideIcons.trash_2, color: Colors.red, size: 20),
                    ),
                  ),
                ]
              ],
            );
          }),
          MySpacing.height(12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: addMachineCode,
              icon: Icon(LucideIcons.plus, size: 16, color: contentTheme.primary),
              label: MyText.labelMedium("Add Machine Code", color: contentTheme.primary, fontWeight: 600),
              style: TextButton.styleFrom(padding: MySpacing.xy(8, 8)),
            ),
          ),
          MySpacing.height(24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: MySpacing.xy(20, 16),
                  side: BorderSide(color: contentTheme.onBackground.withAlpha(20)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: MyText.bodySmall("Cancel", color: contentTheme.onBackground),
              ),
              MySpacing.width(16),
              ElevatedButton(
                onPressed: isSaveLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await saveSupplier();
                    if (success) {
                      Get.back(result: true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  padding: MySpacing.xy(20, 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isSaveLoading 
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: contentTheme.onPrimary))
                  : MyText.bodySmall("Save Supplier", color: contentTheme.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    Function(String)? onChanged,
    bool isRequired = true,
    bool enabled = true,
    FocusNode? focusNode,
    TextInputAction? textInputAction = TextInputAction.next,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 500, color: contentTheme.onBackground),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return "$label is required";
            }
            return null;
          },
          style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: contentTheme.onBackground.withAlpha(enabled ? 150 : 100)),
            filled: true,
            fillColor: enabled ? contentTheme.background.withAlpha(50) : contentTheme.background.withAlpha(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.onBackground.withAlpha(20)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.primary.withAlpha(100)),
            ),
            contentPadding: MySpacing.all(12),
            isCollapsed: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: value ? contentTheme.primary : Colors.transparent,
              border: Border.all(
                color: value ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                : null,
          ),
          MySpacing.width(8),
          MyText.bodyMedium(label, fontWeight: 600),
        ],
      ),
    );
  }
}
