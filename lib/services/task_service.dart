import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference scoped to user
  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  // Real-time stream of all tasks for a user
  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Create a new task
  Future<void> createTask(TaskModel task) async {
    await _tasksRef(task.userId).add(task.toFirestore());
  }

  // Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await _tasksRef(task.userId).doc(task.id).update(task.toFirestore());
  }

  // Toggle completed/uncompleted
  Future<void> toggleComplete(TaskModel task) async {
    await _tasksRef(task.userId).doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // Delete a task
  Future<void> deleteTask(TaskModel task) async {
    await _tasksRef(task.userId).doc(task.id).delete();
  }
}
