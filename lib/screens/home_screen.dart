import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';
import '../screens/add_edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _taskService = TaskService();
  late TabController _tabController;

  String _filter = 'all'; // 'all', 'active', 'completed'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _filter = ['all', 'active', 'completed'][_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task deleted',
                  style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: AppTheme.bgCardLight,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
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
    final userEmail = user?.email ?? 'User';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            backgroundColor: AppTheme.bgCard,
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppTheme.textSecondary),
                onPressed: _logout,
                tooltip: 'Sign Out',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.bgCard,
                      AppTheme.bgDark,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Taskly',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Good day!',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: AppTheme.bgCard,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2.5,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.poppins(fontSize: 13),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Done'),
                  ],
                ),
              ),
            ),
          ),

          // Task List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: StreamBuilder<List<TaskModel>>(
              stream: _taskService.getTasks(userId),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: _LoadingState(),
                  );
                }

                // Error State
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: _ErrorState(error: snapshot.error.toString()),
                  );
                }

                final allTasks = snapshot.data ?? [];
                final tasks = _filteredTasks(allTasks);

                // Stats header
                final completedCount =
                    allTasks.where((t) => t.isCompleted).length;

                // Empty State
                if (tasks.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(filter: _filter),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        // Stats Row
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditTaskScreen(userId: userId),
          ),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Task',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 8,
      ),
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
              color: AppTheme.primary.withValues(alpha: 0.3),
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
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
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
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
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
