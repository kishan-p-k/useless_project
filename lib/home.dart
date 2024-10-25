import 'package:flutter/material.dart';
import 'package:gtodo/login.dart';
import 'package:gtodo/profile.dart';
import 'package:gtodo/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final String username; // To hold the username
  final int points; // To hold user points
  final int completed; // To hold completed tasks count
  final int skipped; // To hold skipped tasks count
  final int missed; // To hold missed tasks count

  HomePage({
    required this.username,
    required this.points,
    required this.completed,
    required this.skipped,
    required this.missed,
  });

  final TextEditingController _taskController = TextEditingController(); // Controller for task input
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance to get the user ID

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (_auth.currentUser == null) {
      return Scaffold(
        body: Center(child: Text('Please log in.')),
      );
    }

    String userId = _auth.currentUser!.uid; // Safely get user ID

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile - $username'), // Displaying the username in the app bar
        actions: [
          // Other actions...
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display user information
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      username[0].toUpperCase(), // Display first letter of the username
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Points: $points',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Completed: $completed | Skipped: $skipped | Missed: $missed',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // List of tasks fetched from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('tasks').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks available.'));
                  }

                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(task['description']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await _firestore
                                  .collection('tasks')
                                  .doc(task.id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input field to add new tasks
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Button to add tasks to Firestore
            ElevatedButton(
              onPressed: () async {
                final taskDescription = _taskController.text;
                if (taskDescription.isNotEmpty) {
                  await _firestore.collection('tasks').add({
                    'description': taskDescription,
                    'createdAt': FieldValue.serverTimestamp(),
                    'isDone': false,
                    'userId': userId, // Add user ID to the task
                  });
                  _taskController.clear(); // Clear input after adding task
                }
              },
              child: Text('Add Task'),
            ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Level: 5',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Equipment: Sword, Shield, Armor',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),

      // Floating Action Button at bottom center for navigating to TaskPage
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskPage()),
          );
        },
        child: Icon(Icons.task),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(), // Notched to fit the FAB
        child: Container(height: 50), // Placeholder for styling
      ),
    );
  }
}

