import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

class AssetItem {
  final String id;
  final String name;
  final String client;
  final String kind;
  final String size;
  final String uploadDate;
  final Uint8List? bytes;
  final String extension;
  final String tags;
  final String caption;

  AssetItem({
    required this.id,
    required this.name,
    required this.client,
    required this.kind,
    required this.size,
    required this.uploadDate,
    this.bytes,
    required this.extension,
    this.tags = '',
    this.caption = '',
  });
}

class AssetLibraryScreen extends StatefulWidget {
  const AssetLibraryScreen({super.key});

  @override
  State<AssetLibraryScreen> createState() => _AssetLibraryScreenState();
}

class _AssetLibraryScreenState extends State<AssetLibraryScreen> with UIMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedClient = "All company";
  String _selectedKind = "All kinds";

  final List<String> _clients = [
    "All company",
    "CCPL TN",
    "CCPL PY",
    "TPST TN",
    "TPST PY",
    "ESAN",
  ];
  final List<String> _kinds = [
    "All kinds",
    "Logo",
    "Image",
    "Document",
    "Guideline",
    "Font",
    "Other",
  ];

  final List<AssetItem> _assets = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AssetItem> get _filteredAssets {
    return _assets.where((asset) {
      final matchesSearch = _searchQuery.isEmpty ||
          asset.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.client.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.kind.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.tags.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.caption.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesClient = _selectedClient == "All company" ||
          asset.client.toLowerCase() == _selectedClient.toLowerCase();

      final matchesKind = _selectedKind == "All kinds" ||
          asset.kind.toLowerCase() == _selectedKind.toLowerCase();

      return matchesSearch && matchesClient && matchesKind;
    }).toList();
  }

  void _showUploadAssetDialog() {
    PlatformFile? selectedFile;
    final nameController = TextEditingController();
    final captionController = TextEditingController();

    String uploadKind = "Image";
    final kindsList = [
      "Logo",
      "Image",
      "Document",
      "Guideline",
      "Font",
      "Other",
    ];

    String uploadCompany = _selectedClient != "All company"
        ? _selectedClient
        : (_clients.length > 1 ? _clients[1] : "CCPL TN");

    final companiesList = _clients.where((c) => c != "All company").toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickFile() async {
              try {
                final result = await FilePicker.pickFiles(withData: true);
                if (result != null && result.files.isNotEmpty) {
                  setModalState(() {
                    selectedFile = result.files.first;
                    if (nameController.text.trim().isEmpty) {
                      String baseName = selectedFile!.name;
                      final dotIndex = baseName.lastIndexOf('.');
                      if (dotIndex > 0) {
                        baseName = baseName.substring(0, dotIndex);
                      }
                      nameController.text = baseName;
                    }
                  });
                }
              } catch (e) {
                Utils.showErrorToast("Could not pick file: $e");
              }
            }

            void handleUpload() {
              if (selectedFile == null) {
                Utils.showWarningToast("Please select a file to upload");
                return;
              }

              final assetName = nameController.text.trim().isNotEmpty
                  ? nameController.text.trim()
                  : selectedFile!.name;

              setState(() {
                _assets.insert(
                  0,
                  AssetItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: assetName,
                    client: uploadCompany,
                    kind: uploadKind,
                    size: _formatFileSize(selectedFile!.size),
                    uploadDate: _getFormattedCurrentDate(),
                    bytes: selectedFile!.bytes,
                    extension: selectedFile!.extension ?? '',
                    caption: captionController.text.trim(),
                  ),
                );
              });

              Navigator.pop(context);
              Utils.showSuccessToast("$assetName added to library");
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: contentTheme.cardBackground,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: 520,
                padding: MySpacing.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title & Close
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.titleMedium(
                            "Upload asset",
                            fontWeight: 700,
                            fontSize: 18,
                            color: contentTheme.onBackground,
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(LucideIcons.x, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      MySpacing.height(2),
                      MyText.bodySmall(
                        "Add files to the brand library so the whole team can use them.",
                        color: contentTheme.cardTextMuted,
                        fontSize: 13,
                      ),
                      MySpacing.height(18),

                      // Drag & browse box
                      InkWell(
                        onTap: pickFile,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: MySpacing.xy(20, 22),
                          decoration: BoxDecoration(
                            color: selectedFile == null
                                ? contentTheme.background
                                : contentTheme.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: contentTheme.primary.withAlpha(80),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                          child: selectedFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.cloud_upload,
                                      size: 36,
                                      color: contentTheme.cardTextMuted,
                                    ),
                                    MySpacing.height(8),
                                    Text(
                                      "Drag files here, or click to browse",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: contentTheme.cardTextMuted,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      _getFileIcon(selectedFile!.extension ?? ''),
                                      size: 28,
                                      color: contentTheme.primary,
                                    ),
                                    MySpacing.width(12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedFile!.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: contentTheme.onBackground,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          MySpacing.height(2),
                                          Text(
                                            _formatFileSize(selectedFile!.size),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: contentTheme.cardTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: MySpacing.xy(10, 4),
                                      decoration: BoxDecoration(
                                        color: contentTheme.cardBackground,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: contentTheme.onBackground.withAlpha(20),
                                        ),
                                      ),
                                      child: const Text(
                                        "Change file",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      MySpacing.height(16),

                      // Row 1: Name & Kind (same size, height, and styling)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyMedium("Name", fontWeight: 600, fontSize: 13),
                                MySpacing.height(6),
                                Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  padding: MySpacing.x(14),
                                  decoration: BoxDecoration(
                                    color: contentTheme.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: contentTheme.onBackground.withAlpha(25),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: "Primary logo",
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: contentTheme.onBackground.withAlpha(120),
                                      ),
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: contentTheme.onBackground,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MySpacing.width(14),
                          // Kind dropdown
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyMedium("Kind", fontWeight: 600, fontSize: 13),
                                MySpacing.height(6),
                                AppDropdown<String>(
                                  value: uploadKind,
                                  items: kindsList,
                                  height: 44,
                                  isExpanded: true,
                                  onChanged: (val) {
                                    setModalState(() => uploadKind = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(14),

                      // Row 2: Company dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("Company", fontWeight: 600, fontSize: 13),
                          MySpacing.height(6),
                          AppDropdown<String>(
                            value: companiesList.contains(uploadCompany)
                                ? uploadCompany
                                : companiesList.first,
                            items: companiesList,
                            height: 44,
                            isExpanded: true,
                            onChanged: (val) {
                              setModalState(() => uploadCompany = val);
                            },
                          ),
                        ],
                      ),
                      MySpacing.height(14),

                      // Caption
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("Caption", fontWeight: 600, fontSize: 13),
                          MySpacing.height(6),
                          TextField(
                            controller: captionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "When to use this file...",
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: contentTheme.onBackground.withAlpha(120),
                              ),
                              filled: true,
                              fillColor: contentTheme.background,
                              contentPadding: MySpacing.xy(14, 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: contentTheme.onBackground.withAlpha(25),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: contentTheme.onBackground.withAlpha(25),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: contentTheme.primary),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: contentTheme.onBackground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(24),

                      // Footer Buttons: Cancel & Upload
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: MySpacing.xy(22, 0),
                                side: BorderSide(
                                  color: contentTheme.onBackground.withAlpha(30),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: contentTheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          MySpacing.width(12),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: handleUpload,
                              icon: const Icon(
                                LucideIcons.cloud_upload,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Upload",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedFile == null
                                    ? contentTheme.primary.withAlpha(120)
                                    : contentTheme.primary,
                                padding: MySpacing.xy(22, 0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
            );
          },
        );
      },
    );
  }

  void _downloadAsset(AssetItem asset) {
    if (kIsWeb && asset.bytes != null) {
      final blob = html.Blob([asset.bytes!]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = asset.name;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
    Utils.showInfoToast("Downloading ${asset.name}...");
  }

  void _confirmDeleteAsset(AssetItem asset) {
    Get.defaultDialog(
      title: "Delete Asset",
      middleText: "Are you sure you want to remove '${asset.name}'?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: contentTheme.danger,
      onConfirm: () {
        setState(() {
          _assets.removeWhere((a) => a.id == asset.id);
        });
        Get.back();
        Utils.showSuccessToast("${asset.name} removed");
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  String _getFormattedCurrentDate() {
    final now = DateTime.now();
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${months[now.month - 1]} ${now.day}, ${now.year}";
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'svg':
      case 'gif':
      case 'webp':
        return LucideIcons.image;
      case 'pdf':
        return LucideIcons.file_text;
      case 'doc':
      case 'docx':
        return LucideIcons.file;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return LucideIcons.sheet;
      case 'zip':
      case 'rar':
        return LucideIcons.archive;
      default:
        return LucideIcons.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAssets;

    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumb (top right)
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: "Assets"),
                    MyBreadcrumbItem(name: "Asset Library", active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(12),

          // Header Row
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: _buildHeader(),
          ),
          MySpacing.height(20),

          // Search, Filter & Action Row
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: _buildSearchAndActionRow(),
          ),
          MySpacing.height(20),

          // Content Area (Empty State or Asset Grid)
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: filtered.isEmpty
                ? _buildEmptyState()
                : _buildAssetGrid(filtered),
          ),
          MySpacing.height(flexSpacing),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Folder Icon
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: contentTheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              LucideIcons.folder,
              size: 24,
              color: contentTheme.primary,
            ),
          ),
        ),
        MySpacing.width(14),
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleLarge(
                "Asset Library",
                fontSize: 24,
                fontWeight: 700,
                color: contentTheme.onBackground,
              ),
              MySpacing.height(4),
              MyText.bodyMedium(
                "Logos, brand files, and documents for every company — shared with the whole team.",
                color: contentTheme.cardTextMuted,
                fontSize: 13,
              ),
            ],
          ),
        ),
        // All company dropdown (top right of header)
        AppDropdown<String>(
          value: _selectedClient,
          items: _clients,
          height: 38,
          onChanged: (val) {
            setState(() {
              _selectedClient = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndActionRow() {
    return Row(
      children: [
        // Search assets by name, tag, or caption...
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search assets by name, tag, or caption...",
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
                contentPadding: MySpacing.xy(16, 0),
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
        ),
        MySpacing.width(12),
        // All kinds dropdown
        AppDropdown<String>(
          value: _selectedKind,
          items: _kinds,
          height: 42,
          onChanged: (val) {
            setState(() {
              _selectedKind = val;
            });
          },
        ),
        MySpacing.width(12),
        // + Upload button (same height & balanced width as All kinds dropdown)
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: _showUploadAssetDialog,
            icon: const Icon(
              LucideIcons.plus,
              size: 16,
              color: Colors.white,
            ),
            label: const Text(
              "Upload",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: contentTheme.primary,
              padding: MySpacing.x(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 56,
      shadow: MyShadow(elevation: 0.2, position: MyShadowPosition.bottom),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.folder,
              size: 52,
              color: contentTheme.cardTextMuted.withAlpha(140),
            ),
            MySpacing.height(16),
            MyText.bodyMedium(
              "No assets in the library yet",
              fontWeight: 500,
              fontSize: 15,
              color: contentTheme.cardTextMuted,
            ),
            MySpacing.height(16),
            OutlinedButton.icon(
              onPressed: _showUploadAssetDialog,
              icon: Icon(
                LucideIcons.plus,
                size: 16,
                color: contentTheme.onBackground,
              ),
              label: MyText.bodyMedium(
                "Upload the first asset",
                fontWeight: 600,
                color: contentTheme.onBackground,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: contentTheme.cardBorder),
                backgroundColor: contentTheme.cardBackground,
                padding: MySpacing.xy(18, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetGrid(List<AssetItem> assets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final isImage = ['png', 'jpg', 'jpeg', 'webp', 'gif']
                .contains(asset.extension.toLowerCase());

            return MyCard(
              borderRadiusAll: 10,
              paddingAll: 14,
              shadow: MyShadow(elevation: 0.2, position: MyShadowPosition.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: contentTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: contentTheme.onBackground.withAlpha(15),
                        ),
                      ),
                      child: isImage && asset.bytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                asset.bytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Icon(
                                _getFileIcon(asset.extension),
                                size: 36,
                                color: contentTheme.primary,
                              ),
                            ),
                    ),
                  ),
                  MySpacing.height(10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.onBackground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            MySpacing.height(2),
                            Row(
                              children: [
                                Text(
                                  asset.client,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: contentTheme.cardTextMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  " • ${asset.size}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: contentTheme.cardTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: MySpacing.xy(6, 2),
                        decoration: BoxDecoration(
                          color: contentTheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          asset.kind,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  MySpacing.height(8),
                  const Divider(height: 1),
                  MySpacing.height(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        asset.uploadDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: contentTheme.cardTextMuted,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: "Download",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: () => _downloadAsset(asset),
                            icon: Icon(
                              LucideIcons.download,
                              size: 15,
                              color: contentTheme.cardText,
                            ),
                          ),
                          MySpacing.width(4),
                          IconButton(
                            tooltip: "Delete",
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed: () => _confirmDeleteAsset(asset),
                            icon: Icon(
                              LucideIcons.trash_2,
                              size: 15,
                              color: contentTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
