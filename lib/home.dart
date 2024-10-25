import 'package:flutter/material.dart';
import 'package:gtodo/login.dart'; // Import the login page for navigation
import 'package:gtodo/profile.dart'; // Import the profile page for navigation

class HomePage extends StatelessWidget {
  final List<String> tasks = []; // Sample list of tasks

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
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Navigate back to the login page
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
              decoration: InputDecoration(
                labelText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  // Add new task
                  tasks.add(value);
                  // Note: You would typically use setState or state management here to refresh the UI
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // You can add more logic here if needed
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
