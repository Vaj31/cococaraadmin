import 'package:ccpladmin/features/user_management/presentation/views/user_management_screen.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final List<String> existingManagers;
  final Function(UserModel) onUserUpdated;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
    this.existingManagers = const [],
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> with UIMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;

  static const List<Map<String, dynamic>> _roleOptions = [
    {"title": "Workspace Owner", "color": Color(0xffdc2626)},
    {"title": "Admin", "color": Color(0xff8b5cf6)},
    {"title": "Manager", "color": Color(0xff3b82f6)},
    {"title": "Sales Executive", "color": Color(0xff10b981)},
    {"title": "Operations", "color": Color(0xff06b6d4)},
    {"title": "Finance", "color": Color(0xffd97706)},
    {"title": "Creative Director", "color": Color(0xff7c3aed)},
    {"title": "Designer", "color": Color(0xffec4899)},
    {"title": "Social Media Manager", "color": Color(0xff0ea5e9)},
    {"title": "Viewer", "color": Color(0xff64748b)},
  ];

  static const List<Map<String, dynamic>> _dataScopeOptions = [
    {"title": "All Organization Data", "icon": LucideIcons.globe},
    {"title": "Department", "icon": LucideIcons.building_2},
    {"title": "Team Data", "icon": LucideIcons.users},
    {"title": "Own Data Only", "icon": LucideIcons.fingerprint_pattern},
  ];

  static const List<String> _teamOptions = [
    "No team",
    "Core Sales",
    "Growth Marketing",
    "Product & Design",
    "Platform Engineering",
    "Customer Success",
  ];

  late String _selectedRole;
  late Color _selectedRoleColor;
  late String _selectedDataScope;
  late String _selectedTeam;
  late String _selectedReportsTo;

  bool get _isWorkspaceOwner =>
      widget.user.role.toLowerCase().contains("workspace owner") ||
      widget.user.role.toLowerCase() == "owner";

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.name);
    _emailController = TextEditingController(text: u.email);
    _phoneController = TextEditingController(text: u.phone.isNotEmpty ? u.phone : "+1 234 567 8900");
    _departmentController = TextEditingController(text: u.department.isNotEmpty ? u.department : "Sales");

    _selectedRole = u.role;
    _selectedRoleColor = u.avatarColor;

    // Data scope
    final matchScope = _dataScopeOptions.firstWhere(
      (s) => s["title"] == u.dataScope,
      orElse: () => _dataScopeOptions.first,
    );
    _selectedDataScope = matchScope["title"] as String;

    _selectedTeam = u.team.isNotEmpty ? u.team : "No team";
    _selectedReportsTo = u.reportsTo.isNotEmpty ? u.reportsTo : "No manager";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final updated = UserModel(
      id: widget.user.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      role: _selectedRole,
      dataScope: _selectedDataScope,
      team: _selectedTeam,
      reportsTo: _selectedReportsTo,
      sendInviteEmail: widget.user.sendInviteEmail,
      status: widget.user.status,
      lastActive: widget.user.lastActive,
      avatarColor: _selectedRoleColor,
      isSelected: widget.user.isSelected,
    );

    widget.onUserUpdated(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final managerList = [
      "No manager",
      ...widget.existingManagers.where(
        (m) => m != "No manager" && !m.startsWith(widget.user.name),
      ),
    ];

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleLarge(
                          "Edit User",
                          fontSize: 22,
                          fontWeight: 700,
                          color: contentTheme.onBackground,
                        ),
                        MySpacing.height(4),
                        MyText.bodyMedium(
                          "Update user profile, role, and access",
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              MySpacing.height(22),

              // Basic Fields Row 1
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Full Name *",
                      child: TextFormField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        decoration: _inputDecoration(hint: "Full Name"),
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
                  Expanded(
                    child: _buildFormField(
                      label: "Email *",
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        decoration: _inputDecoration(hint: "Email"),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Email is required";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              MySpacing.height(14),

              // Basic Fields Row 2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Phone",
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        decoration: _inputDecoration(hint: "+1 234 567 8900"),
                      ),
                    ),
                  ),
                  MySpacing.width(16),
                  Expanded(
                    child: _buildFormField(
                      label: "Department",
                      child: TextFormField(
                        controller: _departmentController,
                        style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        decoration: _inputDecoration(hint: "Department"),
                      ),
                    ),
                  ),
                ],
              ),
              MySpacing.height(22),

              // Role & Access Title
              Text(
                "Role & Access",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: contentTheme.onBackground,
                ),
              ),
              MySpacing.height(12),

              // Warning alert for Workspace Owner
              if (_isWorkspaceOwner) ...[
                Container(
                  padding: MySpacing.xy(14, 11),
                  decoration: BoxDecoration(
                    color: const Color(0xfffffbeb),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xfffef08a)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.triangle_alert,
                        size: 16,
                        color: Color(0xffd97706),
                      ),
                      MySpacing.width(10),
                      const Expanded(
                        child: Text(
                          "Workspace Owner role cannot be changed here. Use \"Transfer Ownership\" to transfer.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffb45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MySpacing.height(14),
              ],

              // Dropdowns Row 1: Primary Role & Data Scope
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Primary Role *",
                      child: _buildRoleDropdown(),
                    ),
                  ),
                  MySpacing.width(16),
                  Expanded(
                    child: _buildFormField(
                      label: "Data Scope",
                      child: _buildDataScopeDropdown(),
                    ),
                  ),
                ],
              ),
              MySpacing.height(14),

              // Dropdowns Row 2: Team & Reports To
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFormField(
                      label: "Team",
                      child: _buildDropdownField<String>(
                        value: _selectedTeam,
                        items: _teamOptions,
                        renderItem: (item) => Text(
                          item,
                          style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTeam = val);
                        },
                      ),
                    ),
                  ),
                  MySpacing.width(16),
                  Expanded(
                    child: _buildFormField(
                      label: "Reports To",
                      child: _buildDropdownField<String>(
                        value: _selectedReportsTo,
                        items: managerList,
                        renderItem: (item) => Text(
                          item,
                          style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
                        ),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedReportsTo = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              MySpacing.height(26),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  MySpacing.width(12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: contentTheme.primary,
                      foregroundColor: Colors.white,
                      padding: MySpacing.xy(22, 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Update User",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    if (_isWorkspaceOwner) {
      // Locked dropdown for workspace owner
      return Container(
        padding: MySpacing.xy(14, 11),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: contentTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xffdc2626),
                shape: BoxShape.circle,
              ),
            ),
            MySpacing.width(10),
            Expanded(
              child: Text(
                _selectedRole,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: contentTheme.onBackground,
                ),
              ),
            ),
            Container(
              padding: MySpacing.xy(6, 2),
              decoration: BoxDecoration(
                color: contentTheme.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Current",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: contentTheme.cardTextMuted,
                ),
              ),
            ),
            MySpacing.width(6),
            Icon(
              LucideIcons.chevron_down,
              size: 16,
              color: contentTheme.cardTextMuted,
            ),
          ],
        ),
      );
    }

    return AppDropdown<String>(
      value: _selectedRole,
      items: _roleOptions
          .where((r) => r["title"] != "Workspace Owner")
          .map((r) => r["title"] as String)
          .toList(),
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      leadingBuilder: (role, isSelected) {
        final opt = _roleOptions.firstWhere(
          (r) => r["title"] == role,
          orElse: () => _roleOptions.first,
        );
        return Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: opt["color"] as Color,
            shape: BoxShape.circle,
          ),
        );
      },
      onChanged: (val) {
        final opt = _roleOptions.firstWhere(
          (r) => r["title"] == val,
          orElse: () => _roleOptions.first,
        );
        setState(() {
          _selectedRole = val;
          _selectedRoleColor = opt["color"] as Color;
        });
      },
    );
  }

  Widget _buildDataScopeDropdown() {
    return AppDropdown<String>(
      value: _selectedDataScope,
      items: _dataScopeOptions.map((d) => d["title"] as String).toList(),
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      leadingBuilder: (scope, isSelected) {
        final opt = _dataScopeOptions.firstWhere(
          (d) => d["title"] == scope,
          orElse: () => _dataScopeOptions.first,
        );
        return Icon(
          opt["icon"] as IconData,
          size: 16,
          color: isSelected ? Colors.white : contentTheme.cardText,
        );
      },
      onChanged: (val) {
        setState(() {
          _selectedDataScope = val;
        });
      },
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<T> items,
    required Widget Function(T) renderItem,
    required ValueChanged<T?> onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : items.first;
    return AppDropdown<T>(
      value: effectiveValue,
      items: items,
      isExpanded: true,
      height: 44,
      backgroundColor: contentTheme.background,
      borderColor: contentTheme.cardBorder,
      itemLabel: (item) => item.toString(),
      onChanged: (val) => onChanged(val),
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
}
