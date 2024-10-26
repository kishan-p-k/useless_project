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
  int _priority = 1;
  int _userPoints = 0;
  int _userLevel = 1;

  // Evolution constants
  final int firstEvolutionLevel = 20;
  final int secondEvolutionLevel = 45;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String getPokemonGif(int level) {
    if (level > secondEvolutionLevel) {
      return 'assets/char3.gif';
    } else if (level >= 45) {
      return 'assets/char3_1.gif';
    } else if (level >= 25) {
      return 'assets/chr2.gif';
    } else if (level >= firstEvolutionLevel) {
      return 'assets/char2_2.gif';
    } else if (level >= 18) {
      return 'assets/char1_5.gif';
    } else if (level >= 10) {
      return 'assets/char1_4.gif';
    } else if (level >= 5) {
      return 'assets/char1_3.gif';
    } else if (level >= 2) {
      return 'assets/char1_2.gif';
    } else {
      return 'assets/char1_1.gif';
    }
  }

  Future<void> _loadUserData() async {
    final userDoc =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();

    if (userDoc.exists) {
      setState(() {
        _userPoints = userDoc.data()?['points'] ?? 0;
        _userLevel = userDoc.data()?['level'] ?? 1;
      });
    } else {
      // Create user document if it doesn't exist
      await _firestore.collection('users').doc(_auth.currentUser?.uid).set({
        'points': 0,
        'level': 1,
        'email': _auth.currentUser?.email,
        'username': _auth.currentUser?.displayName ?? 'User',
      });
    }
  }

  Future<void> _updateUserPoints(int pointsToAdd) async {
    final userRef = _firestore.collection('users').doc(_auth.currentUser?.uid);

    // Update points in Firestore using transaction for accuracy
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        transaction.set(userRef, {
          'points': pointsToAdd,
          'level': 1,
          'email': _auth.currentUser?.email,
          'username': _auth.currentUser?.displayName ?? 'User',
        });
        setState(() {
          _userPoints = pointsToAdd;
        });
      } else {
        final currentPoints = userDoc.data()?['points'] ?? 0;
        final newPoints = currentPoints + pointsToAdd;
        transaction.update(userRef, {
          'points': newPoints,
        });
        setState(() {
          _userPoints = newPoints;
        });
      }
    });

    // Check if user can level up
    await _checkForLevelUp();
  }

  Future<void> _checkForLevelUp() async {
    int pointsNeeded = _userLevel * 2;

    if (_userPoints >= pointsNeeded) {
      // Calculate new level based on points
      int newLevel = _userLevel + 1;

      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        'level': newLevel,
      });

      setState(() {
        _userLevel = newLevel;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Level Up! You are now level $_userLevel'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

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

  Future<void> _addTask(String task) async {
    if (task.isNotEmpty) {
      try {
        final String taskId = _generateTaskId();

        await _firestore.collection('tasks').add({
          'userId': _auth.currentUser?.uid,
          'email': _auth.currentUser?.email,
          'taskId': taskId,
          'description': task,
          'priority': _priority,
          'createdAt': FieldValue.serverTimestamp(),
          'isDone': false,
          'isSkipped': false,
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

  Future<void> _completeTask(String docId, int priority) async {
    try {
      // Delete the task
      await _firestore.collection('tasks').doc(docId).delete();

      // Add points equal to priority
      await _updateUserPoints(priority);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task completed! Earned $priority points!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing task: $e')),
      );
    }
  }

  Future<void> _skipTask(String docId) async {
    try {
      await _firestore.collection('tasks').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task skipped')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error skipping task: $e')),
      );
    }
  }

  int getPointsToNextLevel() {
    return (_userLevel * 2) - (_userPoints % (_userLevel * 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.blue,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          getPokemonGif(_userLevel),
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Lvl $_userLevel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.stars, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    '$_userPoints pts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Points to next level indicator
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Points to next level: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '${getPointsToNextLevel()}',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .where('isDone', isEqualTo: false)
                    .where('isSkipped', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

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
                      final priority = task['priority'] as int;

                      return Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        color: Colors.blue.withOpacity(0.2),
                        child: ListTile(
                          title: Text(
                            task['description'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Priority: $priority',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.stars,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(
                                '+$priority pts',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _completeTask(task.id, priority),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.skip_next,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _skipTask(task.id),
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add_task, color: Colors.blue),
                              onPressed: () => _addTask(taskController.text),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Priority: $_priority',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Slider(
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
                      ),
                    ],
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
