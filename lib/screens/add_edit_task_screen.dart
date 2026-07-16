import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_ambient_background.dart';

class AddEditTaskScreen extends StatefulWidget {
  final String userId;
  final TaskModel? task; // null = add mode, non-null = edit mode

  const AddEditTaskScreen({
    super.key,
    required this.userId,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _taskService = TaskService();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    if (_isEditing) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.bgCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );
        await _taskService.updateTask(updated);
      } else {
        final newTask = TaskModel(
          id: '',
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          isCompleted: false,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
          priority: _priority,
          userId: widget.userId,
        );
        await _taskService.createTask(newTask);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumAmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? const Color(0xFFF5E8D5) : AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFF5E8D5) : AppTheme.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _isEditing ? 'Update' : 'Save',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _SectionLabel(label: 'Task Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  style: TextStyle(color: isDark ? AppTheme.textPrimaryDm : AppTheme.textPrimary),
                  maxLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'What do you need to do?',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Task title is required';
                    }
                    if (v.trim().length > 100) {
                      return 'Title too long (max 100 chars)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Description
                _SectionLabel(label: 'Description (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  style: TextStyle(color: isDark ? AppTheme.textPrimaryDm : AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add some details...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 45),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Priority
                _SectionLabel(label: 'Priority'),
                const SizedBox(height: 10),
                _PrioritySelector(
                  selected: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
                const SizedBox(height: 18),

                // Due Date
                _SectionLabel(label: 'Due Date (optional)'),
                const SizedBox(height: 8),
                _DueDatePicker(
                  date: _dueDate,
                  onPick: _pickDate,
                  onClear: () => setState(() => _dueDate = null),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFB89F8A) : AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? AppTheme.bgCardLightDm : AppTheme.bgCardLight;
    final unselectedFg = isDark ? AppTheme.textMutedDm : AppTheme.textMuted;
    return Row(
      children: TaskPriority.values.map((p) {
        final isSelected = p == selected;
        final (color, label, icon) = switch (p) {
          TaskPriority.low => (
              const Color(0xFF43E97B),
              'Low',
              Icons.arrow_downward_rounded
            ),
          TaskPriority.medium => (
              const Color(0xFFFFD166),
              'Medium',
              Icons.remove_rounded
            ),
          TaskPriority.high => (
              const Color(0xFFFF6584),
              'High',
              Icons.arrow_upward_rounded
            ),
        };
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: p != TaskPriority.high ? 10 : 0),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : unselectedBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected ? color : unselectedFg,
                      size: 18),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : unselectedFg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DueDatePicker extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DueDatePicker({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? AppTheme.primary.withValues(alpha: 0.5)
                : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF581C87)
                    : const Color(0xFFD8B4FE)),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: date != null ? AppTheme.primary : AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('EEE, MMM d, yyyy').format(date!)
                    : 'Pick a due date',
                style: GoogleFonts.poppins(
                  color:
                      date != null ? AppTheme.textPrimary : AppTheme.textMuted,
                  fontSize: 13.5,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.textMuted, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
