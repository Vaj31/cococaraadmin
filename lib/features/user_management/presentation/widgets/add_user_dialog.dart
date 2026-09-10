import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class RoleOption {
  final String title;
  final Color dotColor;

  const RoleOption({required this.title, required this.dotColor});
}

class DataScopeOption {
  final String title;
  final IconData icon;

  const DataScopeOption({required this.title, required this.icon});
}

class NewUserData {
  final String name;
  final String email;
  final String phone;
  final String department;
  final String role;
  final Color roleColor;
  final String dataScope;
  final String team;
  final String reportsTo;
  final bool sendInviteEmail;

  NewUserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.role,
    required this.roleColor,
    required this.dataScope,
    required this.team,
    required this.reportsTo,
    required this.sendInviteEmail,
  });
}

class AddUserDialog extends StatefulWidget {
  final List<String> existingManagers;
  final Function(NewUserData) onUserCreated;

  const AddUserDialog({
    super.key,
    required this.onUserCreated,
    this.existingManagers = const [],
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> with UIMixin {
  int _currentStep = 0; // 0: Profile, 1: Role & Access, 2: Review

  // Form Controllers
  final _formKeyProfile = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController(text: "Sales");
  bool _sendInvitationEmail = true;

  // Step 2 selections
  static const List<RoleOption> _roleOptions = [
    RoleOption(title: "Admin", dotColor: Color(0xff8b5cf6)),
    RoleOption(title: "Manager", dotColor: Color(0xff3b82f6)),
    RoleOption(title: "Sales Executive", dotColor: Color(0xff10b981)),
    RoleOption(title: "Operations", dotColor: Color(0xff06b6d4)),
    RoleOption(title: "Finance", dotColor: Color(0xffd97706)),
    RoleOption(title: "Creative Director", dotColor: Color(0xff7c3aed)),
    RoleOption(title: "Designer", dotColor: Color(0xffec4899)),
    RoleOption(title: "Social Media Manager", dotColor: Color(0xff0ea5e9)),
    RoleOption(title: "Viewer", dotColor: Color(0xff64748b)),
  ];

  static const List<DataScopeOption> _dataScopeOptions = [
    DataScopeOption(title: "Own Data Only", icon: LucideIcons.fingerprint_pattern),
    DataScopeOption(title: "Team Data", icon: LucideIcons.users),
    DataScopeOption(title: "Department", icon: LucideIcons.building_2),
    DataScopeOption(title: "All Organization Data", icon: LucideIcons.globe),
  ];

  static const List<String> _teamOptions = [
    "No team",
    "Core Sales",
    "Growth Marketing",
    "Product & Design",
    "Platform Engineering",
    "Customer Success",
  ];

  late RoleOption _selectedRole;
  late DataScopeOption _selectedDataScope;
  String _selectedTeam = "No team";
  String _selectedReportsTo = "No manager";

  @override
  void initState() {
    super.initState();
    _selectedRole = _roleOptions.firstWhere(
      (r) => r.title == "Viewer",
      orElse: () => _roleOptions.last,
    );
    _selectedDataScope = _dataScopeOptions.first;
    if (widget.existingManagers.isNotEmpty) {
      _selectedReportsTo = "No manager";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (!(_formKeyProfile.currentState?.validate() ?? false)) {
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submit() {
    final userData = NewUserData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      role: _selectedRole.title,
      roleColor: _selectedRole.dotColor,
      dataScope: _selectedDataScope.title,
      team: _selectedTeam,
      reportsTo: _selectedReportsTo,
      sendInviteEmail: _sendInvitationEmail,
    );
    widget.onUserCreated(userData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: contentTheme.cardBackground,
      elevation: 8,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxWidth: 620),
        padding: MySpacing.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            _buildDialogHeader(),
            MySpacing.height(24),

            // Stepper progress indicator
            _buildStepper(),
            MySpacing.height(26),

            // Step Content
            if (_currentStep == 0) _buildProfileStep(),
            if (_currentStep == 1) _buildRoleAccessStep(),
            if (_currentStep == 2) _buildReviewStep(),
            MySpacing.height(24),

            // Bottom Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleLarge(
                "Add New User",
                fontSize: 22,
                fontWeight: 700,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(4),
              MyText.bodyMedium(
                "Set up a new team member with the right access",
                fontSize: 13,
                color: contentTheme.cardTextMuted,
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(
            LucideIcons.x,
            size: 18,
            color: contentTheme.cardTextMuted,
          ),
          splashRadius: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        // Step 1: Profile
        _buildStepItem(
          index: 0,
          label: "Profile",
          icon: LucideIcons.user_plus,
        ),
        // Line 1
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: _currentStep > 0
                ? contentTheme.primary
                : contentTheme.cardBorder,
          ),
        ),
        // Step 2: Role & Access
        _buildStepItem(
          index: 1,
          label: "Role & Access",
          icon: LucideIcons.shield,
        ),
        // Line 2
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: _currentStep > 1
                ? contentTheme.primary
                : contentTheme.cardBorder,
          ),
        ),
        // Step 3: Review
        _buildStepItem(
          index: 2,
          label: "Review",
          icon: LucideIcons.circle_check,
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isCompleted = _currentStep > index;
    final isActive = _currentStep == index;

    Color badgeBg;
    Color iconColor;
    Color textColor;
    Widget childWidget;

    if (isCompleted) {
      badgeBg = contentTheme.primary;
      iconColor = Colors.white;
      textColor = contentTheme.primary;
      childWidget = const Icon(LucideIcons.check, size: 20, color: Colors.white);
    } else if (isActive) {
      badgeBg = contentTheme.primary;
      iconColor = Colors.white;
      textColor = contentTheme.primary;
      childWidget = Icon(icon, size: 20, color: iconColor);
    } else {
      badgeBg = contentTheme.background;
      iconColor = contentTheme.cardTextMuted;
      textColor = contentTheme.cardTextMuted;
      childWidget = Icon(icon, size: 20, color: iconColor);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(12),
            border: (!isCompleted && !isActive)
                ? Border.all(color: contentTheme.cardBorder)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: contentTheme.primary.withAlpha(70),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(child: childWidget),
        ),
        MySpacing.height(6),
        MyText.bodySmall(
          label,
          fontSize: 12,
          fontWeight: isActive || isCompleted ? 600 : 500,
          color: textColor,
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Step 1: Profile (Basic Information)
  // -------------------------------------------------------------
  Widget _buildProfileStep() {
    return Form(
      key: _formKeyProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: LucideIcons.user_plus,
            title: "Basic Information",
          ),
          MySpacing.height(18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              Expanded(
                child: _buildFormField(
                  label: "Full Name *",
                  child: TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                    decoration: _inputDecoration(hint: "e.g. John Doe"),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              MySpacing.width(16),
              // Email
              Expanded(
                child: _buildFormField(
                  label: "Email *",
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                    decoration: _inputDecoration(hint: "john@example.com"),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!val.contains("@") || !val.contains(".")) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          MySpacing.height(14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone
              Expanded(
                child: _buildFormField(
                  label: "Phone",
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                    decoration: _inputDecoration(hint: "+1 234 567 8900"),
                  ),
                ),
              ),
              MySpacing.width(16),
              // Department
              Expanded(
                child: _buildFormField(
                  label: "Department",
                  child: TextFormField(
                    controller: _departmentController,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                    decoration: _inputDecoration(hint: "Sales"),
                  ),
                ),
              ),
            ],
          ),
          MySpacing.height(20),
          // Send Invitation Email Switch Card
          Container(
            padding: MySpacing.xy(16, 14),
            decoration: BoxDecoration(
              color: contentTheme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: contentTheme.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Switch(
                  value: _sendInvitationEmail,
                  activeThumbColor: contentTheme.primary,
                  activeTrackColor: contentTheme.primary.withAlpha(120),
                  onChanged: (val) {
                    setState(() {
                      _sendInvitationEmail = val;
                    });
                  },
                ),
                MySpacing.width(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium(
                        "Send Invitation Email",
                        fontWeight: 600,
                        fontSize: 14,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.height(2),
                      MyText.bodySmall(
                        "User will receive an email to set their own password",
                        fontSize: 12,
                        color: contentTheme.cardTextMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Step 2: Role & Access Control
  // -------------------------------------------------------------
  Widget _buildRoleAccessStep() {
    final managerList = [
      "No manager",
      ...widget.existingManagers.where((m) => m != "No manager"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: LucideIcons.shield,
          title: "Role & Access Control",
        ),
        MySpacing.height(18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Role *
            Expanded(
              child: _buildFormField(
                label: "Primary Role *",
                child: _buildRoleDropdown(),
              ),
            ),
            MySpacing.width(16),
            // Data Scope
            Expanded(
              child: _buildFormField(
                label: "Data Scope",
                child: _buildDataScopeDropdown(),
              ),
            ),
          ],
        ),
        MySpacing.height(14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team
            Expanded(
              child: _buildFormField(
                label: "Team",
                child: _buildCustomSelectionDropdown<String>(
                  value: _selectedTeam,
                  items: _teamOptions,
                  renderItem: (item) => Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTeam = val);
                  },
                ),
              ),
            ),
            MySpacing.width(16),
            // Reports To
            Expanded(
              child: _buildFormField(
                label: "Reports To",
                child: _buildCustomSelectionDropdown<String>(
                  value: _selectedReportsTo,
                  items: managerList,
                  renderItem: (item) => Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: contentTheme.onBackground,
                    ),
                  ),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReportsTo = val);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return AppDropdown<RoleOption>(
      value: _selectedRole,
      items: _roleOptions,
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      itemLabel: (r) => r.title,
      leadingBuilder: (role, isSelected) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: role.dotColor,
          shape: BoxShape.circle,
        ),
      ),
      onChanged: (RoleOption opt) {
        setState(() {
          _selectedRole = opt;
        });
      },
    );
  }

  Widget _buildDataScopeDropdown() {
    return AppDropdown<DataScopeOption>(
      value: _selectedDataScope,
      items: _dataScopeOptions,
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      itemLabel: (s) => s.title,
      leadingBuilder: (scope, isSelected) => Icon(
        scope.icon,
        size: 16,
        color: isSelected ? Colors.white : contentTheme.cardText,
      ),
      onChanged: (DataScopeOption opt) {
        setState(() {
          _selectedDataScope = opt;
        });
      },
    );
  }

  Widget _buildCustomSelectionDropdown<T>({
    required T value,
    required List<T> items,
    required Widget Function(T) renderItem,
    required ValueChanged<T?> onChanged,
  }) {
    return AppDropdown<T>(
      value: value,
      items: items,
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      itemLabel: (item) => item.toString(),
      onChanged: (val) => onChanged(val),
    );
  }

  // -------------------------------------------------------------
  // Step 3: Review & Confirm
  // -------------------------------------------------------------
  Widget _buildReviewStep() {
    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : "U";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          icon: LucideIcons.circle_check,
          title: "Review & Confirm",
        ),
        MySpacing.height(18),
        Container(
          padding: MySpacing.all(20),
          decoration: BoxDecoration(
            color: contentTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: contentTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card top row
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: contentTheme.primary.withAlpha(30),
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: contentTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  MySpacing.width(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium(
                          _nameController.text.trim().isNotEmpty
                              ? _nameController.text.trim()
                              : "New User",
                          fontWeight: 700,
                          fontSize: 16,
                          color: contentTheme.onBackground,
                        ),
                        MySpacing.height(2),
                        MyText.bodySmall(
                          _emailController.text.trim().isNotEmpty
                              ? _emailController.text.trim()
                              : "user@example.com",
                          fontSize: 13,
                          color: contentTheme.cardTextMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: contentTheme.cardBorder,
                ),
              ),
              // Grid Information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Col 1: Role & Department
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReviewItem(
                          label: "Role",
                          value: _selectedRole.title,
                        ),
                        MySpacing.height(16),
                        _buildReviewItem(
                          label: "Department",
                          value: _departmentController.text.trim().isNotEmpty
                              ? _departmentController.text.trim()
                              : "Not specified",
                        ),
                      ],
                    ),
                  ),
                  MySpacing.width(20),
                  // Col 2: Data Scope & Onboarding
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReviewItem(
                          label: "Data Scope",
                          value: _selectedDataScope.title,
                        ),
                        MySpacing.height(16),
                        _buildReviewItem(
                          label: "Onboarding",
                          value: _sendInvitationEmail
                              ? "Email invitation"
                              : "Manual setup",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodySmall(
          label,
          fontSize: 12,
          fontWeight: 500,
          color: contentTheme.cardTextMuted,
        ),
        MySpacing.height(4),
        MyText.bodyMedium(
          value,
          fontSize: 14,
          fontWeight: 600,
          color: contentTheme.onBackground,
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Helper Widgets
  // -------------------------------------------------------------
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: contentTheme.primary,
        ),
        MySpacing.width(8),
        MyText.titleMedium(
          title,
          fontWeight: 700,
          fontSize: 15,
          color: contentTheme.onBackground,
        ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodySmall(
          label,
          fontWeight: 600,
          fontSize: 12,
          color: contentTheme.onBackground,
        ),
        MySpacing.height(6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: contentTheme.cardTextMuted,
      ),
      filled: true,
      fillColor: contentTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: contentTheme.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: contentTheme.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: contentTheme.danger),
      ),
      contentPadding: MySpacing.xy(14, 12),
      isDense: true,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel Button
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: contentTheme.cardBorder),
            backgroundColor: contentTheme.cardBackground,
            padding: MySpacing.xy(18, 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: MyText.bodyMedium(
            "Cancel",
            fontWeight: 500,
            fontSize: 13,
            color: contentTheme.onBackground,
          ),
        ),
        // Back Button (if not on first step)
        if (_currentStep > 0) ...[
          MySpacing.width(10),
          OutlinedButton(
            onPressed: _goToPreviousStep,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: contentTheme.cardBorder),
              backgroundColor: contentTheme.cardBackground,
              padding: MySpacing.xy(18, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: MyText.bodyMedium(
              "Back",
              fontWeight: 500,
              fontSize: 13,
              color: contentTheme.onBackground,
            ),
          ),
        ],
        MySpacing.width(10),
        // Primary Button (Continue > or Send Invitation)
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: contentTheme.primary,
              foregroundColor: Colors.white,
              padding: MySpacing.xy(20, 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Continue",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                MySpacing.width(6),
                const Icon(
                  LucideIcons.chevron_right,
                  size: 15,
                  color: Colors.white,
                ),
              ],
            ),
          )
        else
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: contentTheme.primary,
              foregroundColor: Colors.white,
              padding: MySpacing.xy(20, 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Send Invitation",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
