import 'package:ccpladmin/helpers/theme/admin_theme.dart';
import 'package:ccpladmin/helpers/theme/theme_customizer.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

class TodoItem {
  final String id;
  String title;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  DateTime? reminder;
  String repeat;
  String? person;
  String? place;
  List<String> tags;
  List<Map<String, dynamic>> checklist;
  String? notes;
  List<Map<String, String>> attachments;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.dueDate,
    this.dueTime,
    this.reminder,
    this.repeat = "Does not repeat",
    this.person,
    this.place = "No place",
    List<String>? tags,
    List<Map<String, dynamic>>? checklist,
    this.notes,
    List<Map<String, String>>? attachments,
    this.isCompleted = false,
  })  : tags = tags ?? [],
        checklist = checklist ?? [],
        attachments = attachments ?? [];
}

class MyTodoDrawer extends StatefulWidget {
  const MyTodoDrawer({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss My To-Do",
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 280),
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
              child: const MyTodoDrawer(),
            ),
          ),
        );
      },
    );
  }

  @override
  State<MyTodoDrawer> createState() => _MyTodoDrawerState();
}

class _MyTodoDrawerState extends State<MyTodoDrawer> {
  static final List<TodoItem> _todos = [];

  bool _isExpanded = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _checklistController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _attachmentLabelController =
      TextEditingController();
  final TextEditingController _attachmentUrlController =
      TextEditingController();

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  DateTime? _selectedReminder;
  String _selectedRepeat = "Does not repeat";
  String _selectedPlace = "No place";

  final List<String> _currentTags = [];
  final List<Map<String, dynamic>> _currentChecklist = [];
  final List<Map<String, String>> _currentAttachments = [];

  final List<String> _repeatOptions = [
    "Does not repeat",
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];

  final List<String> _placeOptions = [
    "No place",
    "Head Office",
    "Warehouse A",
    "Warehouse B",
    "Client Site",
    "Remote",
  ];

  int get _openCount => _todos.where((t) => !t.isCompleted).length;

