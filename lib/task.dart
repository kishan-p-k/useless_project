import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _priority = 1;

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

  // First confirmation dialog
  Future<bool> _showFirstConfirmation() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Complete Task'),
              content:
                  Text('Are you sure you want to mark this task as complete?'),
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

  // Second confirmation dialog
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
  Future<void> _completeTask(String documentId, String taskId) async {
    bool firstConfirm = await _showFirstConfirmation();
    if (firstConfirm) {
      bool secondConfirm = await _showSecondConfirmation();
      if (secondConfirm) {
        try {
          await _firestore.collection('tasks').doc(documentId).update({
            'isDone': true,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task completed successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error completing task: $e')),
          );
        }
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
            // Task List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .orderBy('priority', descending: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks available',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              data['priority'].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            data['description'],
                            style: TextStyle(
                              decoration: data['isDone'] == true
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: data['isDone'] == true
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Checkbox(
                                  value: false,
                                  onChanged: (bool? value) {
                                    if (value == true) {
                                      _completeTask(doc.id, data['taskId']);
                                    }
                                  },
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Add Task Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addTask(taskController.text),
                      ),
                    ),
                    onSubmitted: _addTask,
                  ),
                  SizedBox(height: 16),

                  // Priority Slider
                  Row(
                    children: [
                      Text('Priority: '),
                      Expanded(
                        child: Slider(
                          value: _priority.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _priority.toString(),
                          onChanged: (double value) {
                            setState(() {
                              _priority = value.round();
                            });
                          },
                        ),
                      ),
                      Text(_priority.toString()),
                    ],
                  ),

                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_task),
                    label: Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () => _addTask(taskController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
