import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/premium_ambient_background.dart';
import '../screens/add_edit_task_screen.dart';
import 'login_screen.dart';
import '../main.dart' show appThemeProvider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _taskService = TaskService();

  String _filter = 'all'; // 'all', 'active', 'completed'

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out',
                style: GoogleFonts.poppins(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  //logic of deleting task
  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Task',
          style: GoogleFonts.poppins(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Delete "${task.title}"? This cannot be undone.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _taskService.deleteTask(task);
        if (mounted) {
          final isDarkSnack = Theme.of(context).brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Task deleted',
                style: GoogleFonts.poppins(
                  color: isDarkSnack
                      ? AppTheme.textPrimaryDm
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: isDarkSnack
                  ? AppTheme.bgCardDm
                  : AppTheme.bgCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDarkSnack
                      ? const Color(0xFF25213F)
                      : const Color(0xFFE8E5F7),
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.all(16),
              elevation: 4,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  List<TaskModel> _filteredTasks(List<TaskModel> all) {
    return switch (_filter) {
      'active' => all.where((t) => !t.isCompleted).toList(),
      'completed' => all.where((t) => t.isCompleted).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';
 
  // calendar for all the deadlines of tasks
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getTasks(userId),
      builder: (context, snapshot) {
        final allTasks = snapshot.data ?? [];
        final tasks = _filteredTasks(allTasks);
        final completedCount = allTasks.where((t) => t.isCompleted).length;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting && allTasks.isEmpty;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return PremiumAmbientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: CustomScrollView(
              slivers: [
                //Custom App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 120,
                  pinned: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    // Dark mode toggle
                    GestureDetector(
                      onTap: () => appThemeProvider.toggle(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 4, top: 12, bottom: 12),
                        width: 48,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: isDark
                              ? AppTheme.primary.withValues(alpha: 0.30)
                              : AppTheme.primary.withValues(alpha: 0.20),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Row(
                            mainAxisAlignment: isDark
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primary,
                                ),
                                child: Icon(
                                  isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: isDark
                            ? AppTheme.textSecondaryDm
                            : AppTheme.textSecondary,
                      ),
                      onPressed: _logout,
                      tooltip: 'Sign Out',
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.transparent,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ordely',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.textPrimaryDm
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Good day!',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppTheme.textPrimaryDm
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Calendar or Task List
                if (_filter == 'calendar')
                  SliverToBoxAdapter(
                    child: _CalendarView(tasks: allTasks),
                  )
                else if (isLoading)
                  const SliverFillRemaining(child: _LoadingState())
                else if (snapshot.hasError)
                  SliverFillRemaining(
                      child: _ErrorState(error: snapshot.error.toString()))
                else if (tasks.isEmpty)
                  SliverFillRemaining(child: _EmptyState(filter: _filter))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return _StatsRow(
                              total: allTasks.length,
                              completed: completedCount,
                            );
                          }
                          final task = tasks[index - 1];
                          return TaskTile(
                            key: ValueKey(task.id),
                            task: task,
                            onToggle: () => _taskService.toggleComplete(task),
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTaskScreen(
                                  userId: userId,
                                  task: task,
                                ),
                              ),
                            ),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                        childCount: tasks.length + 1,
                      ),
                    ),
                  ),
              ],
            ),
          bottomNavigationBar: _FloatingTabBar(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
            onAdd: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(userId: userId),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int total;
  final int completed;

  const _StatsRow({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completed of $total done',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor = isDark ? AppTheme.textPrimaryDm : AppTheme.textPrimary;
    final textSecondaryColor = isDark ? AppTheme.textSecondaryDm : AppTheme.textSecondary;

    final (icon, title, subtitle) = switch (filter) {
      'active' => (
          Icons.playlist_add_check_circle_outlined,
          'All caught up!',
          'No active tasks. Great work!',
        ),
      'completed' => (
          Icons.check_circle_outline_rounded,
          'Nothing completed yet',
          'Complete a task to see it here.',
        ),
      _ => (
          Icons.inbox_outlined,
          'No tasks yet',
          'Tap the button below to add your first task.',
        ),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, size: 46, color: AppTheme.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 40, color: AppTheme.error),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Floating rounded bottom tab bar
class _FloatingTabBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const _FloatingTabBar({
    required this.selected,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCardDm : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabItem(label: 'All', value: 'all', selected: selected, onTap: onChanged),
          _TabItem(label: 'Pending', value: 'active', selected: selected, onTap: onChanged),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
          _TabItem(label: 'Done', value: 'completed', selected: selected, onTap: onChanged),
          _TabItem(label: 'Calendar', value: 'calendar', selected: selected, onTap: onChanged),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _TabItem({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final highlightColor = isDark ? Colors.white : AppTheme.textPrimary;
    final unselectedColor = isDark 
        ? AppTheme.textSecondaryDm 
        : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => onTap(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? highlightColor : unselectedColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: highlightColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Calendar View ─────────────────────────────────────────────────────────

class _CalendarView extends StatefulWidget {
  final List<TaskModel> tasks;
  const _CalendarView({required this.tasks});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<TaskModel> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      if (task.dueDate == null) return false;
      final d = task.dueDate!;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor = isDark ? AppTheme.textPrimaryDm : AppTheme.textPrimary;
    final textSecondaryColor = isDark ? AppTheme.textSecondaryDm : AppTheme.textSecondary;

    final selectedTasks =
        _selectedDay != null ? _getTasksForDay(_selectedDay!) : <TaskModel>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.bgCardDm.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.25) : AppTheme.textSecondary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar<TaskModel>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getTasksForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimaryColor,
                ),
                leftChevronIcon: Icon(
                    Icons.chevron_left_rounded, color: textSecondaryColor),
                rightChevronIcon: Icon(
                    Icons.chevron_right_rounded, color: textSecondaryColor),
                headerPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondaryColor),
                weekendStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.textPrimary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.poppins(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: BoxDecoration(
                  color: textPrimaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: GoogleFonts.poppins(
                  color: isDark ? AppTheme.bgDarkDm : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                defaultTextStyle:
                    GoogleFonts.poppins(color: textPrimaryColor),
                weekendTextStyle:
                    GoogleFonts.poppins(color: AppTheme.secondary),
                markerDecoration: BoxDecoration(
                  color: textSecondaryColor,
                  shape: BoxShape.circle,
                ),
                markerSize: 5,
                markerMargin: const EdgeInsets.only(top: 1),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tasks for selected day
          if (_selectedDay != null) ...
            [
              Text(
                selectedTasks.isEmpty
                    ? 'No tasks due on this day'
                    : '${selectedTasks.length} task${selectedTasks.length > 1 ? 's' : ''} due',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ...selectedTasks.map(
                (task) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? AppTheme.success
                              : task.priority == TaskPriority.high
                                  ? AppTheme.error
                                  : task.priority == TaskPriority.medium
                                      ? AppTheme.warning
                                      : AppTheme.success,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.description.isNotEmpty)
                              Text(
                                task.description,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (task.isCompleted)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.success, size: 20),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}
