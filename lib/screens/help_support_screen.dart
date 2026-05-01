import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../global_state.dart';

class HelpSupportScreen extends StatefulWidget {
  final bool showTicket;
  const HelpSupportScreen({super.key, this.showTicket = false});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
    
    if (widget.showTicket) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRaiseTicketDialog(context);
      });
    }
  }

  Future<void> _fetchTickets({VoidCallback? onUpdate}) async {
    final tickets = await ApiService.getUserTickets(GlobalState.mobile);
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
      if (onUpdate != null) onUpdate();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    int hour = date.hour;
    String period = "AM";
    if (hour >= 12) {
      period = "PM";
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    
    final timeStr = "$hour:${date.minute.toString().padLeft(2, '0')} $period";
    
    if (difference.inDays == 0 && now.day == date.day) {
      return "Today, $timeStr";
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return "Yesterday, $timeStr";
    } else {
      return "${date.day}/${date.month}/${date.year}, $timeStr";
    }
  }

  List<Map<String, dynamic>> _getAdminRepliesFromLast7Days() {
    final List<Map<String, dynamic>> allReplies = [];
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    for (var ticket in _tickets) {
      if (ticket['replies'] != null) {
        for (var reply in ticket['replies']) {
          if (reply['senderType'] == 'Admin') {
            final replyDate = DateTime.tryParse(reply['createdAt'] ?? '')?.toLocal();
            if (replyDate != null) {
              final isRecent = replyDate.isAfter(sevenDaysAgo);
              if (isRecent) {
                allReplies.add({
                  'ticketId': ticket['_id'],
                  'subject': ticket['subject'],
                  'message': reply['message'],
                  'date': replyDate,
                });
              }
            }
          }
        }
      }
    }
    // Sort by most recent
    allReplies.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return allReplies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Help & Support', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF1A73E8)),
                onPressed: () => _showRepliesBottomSheet(context),
              ),
              if (_getAdminRepliesFromLast7Days().isNotEmpty)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help?', style: TextStyle(color: Color(0xFF1A73E8), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Choose an option below to get assistance.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 32),

            // Chat Support
            _buildSupportTile(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Chat Support',
              subtitle: 'Chat with us on WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () {
                debugPrint('Redirecting to WhatsApp...');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening WhatsApp...')),
                );
              },
            ),
            const SizedBox(height: 16),

            // Raise a Ticket
            _buildSupportTile(
              context,
              icon: Icons.confirmation_number_outlined,
              title: 'Raise a Ticket',
              subtitle: 'Submit your issue for review',
              color: const Color(0xFFF47920),
              onTap: () => _showRaiseTicketDialog(context),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildFAQTile('How do I start receiving orders?', 'Once your profile is verified, orders will automatically appear on your Home screen under "New Orders".'),
            _buildFAQTile('How do I update my documents?', 'Go to My Profile and click "Request Profile Update". Our team will review and update your documents.'),
            _buildFAQTile('When will I receive my earnings?', 'Earnings are settled weekly. You can track your balance in the Wallet section.'),
            _buildFAQTile('How do I change my vehicle type?', 'Contact our support team through WhatsApp chat or raise a ticket for vehicle changes.'),
            _buildFAQTile('What are subscription benefits?', 'Subscriptions unlock higher daily ride limits, priority bookings, and bonus incentives.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [Text(answer, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))],
      ),
    );
  }

  void _showRepliesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AdminRepliesSheet(
        mobile: GlobalState.mobile,
        formatDate: _formatDate,
      ),
    );
  }

  void _showRaiseTicketDialog(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 30),
              const Text('Raise a Ticket', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF47920))),
              const SizedBox(height: 20),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Describe your issue',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (subjectController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in both subject and message.')),
                      );
                      return;
                    }

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF47920))),
                    );

                    final success = await ApiService.raiseTicket(
                      subjectController.text.trim(),
                      descController.text.trim(),
                    );

                    // Hide loading
                    Navigator.pop(context);

                    if (success) {
                      Navigator.pop(context); // Close bottom sheet
                      _fetchTickets(); // Refresh tickets list to include new ticket
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ticket raised successfully! We\'ll get back to you soon.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to raise ticket. Please try again later.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF47920),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminRepliesSheet extends StatefulWidget {
  final String mobile;
  final String Function(DateTime) formatDate;

  const _AdminRepliesSheet({required this.mobile, required this.formatDate});

  @override
  State<_AdminRepliesSheet> createState() => _AdminRepliesSheetState();
}

class _AdminRepliesSheetState extends State<_AdminRepliesSheet> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final tickets = await ApiService.getUserTickets(widget.mobile);
    
    if (mounted) {
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getAdminReplies() {
    final List<Map<String, dynamic>> allReplies = [];
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    for (var ticket in _tickets) {
      if (ticket['replies'] != null) {
        for (var reply in ticket['replies']) {
          if (reply['senderType'] == 'Admin') {
            final replyDate = DateTime.tryParse(reply['createdAt'] ?? '')?.toLocal();
            if (replyDate != null && replyDate.isAfter(sevenDaysAgo)) {
              allReplies.add({
                'subject': ticket['subject'],
                'message': reply['message'],
                'date': replyDate,
              });
            }
          }
        }
      }
    }
    allReplies.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return allReplies;
  }

  @override
  Widget build(BuildContext context) {
    final replies = _getAdminReplies();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Admin Replies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Recent replies from the last 7 days', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
                : replies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No recent replies found', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: replies.length,
                        itemBuilder: (context, index) {
                          final reply = replies[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Ref: ${reply['subject']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A73E8)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      widget.formatDate(reply['date']),
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reply['message'],
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text('- Admin Support', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
