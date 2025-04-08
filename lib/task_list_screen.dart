import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';

class TaskListScreen extends StatefulWidget {
  final User user;

  const TaskListScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  CollectionReference get tasksRef => FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('tasks'); 

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    await tasksRef.add({
      'name': _taskController.text.trim(),
      'isCompleted': false,
    });

    _taskController.clear();
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentStatus) async {
    await tasksRef.doc(taskId).update({'isCompleted': !currentStatus});
  }

  Future<void> _deleteTask(String taskId) async {
    await tasksRef.doc(taskId).delete();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showAddTimeBlockDialog(BuildContext context) {
    final dayController = TextEditingController();
    final timeRangeController = TextEditingController();
    final taskListController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Time Block'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                decoration: const InputDecoration(labelText: 'Day (e.g., Monday)'),
              ),
              TextField(
                controller: timeRangeController,
                decoration: const InputDecoration(labelText: 'Time (e.g., 9 AM - 10 AM)'),
              ),
              TextField(
                controller: taskListController,
                decoration: const InputDecoration(labelText: 'Tasks (comma separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final tasks = taskListController.text
                    .split(',')
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .collection('timeblocks')
                    .add({
                  'day': dayController.text.trim(),
                  'timeRange': timeRangeController.text.trim(),
                  'tasks': tasks,
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddTimeBlockDialog(context),
            child: const Text('Add Time Block'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final taskDocs = snapshot.data!.docs;

                if (taskDocs.isEmpty) {
                  return const Center(child: Text('No tasks yet!'));
                }

                return ListView.builder(
                  itemCount: taskDocs.length,
                  itemBuilder: (context, index) {
                    final doc = taskDocs[index];
                    final task = Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);

                    return ListTile(
                      title: Text(
                        task.name,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _toggleTaskCompletion(task.id, task.isCompleted),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.uid)
                  .collection('timeblocks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Error loading time blocks');
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final timeBlocks = snapshot.data!.docs.map((doc) {
                  return TimeBlockTask.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: timeBlocks.length,
                  itemBuilder: (context, index) {
                    final tb = timeBlocks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('${tb.day} - ${tb.timeRange}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: tb.tasks.map((t) => Text('• $t')).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
