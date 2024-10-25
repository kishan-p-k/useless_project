import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for gamified theme
      appBar: AppBar(
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
          ],
        ),
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
              'John Doe',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Points: 1200',
              style: TextStyle(fontSize: 16, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
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
}
