import 'package:ccpladmin/features/user_management/presentation/views/user_management_screen.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class UserDetailsDrawer extends StatefulWidget {
  final UserModel user;

  const UserDetailsDrawer({super.key, required this.user});

  static void show(BuildContext context, UserModel user) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss User Details",
      barrierColor: Colors.black.withAlpha(90),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: UserDetailsDrawer(user: user),
            ),
          ),
        );
      },
    );
  }

  @override
  State<UserDetailsDrawer> createState() => _UserDetailsDrawerState();
}

class _UserDetailsDrawerState extends State<UserDetailsDrawer> with UIMixin {
  int _selectedTab = 0; // 0: Access, 1: Sessions
  final TextEditingController _permissionFilterController = TextEditingController();
  String _permissionFilter = "";

  final List<Map<String, dynamic>> _permissions = [
    {
      "category": "CRM Core",
      "module": "DASHBOARD",
      "code": "crm.dashboard.view",
      "description": "View dashboard and analytics",
      "source": "Role",
    },
    {
      "category": "CRM Core",
      "module": "DASHBOARD",
      "code": "crm.dashboard.export",
      "description": "Export dashboard data",
      "source": "Role",
    },
    {
      "category": "CRM Core",
      "module": "LEADS",
      "code": "crm.leads.read",
      "description": "View leads",
      "source": "Role",
    },
    {
      "category": "CRM Core",
      "module": "LEADS",
      "code": "crm.leads.edit",
      "description": "Create and edit lead profiles",
      "source": "Role",
    },
    {
      "category": "Administration",
      "module": "SETTINGS",
      "code": "admin.settings.manage",
      "description": "Configure company and system settings",
      "source": "Role",
    },
  ];

  @override
  void dispose() {
    _permissionFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPerms = _permissions.where((p) {
      if (_permissionFilter.isEmpty) return true;
      final query = _permissionFilter.toLowerCase();
      final code = (p["code"] as String).toLowerCase();
      final desc = (p["description"] as String).toLowerCase();
      final mod = (p["module"] as String).toLowerCase();
      return code.contains(query) || desc.contains(query) || mod.contains(query);
    }).toList();

    return Container(
      width: 520,
      height: double.infinity,
      decoration: BoxDecoration(
        color: contentTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          _buildHeader(),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: MySpacing.xy(24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // KPI Stat boxes
                  _buildKpiBoxes(),
                  MySpacing.height(20),

                  // Tab switcher (Access / Sessions)
                  _buildTabSwitcher(),
                  MySpacing.height(20),

                  if (_selectedTab == 0) ...[
                    // Profiles section
                    _buildProfilesSection(),
                    MySpacing.height(24),

                    // Permissions tree section
                    _buildPermissionsSection(filteredPerms),
                  ] else ...[
                    _buildSessionsSection(),
                  ],
                ],
              ),
            ),
          ),

          // Sticky Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = widget.user;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : "U";

