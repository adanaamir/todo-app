import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
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
                : TextButton(
                    onPressed: _save,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Update' : 'Save',
                      style: GoogleFonts.poppins(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          )
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
                  style: const TextStyle(color: AppTheme.textPrimary),
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
                const SizedBox(height: 24),

                // Description
                _SectionLabel(label: 'Description (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add some details...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Priority
                _SectionLabel(label: 'Priority'),
                const SizedBox(height: 12),
                _PrioritySelector(
                  selected: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
                const SizedBox(height: 24),

                // Due Date
                _SectionLabel(label: 'Due Date (optional)'),
                const SizedBox(height: 8),
                _DueDatePicker(
                  date: _dueDate,
                  onPick: _pickDate,
                  onClear: () => setState(() => _dueDate = null),
                ),
                const SizedBox(height: 40),
              ],
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
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
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
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected ? color : AppTheme.textMuted,
                      size: 18),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppTheme.textMuted,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: date != null
                ? AppTheme.primary.withValues(alpha: 0.5)
                : const Color(0xFF333360),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: date != null ? AppTheme.primary : AppTheme.textSecondary,
              size: 20,
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
                  fontSize: 14,
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
