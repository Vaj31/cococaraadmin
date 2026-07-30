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
import 'package:ccpladmin/services/customer_service.dart';
import 'package:ccpladmin/features/masters/presentation/providers/masters_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editCustomer;
  const AddCustomerScreen({super.key, this.editCustomer});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> with UIMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController customerNameController;
  late TextEditingController contactPersonController;
  late TextEditingController emailController;
  late TextEditingController mobileNo1Controller;
  late TextEditingController mobileNo2Controller;
  late TextEditingController mobileNo3Controller;
  late TextEditingController phoneNo1Controller;
  late TextEditingController phoneNo2Controller;
  
  late TextEditingController billingAddressController;
  late TextEditingController billingZipcodeController;
  
  late TextEditingController shippingAddressController;
  late TextEditingController shippingZipcodeController;

  late FocusNode customerNameFocusNode;
  late FocusNode contactPersonFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode mobileNo1FocusNode;
  late FocusNode mobileNo2FocusNode;
  late FocusNode mobileNo3FocusNode;
  late FocusNode phoneNo1FocusNode;
  late FocusNode phoneNo2FocusNode;
  late FocusNode billingAddressFocusNode;
  late FocusNode billingZipcodeFocusNode;
  late FocusNode shippingAddressFocusNode;
  late FocusNode shippingZipcodeFocusNode;

  bool sameAsBillingAddress = false;
  bool isSaveLoading = false;
  bool isEditing = false;
  int? editingCustomerId;

  @override
  void initState() {
    super.initState();
    isEditing = widget.editCustomer != null;
    editingCustomerId = widget.editCustomer?['seqnum'];

    customerNameController = TextEditingController(text: widget.editCustomer?['customername'] ?? '');
    contactPersonController = TextEditingController(text: widget.editCustomer?['contactperson'] ?? '');
    emailController = TextEditingController(text: widget.editCustomer?['email'] ?? '');
    mobileNo1Controller = TextEditingController(text: widget.editCustomer?['mobileno1'] ?? '');
    mobileNo2Controller = TextEditingController(text: widget.editCustomer?['mobileno2'] ?? '');
    mobileNo3Controller = TextEditingController(text: widget.editCustomer?['mobileno3'] ?? '');
    phoneNo1Controller = TextEditingController(text: widget.editCustomer?['phoneno1'] ?? '');
    phoneNo2Controller = TextEditingController(text: widget.editCustomer?['phoneno2'] ?? '');
    billingAddressController = TextEditingController(text: widget.editCustomer?['billingaddress'] ?? '');
    billingZipcodeController = TextEditingController(text: widget.editCustomer?['billingzipcode'] ?? '');
    shippingAddressController = TextEditingController(text: widget.editCustomer?['shippingaddress'] ?? '');
    shippingZipcodeController = TextEditingController(text: widget.editCustomer?['shippingzipcode'] ?? '');

    sameAsBillingAddress = widget.editCustomer?['sameasbillingaddress'] == 1 || widget.editCustomer?['sameasbillingaddress'] == true;

    customerNameFocusNode = FocusNode();
    contactPersonFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    mobileNo1FocusNode = FocusNode();
    mobileNo2FocusNode = FocusNode();
    mobileNo3FocusNode = FocusNode();
    phoneNo1FocusNode = FocusNode();
    phoneNo2FocusNode = FocusNode();
    billingAddressFocusNode = FocusNode();
    billingZipcodeFocusNode = FocusNode();
    shippingAddressFocusNode = FocusNode();
    shippingZipcodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    mobileNo1Controller.dispose();
    mobileNo2Controller.dispose();
    mobileNo3Controller.dispose();
    phoneNo1Controller.dispose();
    phoneNo2Controller.dispose();
    billingAddressController.dispose();
    billingZipcodeController.dispose();
    shippingAddressController.dispose();
    shippingZipcodeController.dispose();

    customerNameFocusNode.dispose();
    contactPersonFocusNode.dispose();
    emailFocusNode.dispose();
    mobileNo1FocusNode.dispose();
    mobileNo2FocusNode.dispose();
    mobileNo3FocusNode.dispose();
    phoneNo1FocusNode.dispose();
    phoneNo2FocusNode.dispose();
    billingAddressFocusNode.dispose();
    billingZipcodeFocusNode.dispose();
    shippingAddressFocusNode.dispose();
    shippingZipcodeFocusNode.dispose();

    super.dispose();
  }

  void toggleSameAsBillingAddress(bool? value) {
    if (value != null) {
      setState(() {
        sameAsBillingAddress = value;
        if (sameAsBillingAddress) {
          shippingAddressController.text = billingAddressController.text;
          shippingZipcodeController.text = billingZipcodeController.text;
        } else {
          shippingAddressController.clear();
          shippingZipcodeController.clear();
        }
      });
    }
  }

  void updateShippingAddress() {
    if (sameAsBillingAddress) {
      setState(() {
        shippingAddressController.text = billingAddressController.text;
        shippingZipcodeController.text = billingZipcodeController.text;
      });
    }
  }

  Future<bool> saveCustomer() async {
    setState(() => isSaveLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      Map<String, dynamic> customerData = {
        "customername": customerNameController.text,
        "contactperson": contactPersonController.text,
        "email": emailController.text,
        "mobileno1": mobileNo1Controller.text,
        "mobileno2": mobileNo2Controller.text,
        "mobileno3": mobileNo3Controller.text,
        "phoneno1": phoneNo1Controller.text,
        "phoneno2": phoneNo2Controller.text,
        "billingaddress": billingAddressController.text,
        "billingzipcode": billingZipcodeController.text,
        "shippingaddress": shippingAddressController.text,
        "shippingzipcode": shippingZipcodeController.text,
        "sameasbillingaddress": sameAsBillingAddress ? 1 : 0,
      };

      if (isEditing && editingCustomerId != null) {
        await CustomerService.updateCustomer(editingCustomerId!, customerData);
      } else {
        await CustomerService.createCustomer(customerData);
      }

      ref.read(customerListProvider.notifier).fetchCustomers();
      setState(() => isSaveLoading = false);
      return true;
    } catch (e) {
      setState(() => isSaveLoading = false);
      Utils.showErrorToast("Failed to save customer: $e", context: context);
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
                  isEditing ? "Edit Customer" : "Add New Customer",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Masters'),
                    MyBreadcrumbItem(name: 'Customers', route: '/masters/customers'),
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
                  MyText.bodyMedium("Customer Information", fontWeight: 600),
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
              Expanded(child: _buildTextField("Customer Name", "Enter customer name", customerNameController, focusNode: customerNameFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(contactPersonFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Contact Person", "Enter contact person", contactPersonController, isRequired: false, focusNode: contactPersonFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(emailFocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Email", "Enter email address", emailController, isRequired: false, focusNode: emailFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(mobileNo1FocusNode))),
            ],
          ),
          MySpacing.height(24),

          MyText.labelMedium("Contact Numbers", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: _buildTextField("Mobile No 1", "Enter mobile number 1", mobileNo1Controller, isRequired: false, focusNode: mobileNo1FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(mobileNo2FocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Mobile No 2", "Enter mobile number 2", mobileNo2Controller, isRequired: false, focusNode: mobileNo2FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(mobileNo3FocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Mobile No 3", "Enter mobile number 3", mobileNo3Controller, isRequired: false, focusNode: mobileNo3FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneNo1FocusNode))),
            ],
          ),
          MySpacing.height(16),
          Row(
            children: [
              Expanded(child: _buildTextField("Phone No 1", "Enter phone number 1", phoneNo1Controller, isRequired: false, focusNode: phoneNo1FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(phoneNo2FocusNode))),
              MySpacing.width(16),
              Expanded(child: _buildTextField("Phone No 2", "Enter phone number 2", phoneNo2Controller, isRequired: false, focusNode: phoneNo2FocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(billingAddressFocusNode))),
              MySpacing.width(16),
              const Expanded(child: SizedBox()), 
            ],
          ),
          MySpacing.height(24),

          MyText.labelMedium("Billing Address", fontWeight: 600, color: contentTheme.onBackground),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(flex: 2, child: _buildTextField("Billing Address", "Enter billing address", billingAddressController, onChanged: (_) => updateShippingAddress(), isRequired: false, focusNode: billingAddressFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(billingZipcodeFocusNode))),
              MySpacing.width(16),
              Expanded(flex: 1, child: _buildTextField("Billing Zipcode", "Enter zip code", billingZipcodeController, onChanged: (_) => updateShippingAddress(), isRequired: false, focusNode: billingZipcodeFocusNode, onFieldSubmitted: (_) {
                if (sameAsBillingAddress) {
                  FocusScope.of(context).unfocus();
                } else {
                  FocusScope.of(context).requestFocus(shippingAddressFocusNode);
                }
              })),
            ],
          ),
          MySpacing.height(24),

          Row(
            children: [
              MyText.labelMedium("Shipping Address", fontWeight: 600, color: contentTheme.onBackground),
              MySpacing.width(24),
              _buildCheckbox("Same as Billing Address", sameAsBillingAddress, toggleSameAsBillingAddress),
            ],
          ),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(flex: 2, child: _buildTextField("Shipping Address", "Enter shipping address", shippingAddressController, isRequired: false, enabled: !sameAsBillingAddress, focusNode: shippingAddressFocusNode, onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(shippingZipcodeFocusNode))),
              MySpacing.width(16),
              Expanded(flex: 1, child: _buildTextField("Shipping Zipcode", "Enter zip code", shippingZipcodeController, isRequired: false, enabled: !sameAsBillingAddress, focusNode: shippingZipcodeFocusNode, textInputAction: TextInputAction.done, onFieldSubmitted: (_) async {
                if (_formKey.currentState!.validate()) {
                  bool success = await saveCustomer();
                  if (success) {
                    Get.back(result: true);
                  }
                }
              })),
            ],
          ),
          MySpacing.height(32),

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
                    bool success = await saveCustomer();
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
                  : MyText.bodySmall("Save Customer", color: contentTheme.onPrimary),
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
