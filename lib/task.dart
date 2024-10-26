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

  Future<void> _addTask(String task) async {
    if (task.isNotEmpty) {
      try {
        final String taskId = _generateTaskId();
        final String userEmail = _auth.currentUser!.email!; // Get user email

        await _firestore.collection('tasks').add({
          'email': userEmail, // Use 'email' instead of 'userEmail'
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
          _priority = 1;
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

  Future<void> _completeTask(String docId) async {
    try {
      await _firestore.collection('tasks').doc(docId).update({
        'isDone': true,
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task marked as complete!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing task: $e')),
      );
    }
  }

  Future<void> _skipTask(String docId) async {
    try {
      await _firestore.collection('tasks').doc(docId).update({
        'isSkipped': true,
        'skipped': true,
        'skippedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task skipped!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error skipping task: $e')),
      );
    }
  }

  Future<void> _clearCompletedTasks() async {
    try {
      final String userEmail = _auth.currentUser!.email!; // Get user email
      QuerySnapshot completedTasks = await _firestore
          .collection('tasks')
          .where('isDone', isEqualTo: true)
          .where('email',
              isEqualTo: userEmail) // Use 'email' instead of 'userEmail'
          .get();

      QuerySnapshot skippedTasks = await _firestore
          .collection('tasks')
          .where('isSkipped', isEqualTo: true)
          .where('email',
              isEqualTo: userEmail) // Use 'email' instead of 'userEmail'
          .get();

      List<DocumentSnapshot> allTasksToDelete = []
        ..addAll(completedTasks.docs)
        ..addAll(skippedTasks.docs);

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

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = _auth.currentUser?.email ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Priority: $_priority',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
              activeColor: Colors.blue,
              inactiveColor: Colors.blue.withOpacity(0.3),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('email',
                        isEqualTo:
                            currentUserEmail) // Use 'email' instead of 'userEmail'
                    // .orderBy('priority', descending: true)
                    //  .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Handle errors
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data!.docs;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks yet. Add some!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        color: Colors.blue.withOpacity(0.2),
                        child: ListTile(
                          title: Text(
                            task['description'],
                            style: TextStyle(
                              color: task['isDone']
                                  ? Colors.grey
                                  : (task['isSkipped']
                                      ? Colors.red
                                      : Colors.white),
                              decoration: task['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Priority: ${task['priority']}',
                            style: TextStyle(
                              color: task['isDone']
                                  ? Colors.grey
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ),
                          trailing: task['isDone']
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!task['isSkipped']) ...[
                                      IconButton(
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          _completeTask(task.id);
                                        },
                                      ),
                                    ],
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        _skipTask(task.id);
                                      },
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Enter Task',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addTask(taskController.text);
                    },
                    child: Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearCompletedTasks,
                    child: Text('Clear Completed & Skipped Tasks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
