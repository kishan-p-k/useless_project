import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _priority = 1; // Default priority

  // Generate a random string of specified length
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Generate a unique task ID
  String _generateTaskId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomString = _generateRandomString(6);
    return 'TASK-$timestamp-$randomString';
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  // Function to add a task with auto-generated ID
  Future<void> _addTask(String task) async {
    if (task.isNotEmpty) {
      try {
        final String taskId = _generateTaskId();
        await _firestore.collection('tasks').add({
          'taskId': taskId,
          'description': task,
          'priority': _priority,
          'createdAt': FieldValue.serverTimestamp(),
          'isDone': false,
          'isSkipped': false,
          'completed': false,
          'skipped': false,
        });
        taskController.clear();
        setState(() {
          _priority = 1; // Reset priority to 1 after adding task
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    }
  }

  // Function to clear completed and skipped tasks
  Future<void> _clearCompletedTasks() async {
    try {
      // Get all completed and skipped tasks
      QuerySnapshot completedTasks = await _firestore
          .collection('tasks')
          .where('isDone', isEqualTo: true)
          .get();

      QuerySnapshot skippedTasks = await _firestore
          .collection('tasks')
          .where('isSkipped', isEqualTo: true)
          .get();

      // Combine both lists of documents
      List<DocumentSnapshot> allTasksToDelete = []
        ..addAll(completedTasks.docs)
        ..addAll(skippedTasks.docs);

      // Delete each document
      for (var doc in allTasksToDelete) {
        await _firestore.collection('tasks').doc(doc.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completed and skipped tasks cleared!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing tasks: $e')),
      );
    }
  }

  // First confirmation dialog for completing tasks
  Future<bool> _showFirstConfirmation(String message) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Second confirmation dialog for final confirmation
  Future<bool> _showSecondConfirmation() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Final Confirmation'),
              content: Text(
                  'Are you absolutely sure? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes, Complete It'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Complete task function with double confirmation
  Future<void> _completeTask(
      String documentId, String taskId, int priority) async {
    bool firstConfirm = await _showFirstConfirmation('Complete Task');
    if (firstConfirm) {
      bool secondConfirm = await _showSecondConfirmation();
      if (secondConfirm) {
        try {
          // Mark the task as done
          await _firestore.collection('tasks').doc(documentId).update({
            'isDone': true,
            'completed': true,
            'skipped': false,
          });

          // Update user points based on priority
          String userId = _auth.currentUser!.uid; // Get current user's ID
          int pointsToAdd = priority * 10; // Assign points based on priority
          await _firestore.collection('users').doc(userId).update({
            'points': FieldValue.increment(pointsToAdd),
            'completed': FieldValue.increment(1),
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Task completed successfully! $pointsToAdd points added!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error completing task: $e')),
          );
        }
      }
    }
  }

  // Skip task function with penalty
  Future<void> _skipTask(String documentId, int priority) async {
    int pointsToDeduct = priority * 5; // Calculate points deduction

    bool confirm = await _showFirstConfirmation(
        'Are you sure you want to skip this task? This will deduct $pointsToDeduct points from your total.');
    if (confirm) {
      try {
        // Mark the task as skipped
        await _firestore.collection('tasks').doc(documentId).update({
          'isSkipped': true,
          'skipped': true,
          'completed': false,
        });

        // Deduct points from the user
        String userId = _auth.currentUser!.uid; // Get current user's ID
        await _firestore.collection('users').doc(userId).update({
          'points': FieldValue.increment(-pointsToDeduct),
          'skipped': FieldValue.increment(1),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task skipped successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error skipping task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Priority Slider
            Text('Priority: $_priority'),
            Slider(
              value: _priority.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _priority.toString(),
              onChanged: (value) {
                setState(() {
                  _priority = value.toInt();
                });
              },
            ),
            SizedBox(height: 20), // Spacer
            // Task List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .orderBy('priority', descending: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final tasks = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return ListTile(
                        title: Text(
                          task['description'],
                          style: TextStyle(
                            color: task['isDone'] ? Colors.white : (task['isSkipped'] ? Colors.red : Colors.white),
                            decoration: task['isDone'] ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Priority: ${task['priority']}',
                          style: TextStyle(
                            color: task['isDone'] ? Colors.white : (task['isSkipped'] ? Colors.red : Colors.white),
                            decoration: task['isDone'] ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        trailing: task['isDone'] 
                            ? null // Remove trailing buttons if the task is done
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!task['isSkipped']) ...[
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        _completeTask(task.id, task['taskId'], task['priority']);
                                      },
                                    ),
                                  ],
                                  IconButton(
                                    icon: Icon(Icons.skip_next),
                                    onPressed: () {
                                      _skipTask(task.id, task['priority']);
                                    },
                                  ),
                                ],
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Spacer
            // Add Task Field
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Enter Task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10), // Spacer
            ElevatedButton(
              onPressed: () {
                _addTask(taskController.text);
              },
              child: Text('Add Task'),
            ),
            SizedBox(height: 10), // Spacer
            ElevatedButton(
              onPressed: _clearCompletedTasks,
              child: Text('Clear Completed & Skipped Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
