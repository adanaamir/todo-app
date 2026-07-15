import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

//UI for the task interaction
class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    return switch (task.priority) {
      TaskPriority.low => const Color(0xFF43E97B),
      TaskPriority.medium => const Color(0xFFFFD166),
      TaskPriority.high => const Color(0xFFFF6584),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.55,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.primary.withValues(alpha: 0.18),
              foregroundColor: AppTheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_rounded, size: 22),
                  const SizedBox(height: 4),
                  Text('Edit',
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.error.withValues(alpha: 0.18),
              foregroundColor: AppTheme.error,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 22),
                  const SizedBox(height: 4),
                  Text('Delete',
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onEdit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? AppTheme.bgCard.withValues(alpha: 0.6)
                  : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : const Color(0xFF2A2A4A),
              ),
              boxShadow: task.isCompleted
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority stripe
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppTheme.textMuted
                          : _priorityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppTheme.success.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: task.isCompleted
                              ? AppTheme.success
                              : AppTheme.textMuted,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: AppTheme.success, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppTheme.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: task.isCompleted
                                  ? AppTheme.textMuted
                                      .withValues(alpha: 0.6)
                                  : AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Priority chip
                            _PriorityChip(
                              priority: task.priority,
                              color: _priorityColor,
                              isCompleted: task.isCompleted,
                            ),
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              _DueDateChip(
                                date: task.dueDate!,
                                isCompleted: task.isCompleted,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Swipe hint
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  final Color color;
  final bool isCompleted;

  const _PriorityChip({
    required this.priority,
    required this.color,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final label = priority.name[0].toUpperCase() + priority.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.textMuted.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isCompleted ? AppTheme.textMuted : color,
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime date;
  final bool isCompleted;

  const _DueDateChip({required this.date, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !isCompleted && date.isBefore(DateTime.now());
    final color = isCompleted
        ? AppTheme.textMuted
        : isOverdue
            ? AppTheme.error
            : AppTheme.textSecondary;

    return Row(
      children: [
        Icon(Icons.calendar_today_rounded, size: 10, color: color),
        const SizedBox(width: 3),
        Text(
          DateFormat('MMM d').format(date),
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