  void _addTodo() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dueDate: _selectedDueDate,
      dueTime: _selectedDueTime,
      reminder: _selectedReminder,
      repeat: _selectedRepeat,
      person: _personController.text.trim().isEmpty
          ? null
          : _personController.text.trim(),
      place: _selectedPlace,
      tags: List.from(_currentTags),
      checklist: List.from(_currentChecklist),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      attachments: List.from(_currentAttachments),
    );

    setState(() {
      _todos.insert(0, newTodo);
      _titleController.clear();
      _personController.clear();
      _tagController.clear();
      _checklistController.clear();
      _notesController.clear();
      _attachmentLabelController.clear();
      _attachmentUrlController.clear();
      _selectedDueDate = null;
      _selectedDueTime = null;
      _selectedReminder = null;
      _selectedRepeat = "Does not repeat";
      _selectedPlace = "No place";
      _currentTags.clear();
      _currentChecklist.clear();
      _currentAttachments.clear();
    });
  }

  void _toggleTodoStatus(TodoItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
  }

  void _deleteTodo(TodoItem item) {
    setState(() {
      _todos.removeWhere((t) => t.id == item.id);
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminder ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedReminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addTag(String tag) {
    final clean = tag.trim();
    if (clean.isNotEmpty && !_currentTags.contains(clean)) {
      setState(() {
        _currentTags.add(clean);
        _tagController.clear();
      });
    }
  }

  void _addChecklistItem(String item) {
    final clean = item.trim();
    if (clean.isNotEmpty) {
      setState(() {
        _currentChecklist.add({"text": clean, "checked": false});
        _checklistController.clear();
      });
    }
  }

  void _addAttachment() {
    final label = _attachmentLabelController.text.trim();
    final url = _attachmentUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _currentAttachments.add({
          "label": label.isEmpty ? "Link" : label,
          "url": url,
        });
        _attachmentLabelController.clear();
        _attachmentUrlController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final contentTheme = AdminTheme.theme.contentTheme;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0);
    final mutedText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      width: 440,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My To-Do",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$_openCount open",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Input Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: TextField(
                            controller: _titleController,
                            onSubmitted: (_) => _addTodo(),
                            style: TextStyle(fontSize: 13, color: textColor),
                            decoration: InputDecoration(
                              hintText: "Add a personal to-do...",
                              hintStyle: TextStyle(
                                  fontSize: 13, color: mutedText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Collapse / Expand Toggle
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Icon(
                            _isExpanded
                                ? LucideIcons.chevron_up
                                : LucideIcons.chevron_down,
                            size: 16,
                            color: mutedText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Plus Add Button
                      InkWell(
                        onTap: _addTodo,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Collapsible Form Section
                  if (_isExpanded) ...[
                    const SizedBox(height: 16),

                    // Due Date & Time Row
                    Row(
                      children: [
                        // Due date
                        Expanded(
                          child: _buildFormField(
                            label: "Due date",
                            child: InkWell(
                              onTap: _pickDueDate,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: borderColor, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDueDate == null
                                          ? "dd/mm/yyyy"
                                          : DateFormat("dd/MM/yyyy")
                                              .format(_selectedDueDate!),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _selectedDueDate == null
                                            ? mutedText
                                            : textColor,
                                      ),
                                    ),
                                    Icon(LucideIcons.calendar,
                                        size: 14, color: mutedText),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time
                        Expanded(
                          child: _buildFormField(
                            label: "Time",
                            child: InkWell(
                              onTap: _pickDueTime,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: borderColor, width: 1),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDueTime == null
                                          ? "-- : -- --"
                                          : _selectedDueTime!
                                              .format(context),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _selectedDueTime == null
                                            ? mutedText
                                            : textColor,
                                      ),
                                    ),
                                    Icon(LucideIcons.clock,
                                        size: 14, color: mutedText),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Reminder
                    _buildFormField(
                      label: "Reminder",
                      child: InkWell(
                        onTap: _pickReminder,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedReminder == null
                                    ? "dd/mm/yyyy --:-- --"
                                    : DateFormat("dd/MM/yyyy hh:mm a")
                                        .format(_selectedReminder!),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _selectedReminder == null
                                      ? mutedText
                                      : textColor,
                                ),
                              ),
                              Icon(LucideIcons.calendar,
                                  size: 14, color: mutedText),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Repeat Dropdown
                    _buildFormField(
                      label: "Repeat",
                      child: AppDropdown<String>(
                        value: _selectedRepeat,
                        items: _repeatOptions,
                        height: 36,
                        isExpanded: true,
                        backgroundColor: cardBg,
                        borderColor: borderColor,
                        borderRadius: BorderRadius.circular(6),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: TextStyle(fontSize: 12.5, color: textColor),
                        onChanged: (val) {
                          setState(() {
                            _selectedRepeat = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Person
                    _buildFormField(
                      label: "Person",
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: TextField(
                          controller: _personController,
                          style: TextStyle(fontSize: 12.5, color: textColor),
                          decoration: InputDecoration(
                            hintText: "Search teammate or contact...",
                            hintStyle: TextStyle(
                                fontSize: 12.5, color: mutedText),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Place Dropdown
                    _buildFormField(
                      label: "Place",
                      child: AppDropdown<String>(
                        value: _selectedPlace,
                        items: _placeOptions,
                        height: 36,
                        isExpanded: true,
                        backgroundColor: cardBg,
                        borderColor: borderColor,
                        borderRadius: BorderRadius.circular(6),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: TextStyle(fontSize: 12.5, color: textColor),
                        onChanged: (val) {
                          setState(() {
                            _selectedPlace = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tags
                    _buildFormField(
                      label: "Tags",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: borderColor, width: 1),
                            ),
                            child: TextField(
                              controller: _tagController,
                              onSubmitted: _addTag,
                              style: TextStyle(
                                  fontSize: 12.5, color: textColor),
                              decoration: InputDecoration(
                                hintText: "Add a tag, press Enter",
                                hintStyle: TextStyle(
                                    fontSize: 12.5, color: mutedText),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          if (_currentTags.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _currentTags.map((tag) {
                                return Chip(
                                  label: Text(tag,
                                      style: const TextStyle(fontSize: 11)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onDeleted: () {
                                    setState(() {
                                      _currentTags.remove(tag);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Checklist
                    _buildFormField(
                      label: "Checklist",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: borderColor, width: 1),
                            ),
                            child: TextField(
                              controller: _checklistController,
                              onSubmitted: _addChecklistItem,
                              style: TextStyle(
                                  fontSize: 12.5, color: textColor),
                              decoration: InputDecoration(
                                hintText: "Add a checklist item, press Enter",
                                hintStyle: TextStyle(
                                    fontSize: 12.5, color: mutedText),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          if (_currentChecklist.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ..._currentChecklist.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: item["checked"] as bool,
                                        onChanged: (v) {
                                          setState(() {
                                            item["checked"] = v ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item["text"] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          decoration: item["checked"] == true
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.x,
                                          size: 13),
                                      onPressed: () {
                                        setState(() {
                                          _currentChecklist.remove(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    _buildFormField(
                      label: "Notes",
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: TextStyle(fontSize: 12.5, color: textColor),
                          decoration: InputDecoration(
                            hintText: "Add a note...",
                            hintStyle: TextStyle(
                                fontSize: 12.5, color: mutedText),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Attachments (links)
                    _buildFormField(
                      label: "Attachments (links)",
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Label
                              Container(
                                width: 95,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: borderColor, width: 1),
                                ),
                                child: TextField(
                                  controller: _attachmentLabelController,
                                  style: TextStyle(
                                      fontSize: 12, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: "Label",
                                    hintStyle: TextStyle(
                                        fontSize: 12, color: mutedText),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // URL
                              Expanded(
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: borderColor, width: 1),
                                  ),
                                  child: TextField(
                                    controller: _attachmentUrlController,
                                    onSubmitted: (_) => _addAttachment(),
                                    style: TextStyle(
                                        fontSize: 12, color: textColor),
                                    decoration: InputDecoration(
                                      hintText: "https://...",
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: mutedText),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Plus Button
                              InkWell(
                                onTap: _addAttachment,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: borderColor, width: 1),
                                  ),
                                  child: Icon(
                                    LucideIcons.plus,
                                    size: 15,
                                    color: mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_currentAttachments.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ..._currentAttachments.map((att) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.link,
                                        size: 13,
                                        color: contentTheme.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "${att['label']}: ${att['url']}",
                                        style: TextStyle(
                                            fontSize: 11.5,
                                            color: contentTheme.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.x,
                                          size: 12),
                                      onPressed: () {
                                        setState(() {
                                          _currentAttachments.remove(att);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Existing To-Do Items List
                  if (_todos.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tasks (${_todos.length})",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (_todos.any((t) => t.isCompleted))
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _todos.removeWhere((t) => t.isCompleted);
                              });
                            },
                            child: const Text("Clear completed",
                                style: TextStyle(fontSize: 11.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._todos.map((todo) => _buildTodoCard(todo, isDark,
                        cardBg, borderColor, textColor, mutedText)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    final isDark = ThemeCustomizer.instance.theme == ThemeMode.dark;
    final labelColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _buildTodoCard(
    TodoItem todo,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color mutedText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: todo.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: todo.isCompleted,
                  activeColor: isDark
                      ? const Color(0xFF35C75D)
                      : const Color(0xFF30AE52),
                  onChanged: (_) => _toggleTodoStatus(todo),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: todo.isCompleted ? mutedText : textColor,
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _deleteTodo(todo),
                child: Icon(LucideIcons.trash_2, size: 14, color: mutedText),
              ),
            ],
          ),
          if (todo.dueDate != null || todo.person != null || todo.place != "No place") ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (todo.dueDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendar, size: 11, color: mutedText),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat("dd/MM/yyyy").format(todo.dueDate!),
                        style: TextStyle(fontSize: 11, color: mutedText),
                      ),
                    ],
                  ),
                if (todo.person != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.user, size: 11, color: mutedText),
                      const SizedBox(width: 3),
                      Text(
                        todo.person!,
                        style: TextStyle(fontSize: 11, color: mutedText),
                      ),
                    ],
                  ),
                if (todo.place != "No place")
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.map_pin, size: 11, color: mutedText),
                      const SizedBox(width: 3),
                      Text(
                        todo.place!,
                        style: TextStyle(fontSize: 11, color: mutedText),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
