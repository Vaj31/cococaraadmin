import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:ccpladmin/features/user_management/presentation/widgets/add_user_dialog.dart';
import 'package:ccpladmin/features/user_management/presentation/widgets/user_details_drawer.dart';
import 'package:ccpladmin/features/user_management/presentation/widgets/edit_user_dialog.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String role;
  final String dataScope;
  final String team;
  final String reportsTo;
  final bool sendInviteEmail;
  final String status;
  final String lastActive;
  final Color avatarColor;
  bool isSelected;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = "",
    this.department = "",
    required this.role,
    required this.dataScope,
    this.team = "No team",
    this.reportsTo = "No manager",
    this.sendInviteEmail = true,
    required this.status,
    required this.lastActive,
    required this.avatarColor,
    this.isSelected = false,
  });
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRoleFilter = "All Roles";
  String _selectedStatusFilter = "All Status";
  int _selectedTabIndex = 0;
  bool _isGridView = false;
  bool _selectAll = false;

  final List<String> _tabs = [
    "Users",
    "Roles",
    "Permissions",
    "Permission Sets",
    "Audit",
  ];

  late List<UserModel> _users;

  @override
  void initState() {
    super.initState();
    _users = [
      UserModel(
        id: "1",
        name: "Barathvaj T",
        email: "tbarathvaj@gmail.com",
        role: "Workspace Owner",
        dataScope: "All Organization Data",
        status: "Active",
        lastActive: "Sep 2",
        avatarColor: const Color(0xffDC2626),
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.role.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRoleFilter == "All Roles" ||
          user.role.toLowerCase() == _selectedRoleFilter.toLowerCase();

      final matchesStatus = _selectedStatusFilter == "All Status" ||
          user.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  int get _totalUsersCount => _users.length;
  int get _activeUsersCount =>
      _users.where((u) => u.status.toLowerCase() == "active").length;

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumb & Page Header
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: "Administration"),
                        MyBreadcrumbItem(name: "User Management", active: true),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(8),
                _buildHeader(),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),

          // Content Body
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // KPI Metric Cards (4 cards)
                _buildKpiSection(),
                MySpacing.height(flexSpacing),

                // Role Distribution Card
                _buildRoleDistributionCard(),
                MySpacing.height(flexSpacing),

                // Tab Bar & View Switch
                _buildTabBarSection(),
                MySpacing.height(16),

                // Search & Filter Row
                _buildSearchAndFilters(),
                MySpacing.height(16),

                // Main Table / Grid View
                _buildTableOrGrid(),
                MySpacing.height(flexSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleLarge(
                "User Management",
                fontSize: 26,
                fontWeight: 700,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(4),
              MyText.bodyMedium(
                "Manage $_totalUsersCount ${_totalUsersCount == 1 ? 'user' : 'users'}, roles, and enterprise permissions",
                color: contentTheme.cardText,
                fontSize: 14,
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Export Button
            OutlinedButton.icon(
              onPressed: () {
                Utils.showInfoToast("Exporting users data...", context: context);
              },
              icon: Icon(
                LucideIcons.download,
                size: 16,
                color: contentTheme.onBackground,
              ),
              label: MyText.bodyMedium(
                "Export",
                fontWeight: 600,
                color: contentTheme.onBackground,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: contentTheme.cardBorder),
                backgroundColor: contentTheme.cardBackground,
                padding: MySpacing.xy(16, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Refresh Button
            OutlinedButton(
              onPressed: () {
                setState(() {});
                Utils.showSuccessToast("User data refreshed", context: context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: contentTheme.cardBorder),
                backgroundColor: contentTheme.cardBackground,
                padding: MySpacing.xy(12, 12),
                minimumSize: const Size(42, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                LucideIcons.rotate_cw,
                size: 16,
                color: contentTheme.onBackground,
              ),
            ),
            // Add User Button
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(
                LucideIcons.user_plus,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                "Add User",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: contentTheme.primary,
                padding: MySpacing.xy(18, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiSection() {
    return MyFlex(
      children: [
        MyFlexItem(
          sizes: 'lg-3 md-6 sm-12',
          child: _buildMetricCard(
            value: "$_totalUsersCount",
            title: "Total Users",
            subtitle: "$_activeUsersCount active this week",
            icon: LucideIcons.users,
            iconBg: contentTheme.primary,
          ),
        ),
        MyFlexItem(
          sizes: 'lg-3 md-6 sm-12',
          child: _buildMetricCard(
            value: "$_activeUsersCount",
            title: "Active",
            subtitle:
                "${_totalUsersCount > 0 ? ((_activeUsersCount / _totalUsersCount) * 100).round() : 0}% of total",
            icon: LucideIcons.user_check,
            iconBg: contentTheme.info,
          ),
        ),
        MyFlexItem(
          sizes: 'lg-3 md-6 sm-12',
          child: _buildMetricCard(
            value: "10",
            title: "Roles",
            subtitle: "10 system, 0 custom",
            icon: LucideIcons.shield,
            iconBg: contentTheme.warning,
          ),
        ),
        MyFlexItem(
          sizes: 'lg-3 md-6 sm-12',
          child: _buildMetricCard(
            value: "0",
            title: "Pending Invites",
            subtitle: "awaiting acceptance",
            icon: LucideIcons.user_plus,
            iconBg: contentTheme.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
  }) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 20,
      shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText.displaySmall(
                  value,
                  fontWeight: 700,
                  fontSize: 32,
                  color: contentTheme.onBackground,
                ),
                MySpacing.height(6),
                MyText.bodyMedium(
                  title,
                  fontWeight: 600,
                  fontSize: 14,
                  color: contentTheme.onBackground,
                ),
                MySpacing.height(4),
                MyText.bodySmall(
                  subtitle,
                  color: contentTheme.cardTextMuted,
                  fontSize: 12,
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDistributionCard() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 20,
      shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                "Role Distribution",
                fontWeight: 700,
                fontSize: 15,
                color: contentTheme.onBackground,
              ),
              MyText.bodySmall(
                "$_totalUsersCount total",
                color: contentTheme.cardTextMuted,
                fontSize: 13,
              ),
            ],
          ),
          MySpacing.height(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 10,
              width: double.infinity,
              color: contentTheme.danger,
            ),
          ),
          MySpacing.height(14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: contentTheme.danger,
                ),
              ),
              MySpacing.width(8),
              MyText.bodyMedium(
                "Workspace Owner ($_totalUsersCount)",
                fontSize: 13,
                fontWeight: 500,
                color: contentTheme.onBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSection() {
    return Row(
      children: [
        // Tabs
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                final tabName = _tabs[index];
                IconData tabIcon;
                switch (tabName) {
                  case "Users":
                    tabIcon = LucideIcons.users;
                    break;
                  case "Roles":
                    tabIcon = LucideIcons.shield;
                    break;
                  case "Permissions":
                    tabIcon = LucideIcons.lock;
                    break;
                  case "Permission Sets":
                    tabIcon = LucideIcons.layers;
                    break;
                  case "Audit":
                    tabIcon = LucideIcons.history;
                    break;
                  default:
                    tabIcon = LucideIcons.circle;
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: MySpacing.xy(14, 10),
                    margin: MySpacing.right(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? contentTheme.primary.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: contentTheme.primary.withAlpha(50))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tabIcon,
                          size: 16,
                          color: isSelected
                              ? contentTheme.primary
                              : contentTheme.cardText,
                        ),
                        MySpacing.width(8),
                        MyText.bodyMedium(
                          tabName,
                          fontWeight: isSelected ? 600 : 500,
                          fontSize: 14,
                          color: isSelected
                              ? contentTheme.primary
                              : contentTheme.cardText,
                        ),
                        if (index == 0) ...[
                          MySpacing.width(8),
                          Container(
                            padding: MySpacing.xy(8, 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? contentTheme.primary
                                  : contentTheme.onBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MyText.bodySmall(
                              "$_totalUsersCount",
                              fontSize: 11,
                              fontWeight: 700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        MySpacing.width(12),
        // List / Grid toggle
        Container(
          decoration: BoxDecoration(
            color: contentTheme.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: contentTheme.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: MySpacing.all(8),
                onPressed: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
                icon: Icon(
                  LucideIcons.list,
                  color: !_isGridView
                      ? contentTheme.primary
                      : contentTheme.cardTextMuted,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                padding: MySpacing.all(8),
                onPressed: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
                icon: Icon(
                  LucideIcons.layout_grid,
                  color: _isGridView
                      ? contentTheme.primary
                      : contentTheme.cardTextMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        // Search bar
        Expanded(
          flex: 4,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search by name, email, or department...",
              hintStyle: TextStyle(
                fontSize: 13,
                color: contentTheme.onBackground.withAlpha(150),
              ),
              prefixIcon: Icon(
                LucideIcons.search,
                size: 18,
                color: contentTheme.onBackground.withAlpha(150),
              ),
              filled: true,
              fillColor: contentTheme.background,
              contentPadding: MySpacing.xy(16, 12),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: contentTheme.onBackground.withAlpha(20),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: contentTheme.primary),
              ),
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: contentTheme.onBackground,
            ),
          ),
        ),
        MySpacing.width(12),
        // All Roles dropdown
        _buildRoleFilterDropdown(),
        MySpacing.width(12),
        // All Status dropdown
        _buildStatusFilterDropdown(),
      ],
    );
  }

  static const List<Map<String, dynamic>> _roleFilterOptions = [
    {"title": "All Roles", "color": null},
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

  static const List<String> _statusFilterOptions = [
    "All Status",
    "Active",
    "Invited",
    "Suspended",
    "Deactivated",
  ];

  Widget _buildRoleFilterDropdown() {
    return AppDropdown<String>(
      value: _selectedRoleFilter,
      items: _roleFilterOptions.map((opt) => opt["title"] as String).toList(),
      height: 42,
      backgroundColor: contentTheme.cardBackground,
      borderColor: contentTheme.cardBorder,
      leadingBuilder: (role, isSelected) {
        final opt = _roleFilterOptions.firstWhere(
          (r) => r["title"] == role,
          orElse: () => _roleFilterOptions.first,
        );
        final Color? dotColor = opt["color"] as Color?;
        if (dotColor != null) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }
        return Icon(
          LucideIcons.shield,
          size: 15,
          color: isSelected ? Colors.white : contentTheme.cardText,
        );
      },
      onChanged: (val) {
        setState(() {
          _selectedRoleFilter = val;
        });
      },
    );
  }

  Widget _buildStatusFilterDropdown() {
    return AppDropdown<String>(
      value: _selectedStatusFilter,
      items: _statusFilterOptions,
      height: 42,
      backgroundColor: contentTheme.cardBackground,
      borderColor: contentTheme.cardBorder,
      prefix: Icon(
        LucideIcons.activity,
        size: 15,
        color: contentTheme.cardText,
      ),
      onChanged: (val) {
        setState(() {
          _selectedStatusFilter = val;
        });
      },
    );
  }

  Widget _buildTableOrGrid() {
    if (_selectedTabIndex != 0) {
      return MyCard(
        borderRadiusAll: 12,
        paddingAll: 40,
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.folder_open,
                size: 48,
                color: contentTheme.cardTextMuted,
              ),
              MySpacing.height(16),
              MyText.titleMedium(
                "${_tabs[_selectedTabIndex]} Settings",
                fontWeight: 600,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(6),
              MyText.bodyMedium(
                "Configuration for ${_tabs[_selectedTabIndex].toLowerCase()} will be managed here.",
                color: contentTheme.cardTextMuted,
              ),
            ],
          ),
        ),
      );
    }

    final users = _filteredUsers;

    if (users.isEmpty) {
      return MyCard(
        borderRadiusAll: 12,
        paddingAll: 40,
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.users,
                size: 48,
                color: contentTheme.cardTextMuted,
              ),
              MySpacing.height(16),
              MyText.titleMedium(
                "No users found",
                fontWeight: 600,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(6),
              MyText.bodyMedium(
                "Try adjusting your search or filters.",
                color: contentTheme.cardTextMuted,
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return _buildGridView(users);
    }

    return _buildTableView(users);
  }

  Widget _buildTableView(List<UserModel> users) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.bottom),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: MySpacing.xy(16, 14),
            decoration: BoxDecoration(
              color: contentTheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: contentTheme.cardBorder),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Checkbox(
                    value: _selectAll,
                    activeColor: contentTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectAll = val ?? false;
                        for (var u in users) {
                          u.isSelected = _selectAll;
                        }
                      });
                    },
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      MyText.labelMedium(
                        "USER",
                        fontWeight: 700,
                        fontSize: 11,
                        color: contentTheme.cardText,
                      ),
                      MySpacing.width(4),
                      Icon(
                        LucideIcons.arrow_up,
                        size: 13,
                        color: contentTheme.cardText,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MyText.labelMedium(
                    "ROLE",
                    fontWeight: 700,
                    fontSize: 11,
                    color: contentTheme.cardText,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MyText.labelMedium(
                    "DATA SCOPE",
                    fontWeight: 700,
                    fontSize: 11,
                    color: contentTheme.cardText,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: MyText.labelMedium(
                    "STATUS",
                    fontWeight: 700,
                    fontSize: 11,
                    color: contentTheme.cardText,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: MyText.labelMedium(
                    "LAST ACTIVE",
                    fontWeight: 700,
                    fontSize: 11,
                    color: contentTheme.cardText,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: MyText.labelMedium(
                    "ACTIONS",
                    fontWeight: 700,
                    fontSize: 11,
                    color: contentTheme.cardText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: contentTheme.cardBorder,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: MySpacing.xy(16, 14),
                color: user.isSelected
                    ? contentTheme.primary.withAlpha(10)
                    : Colors.transparent,
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Checkbox(
                        value: user.isSelected,
                        activeColor: contentTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            user.isSelected = val ?? false;
                            _selectAll = users.every((u) => u.isSelected);
                          });
                        },
                      ),
                    ),
                    MySpacing.width(12),
                    // USER cell
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: user.avatarColor,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : "U",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          MySpacing.width(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyMedium(
                                  user.name,
                                  fontWeight: 600,
                                  fontSize: 14,
                                  color: contentTheme.onBackground,
                                ),
                                MySpacing.height(2),
                                MyText.bodySmall(
                                  user.email,
                                  fontSize: 12,
                                  color: contentTheme.cardTextMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ROLE cell
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: MySpacing.xy(10, 4),
                          decoration: BoxDecoration(
                            color: user.avatarColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
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
                                    : user.role.toLowerCase().contains("admin") ||
                                            user.role.toLowerCase().contains("manager")
                                        ? LucideIcons.shield
                                        : LucideIcons.user,
                                size: 13,
                                color: user.avatarColor,
                              ),
                              MySpacing.width(6),
                              MyText.bodySmall(
                                user.role,
                                fontSize: 12,
                                fontWeight: 500,
                                color: user.avatarColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // DATA SCOPE cell
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.globe,
                            size: 15,
                            color: contentTheme.cardText,
                          ),
                          MySpacing.width(8),
                          Expanded(
                            child: MyText.bodyMedium(
                              user.dataScope,
                              fontSize: 13,
                              color: contentTheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // STATUS cell
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.status.toLowerCase() == "active"
                                  ? contentTheme.success
                                  : contentTheme.cardTextMuted,
                            ),
                          ),
                          MySpacing.width(6),
                          MyText.bodyMedium(
                            user.status,
                            fontSize: 13,
                            fontWeight: 500,
                            color: contentTheme.onBackground,
                          ),
                        ],
                      ),
                    ),
                    // LAST ACTIVE cell
                    Expanded(
                      flex: 1,
                      child: MyText.bodySmall(
                        user.lastActive,
                        fontSize: 13,
                        color: contentTheme.cardText,
                      ),
                    ),
                    // ACTIONS cell
                    SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: "View User Details",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            onPressed: () => _showUserDetails(user),
                            icon: Icon(
                              LucideIcons.eye,
                              size: 16,
                              color: contentTheme.cardText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: "Edit User",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            onPressed: () => _showEditUser(user),
                            icon: Icon(
                              LucideIcons.pencil,
                              size: 16,
                              color: contentTheme.cardText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<UserModel> users) {
    return MyFlex(
      children: users.map((user) {
        return MyFlexItem(
          sizes: 'lg-4 md-6 sm-12',
          child: MyCard(
            borderRadiusAll: 12,
            paddingAll: 20,
            shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: user.avatarColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyLarge(
                            user.name,
                            fontWeight: 600,
                            color: contentTheme.onBackground,
                          ),
                          MyText.bodySmall(
                            user.email,
                            color: contentTheme.cardTextMuted,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.status.toLowerCase() == "active"
                            ? contentTheme.success
                            : contentTheme.cardTextMuted,
                      ),
                    ),
                  ],
                ),
                MySpacing.height(16),
                Divider(height: 1, color: contentTheme.cardBorder),
                MySpacing.height(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.bodySmall("Role", color: contentTheme.cardTextMuted),
                    Container(
                      padding: MySpacing.xy(8, 4),
                      decoration: BoxDecoration(
                        color: user.avatarColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MyText.bodySmall(
                        user.role,
                        color: user.avatarColor,
                        fontWeight: 600,
                      ),
                    ),
                  ],
                ),
                MySpacing.height(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.bodySmall("Data Scope", color: contentTheme.cardTextMuted),
                    MyText.bodySmall(user.dataScope, fontWeight: 500),
                  ],
                ),
                MySpacing.height(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.bodySmall("Last Active", color: contentTheme.cardTextMuted),
                    MyText.bodySmall(user.lastActive, color: contentTheme.cardText),
                  ],
                ),
                MySpacing.height(14),
                Divider(height: 1, color: contentTheme.cardBorder),
                MySpacing.height(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: "View User Details",
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _showUserDetails(user),
                      icon: Icon(
                        LucideIcons.eye,
                        size: 16,
                        color: contentTheme.cardText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "Edit User",
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _showEditUser(user),
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: contentTheme.cardText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddUserDialog() {
    final managers = _users.map((u) => "${u.name} (${u.role})").toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AddUserDialog(
          existingManagers: managers,
          onUserCreated: (userData) {
            setState(() {
              _users.add(
                UserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: userData.name,
                  email: userData.email,
                  phone: userData.phone,
                  department: userData.department,
                  role: userData.role,
                  dataScope: userData.dataScope,
                  team: userData.team,
                  reportsTo: userData.reportsTo,
                  sendInviteEmail: userData.sendInviteEmail,
                  status: "Active",
                  lastActive: "Just now",
                  avatarColor: userData.roleColor,
                ),
              );
            });
            Utils.showSuccessToast(
              "${userData.name} was successfully ${userData.sendInviteEmail ? 'invited' : 'added'}.",
              context: context,
            );
          },
        );
      },
    );
  }

  void _showUserDetails(UserModel user) {
    UserDetailsDrawer.show(context, user);
  }

  void _showEditUser(UserModel user) {
    final managers = _users.map((u) => "${u.name} (${u.role})").toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return EditUserDialog(
          user: user,
          existingManagers: managers,
          onUserUpdated: (updatedUser) {
            setState(() {
              final index = _users.indexWhere((u) => u.id == updatedUser.id);
              if (index != -1) {
                _users[index] = updatedUser;
              }
            });
            Utils.showSuccessToast(
              "${updatedUser.name} was successfully updated.",
              context: context,
            );
          },
        );
      },
    );
  }
}
