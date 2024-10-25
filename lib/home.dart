import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:gtodo/login.dart'; // Import the login page for navigation
import 'package:gtodo/profile.dart'; // Import the profile page for navigation

class HomePage extends StatelessWidget {
  final List<String> tasks = []; // Sample list of tasks
  final TextEditingController _taskController =
      TextEditingController(); // Controller for the TextField
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('To-Do List'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) {
              if (value == 'profile') {
                // Navigate to Profile Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'logout') {
                // Handle logout logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(tasks[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Handle delete task
                          tasks.removeAt(index);
                          // Note: You would typically use setState or state management here to refresh the UI
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final taskDescription = _taskController.text;
                if (taskDescription.isNotEmpty) {
                  // Generate a unique ID (you can use the document ID from Firestore)
                  String taskId = _firestore.collection('tasks').doc().id;

                  // Add task to Firestore
                  await _firestore.collection('tasks').doc(taskId).set({
                    'createdAt': FieldValue
                        .serverTimestamp(), // Automatically sets the timestamp
                    'description': taskDescription,
                    'id': taskId,
                    'isDone': false,
                  });

                  // Clear the TextField
                  _taskController.clear();
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
