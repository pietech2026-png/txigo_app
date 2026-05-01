import 'package:flutter/material.dart';

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});

  final List<Map<String, dynamic>> incentives = const [
    {
      'title': '10 Rides Milestone',
      'description': 'Complete 10 rides today',
      'reward': '₹200 Bonus',
      'progress': 0.3,
      'current': 3,
      'target': 10,
    },
    {
      'title': '5-Star Rating',
      'description': 'Maintain 5-star for 20 rides',
      'reward': '₹500 Bonus',
      'progress': 0.6,
      'current': 12,
      'target': 20,
    },
    {
      'title': 'Weekly Champion',
      'description': 'Complete 50 rides this week',
      'reward': '₹1,500 Bonus',
      'progress': 0.1,
      'current': 5,
      'target': 50,
    },
    {
      'title': 'Peak Hour Hero',
      'description': 'Complete 5 rides during peak hours',
      'reward': '₹300 Bonus',
      'progress': 0.0,
      'current': 0,
      'target': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Incentives', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earn More', style: TextStyle(color: Color(0xFFF47920), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Complete milestones to unlock bonus rewards.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 8),

            // Total earnings card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF47920), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Incentives Earned', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('₹0.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Active Challenges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            ...incentives.map((inc) => _buildIncentiveCard(inc)),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveCard(Map<String, dynamic> inc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(inc['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF47920).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(inc['reward'], style: const TextStyle(color: Color(0xFFF47920), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(inc['description'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: inc['progress'],
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF47920)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${inc['current']}/${inc['target']} completed',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
