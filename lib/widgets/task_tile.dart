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
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    final cardBg = isDark
        ? AppTheme.bgCardDm
        : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFF25213F)
        : const Color(0xFFE8E5F7);
    final titleColor = isDark
        ? AppTheme.textPrimaryDm
        : AppTheme.textPrimary;
    final subtitleColor = isDark
        ? AppTheme.textSecondaryDm
        : AppTheme.textSecondary;
    final mutedColor = isDark
        ? AppTheme.textMutedDm
        : AppTheme.textMuted;

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
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_rounded, size: 20),
                  const SizedBox(height: 4),
                  Text('Edit',
                      style: GoogleFonts.poppins(
                          fontSize: 10.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.error.withValues(alpha: 0.18),
              foregroundColor: AppTheme.error,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 20),
                  const SizedBox(height: 4),
                  Text('Delete',
                      style: GoogleFonts.poppins(
                          fontSize: 10.5, fontWeight: FontWeight.w600)),
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
                  ? cardBg.withValues(alpha: 0.6)
                  : cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isCompleted
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : cardBorder,
              ),
              boxShadow: task.isCompleted
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority stripe
                  Container(
                    width: 3.5,
                    height: 42,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? mutedColor : _priorityColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppTheme.success.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: task.isCompleted ? AppTheme.success : mutedColor,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: AppTheme.success, size: 13)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted ? mutedColor : titleColor,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: mutedColor,
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
                                  ? mutedColor.withValues(alpha: 0.6)
                                  : subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _PriorityChip(
                              priority: task.priority,
                              color: _priorityColor,
                              isCompleted: task.isCompleted,
                              mutedColor: mutedColor,
                            ),
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              _DueDateChip(
                                date: task.dueDate!,
                                isCompleted: task.isCompleted,
                                mutedColor: mutedColor,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Swipe hint
                  Icon(
                    Icons.chevron_left_rounded,
                    color: mutedColor,
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
  final Color mutedColor;

  const _PriorityChip({
    required this.priority,
    required this.color,
    required this.isCompleted,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final label = priority.name[0].toUpperCase() + priority.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted
            ? mutedColor.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isCompleted ? mutedColor : color,
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime date;
  final bool isCompleted;
  final Color mutedColor;

  const _DueDateChip({
    required this.date,
    required this.isCompleted,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = !isCompleted && date.isBefore(DateTime.now());
    final color = isCompleted
        ? mutedColor
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
