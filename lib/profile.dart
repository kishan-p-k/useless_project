import 'package:flutter/material.dart';
import 'package:gtodo/home.dart';
import 'package:gtodo/login.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for gamified theme
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
            }
          },
        ),
        backgroundColor: Colors.blueAccent,
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 20),
            _buildTaskSummary(),
            const SizedBox(height: 20),
            _buildRecentActivities(),
            const SizedBox(height: 20),
            _buildSettingsButton(context), // New settings button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.logout), // Logout icon
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Row(
      children: [
        // Solid color circle replacing the avatar image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purpleAccent, // Solid color for the avatar
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Doe', // Placeholder for the user's name
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Points: 1200', // Placeholder for user points
              style: TextStyle(fontSize: 16, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {}, // Functionality for upgrading avatar
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Upgrade Avatar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTaskCard('Completed', 25, Colors.green),
        _buildTaskCard('Skipped', 5, Colors.yellow),
        _buildTaskCard('Missed', 3, Colors.red),
      ],
    );
  }

  Widget _buildTaskCard(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _buildActivityTile('Completed: Daily Workout', 'Today'),
        _buildActivityTile('Skipped: Reading Task', 'Yesterday'),
        _buildActivityTile('Missed: Grocery Shopping', '2 Days Ago'),
      ],
    );
  }

  Widget _buildActivityTile(String title, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        date,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the settings page (to be implemented)
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text('Settings'), // Placeholder for settings button
      ),
    );
  }
}
