import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final List<String> tasks = [];
  final TextEditingController taskController = TextEditingController();

  // Function to add a task
  void _addTask(String task) {
    if (task.isNotEmpty) {
      setState(() {
        tasks.add(task);
      });
      taskController.clear();
    }
  }

  // Function to delete a task
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tasks'),
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
                        onPressed: () => _deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _addTask,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addTask(taskController.text),
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