    return Container(
      padding: MySpacing.xy(24, 20),
      decoration: BoxDecoration(
        color: contentTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: contentTheme.cardBorder),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: user.avatarColor,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          MySpacing.width(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium(
                  user.name,
                  fontWeight: 700,
                  fontSize: 17,
                  color: contentTheme.onBackground,
                ),
                MySpacing.height(2),
                MyText.bodySmall(
                  user.email,
                  fontSize: 13,
                  color: contentTheme.cardTextMuted,
                ),
                MySpacing.height(8),
                Row(
                  children: [
                    // Role pill badge
                    Container(
                      padding: MySpacing.xy(8, 3),
                      decoration: BoxDecoration(
                        color: user.avatarColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: user.avatarColor.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user.role.toLowerCase().contains("owner")
                                ? LucideIcons.crown
                                : LucideIcons.shield,
                            size: 11,
                            color: user.avatarColor,
                          ),
                          MySpacing.width(5),
                          Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.avatarColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MySpacing.width(8),
                    // Scope pill badge
                    Container(
                      padding: MySpacing.xy(8, 3),
                      decoration: BoxDecoration(
                        color: contentTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: contentTheme.cardBorder,
                        ),
                      ),
                      child: Text(
                        user.dataScope.toLowerCase().contains("all")
                            ? "All Scope"
                            : user.dataScope,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: contentTheme.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                LucideIcons.x,
                size: 16,
                color: contentTheme.cardTextMuted,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBoxes() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            value: "111",
            label: "Permissions",
            highlight: true,
          ),
        ),
        MySpacing.width(10),
        Expanded(
          child: _buildMetricCard(
            value: "1",
            label: "Modules",
            highlight: false,
          ),
        ),
        MySpacing.width(10),
        Expanded(
          child: _buildMetricCard(
            value: "0",
            label: "Profiles",
            highlight: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required bool highlight,
  }) {
    return Container(
      padding: MySpacing.xy(14, 12),
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: contentTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: highlight ? contentTheme.primary : contentTheme.onBackground,
            ),
          ),
          MySpacing.height(3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: contentTheme.cardTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contentTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: MySpacing.y(7),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? contentTheme.cardBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Access",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 0
                          ? contentTheme.onBackground
                          : contentTheme.cardTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 1),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: MySpacing.y(7),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? contentTheme.cardBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Sessions",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 1
                          ? contentTheme.onBackground
                          : contentTheme.cardTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.layers,
              size: 16,
              color: contentTheme.primary,
            ),
            MySpacing.width(8),
            Text(
              "Profiles",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: contentTheme.onBackground,
              ),
            ),
            MySpacing.width(6),
            Expanded(
              child: Text(
                "(permission sets layered on the role)",
                style: TextStyle(
                  fontSize: 12,
                  color: contentTheme.cardTextMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        MySpacing.height(10),
        Container(
          width: double.infinity,
          padding: MySpacing.all(14),
          decoration: BoxDecoration(
            color: contentTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: contentTheme.cardBorder),
          ),
          child: Text(
            "No permission sets assigned.",
            style: TextStyle(
              fontSize: 13,
              color: contentTheme.cardTextMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(List<Map<String, dynamic>> perms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.sliders_horizontal,
              size: 16,
              color: contentTheme.primary,
            ),
            MySpacing.width(8),
            Text(
              "What they can actually do",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: contentTheme.onBackground,
              ),
            ),
          ],
        ),
        MySpacing.height(12),
        // Filter input
        TextField(
          controller: _permissionFilterController,
          onChanged: (val) {
            setState(() {
              _permissionFilter = val;
            });
          },
          style: TextStyle(fontSize: 13, color: contentTheme.onBackground),
          decoration: InputDecoration(
            hintText: "Filter permissions...",
            hintStyle: TextStyle(fontSize: 13, color: contentTheme.cardTextMuted),
            prefixIcon: Icon(LucideIcons.search, size: 16, color: contentTheme.cardTextMuted),
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
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            contentPadding: MySpacing.xy(12, 10),
            isDense: true,
          ),
        ),
        MySpacing.height(8),
        Text(
          "Each row shows where its access comes from. Use Grant / Deny to override for this user only.",
          style: TextStyle(fontSize: 12, color: contentTheme.cardTextMuted),
        ),
        MySpacing.height(14),

        // Permission list
        Container(
          decoration: BoxDecoration(
            color: contentTheme.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: contentTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                width: double.infinity,
                padding: MySpacing.xy(14, 10),
                decoration: BoxDecoration(
                  color: contentTheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  border: Border(
                    bottom: BorderSide(color: contentTheme.cardBorder),
                  ),
                ),
                child: Text(
                  "CRM Core",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: contentTheme.onBackground,
                  ),
                ),
              ),
              // Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: perms.length,
                separatorBuilder: (ctx, i) => Divider(
                  height: 1,
                  thickness: 1,
                  color: contentTheme.cardBorder,
                ),
                itemBuilder: (ctx, i) {
                  final p = perms[i];
                  return Padding(
                    padding: MySpacing.xy(14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i == 0 || perms[i - 1]["module"] != p["module"]) ...[
                          Text(
                            p["module"] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: contentTheme.cardTextMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          MySpacing.height(6),
                        ],
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff10b981),
                              ),
                            ),
                            MySpacing.width(8),
                            Expanded(
                              child: Text(
                                p["code"] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                  color: contentTheme.onBackground,
                                ),
                              ),
                            ),
                            Container(
                              padding: MySpacing.xy(6, 2),
                              decoration: BoxDecoration(
                                color: contentTheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p["source"] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: contentTheme.primary,
                                ),
                              ),
                            ),
                            MySpacing.width(10),
                            InkWell(
                              onTap: () {
                                Utils.showInfoToast(
                                  "Access derived from ${widget.user.role} role",
                                  context: context,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Why?",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: contentTheme.cardTextMuted,
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevron_down,
                                    size: 12,
                                    color: contentTheme.cardTextMuted,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(3),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            p["description"] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: contentTheme.cardTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Field Security expander
              InkWell(
                onTap: () {
                  Utils.showInfoToast("Field security rules are active", context: context);
                },
                child: Container(
                  width: double.infinity,
                  padding: MySpacing.xy(14, 12),
                  decoration: BoxDecoration(
                    color: contentTheme.background.withAlpha(120),
                    border: Border(
                      top: BorderSide(color: contentTheme.cardBorder),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.shield_check,
                            size: 15,
                            color: contentTheme.cardTextMuted,
                          ),
                          MySpacing.width(8),
                          Text(
                            "Field Security",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        LucideIcons.chevron_down,
                        size: 15,
                        color: contentTheme.cardTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsSection() {
    return Container(
      padding: MySpacing.all(20),
      decoration: BoxDecoration(
        color: contentTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: contentTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.laptop, size: 16, color: contentTheme.primary),
              MySpacing.width(8),
              Text(
                "Active Sessions",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: contentTheme.onBackground,
                ),
              ),
            ],
          ),
          MySpacing.height(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chrome on Windows (Current)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.onBackground,
                    ),
                  ),
                  MySpacing.height(2),
                  Text(
                    "Last active: Just now • IP: 192.168.1.12",
                    style: TextStyle(
                      fontSize: 12,
                      color: contentTheme.cardTextMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: MySpacing.xy(8, 3),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff10b981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: MySpacing.xy(24, 16),
      decoration: BoxDecoration(
        color: contentTheme.cardBackground,
        border: Border(
          top: BorderSide(color: contentTheme.cardBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Utils.showSuccessToast(
                "Overrides saved for ${widget.user.name}",
                context: context,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: contentTheme.primary,
              foregroundColor: Colors.white,
              padding: MySpacing.xy(22, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Save Overrides",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
