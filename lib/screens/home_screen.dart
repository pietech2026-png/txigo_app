import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_screen.dart';
import 'my_profile_screen.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';
import 'help_support_screen.dart';
import 'incentives_screen.dart';
import '../global_state.dart';
import 'document_hub_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _cancellationReasonController = TextEditingController();

  static const Color txigoBlue = Color(0xFF1A73E8);
  static const Color txigoDark = Color(0xFF1A1A2E);
  static const Color oliveGreen = Color(0xFF8B8000);
  static const Color goldenrod = Color(0xFFDAA520);

  // Dynamic booking data
  List<Map<String, dynamic>> newOrders = [];
  List<Map<String, dynamic>> confirmedOrders = [];
  bool _isLoading = true;

  // Notification state
  Timer? _notificationTimer;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAndPopulateData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMissedBookingsPopup();
      _checkForNotifications();
    });
    _startNotificationPolling();
  }

  Future<void> _fetchAndPopulateData() async {
    setState(() => _isLoading = true);
    try {
      // 0. Fetch User Profile to get Wallet Balance
      await ApiService.fetchUserProfile(GlobalState.mobile);

      // 1. Fetch Shared Available Bookings for "Upcoming" tab
      final availableRaw = await ApiService.fetchBookings(isAvailable: true);
      final List<Map<String, dynamic>> availableFormatted = _mapApiRides(availableRaw);

      // 2. Fetch My Private Accepted Bookings for "Confirmed" tab
      final confirmedRaw = await ApiService.fetchBookings(mobile: GlobalState.mobile);
      final List<Map<String, dynamic>> confirmedFormatted = _mapApiRides(confirmedRaw, status: 'CONFIRMED');

      setState(() {
        newOrders = availableFormatted;
        confirmedOrders = confirmedFormatted;
        _isLoading = false;
      });
    } catch (e) {
      print('Error populating bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _mapApiRides(List<dynamic> rawData, {String status = 'PENDING'}) {
    return rawData.map((item) {
      final pricing = item['pricing'] ?? {};
      final extra = pricing['extraCharges'] ?? {};
      
      return {
        'id': item['_id'] ?? '',
        'bookingId': (item['_id'] ?? '').toString().substring(0, 4).toUpperCase(),
        'price': '₹${pricing['totalFare'] ?? 0}',
        'rawPrice': (pricing['totalFare'] ?? 0).toDouble(),
        'rideType': '${item['serviceType'] ?? 'Outstation'} ${item['wayType'] != null ? '(${item['wayType']})' : ''}',
        'serviceType': item['serviceType'] ?? 'Outstation',
        'wayType': item['wayType'],
        'extraKm': '₹${extra['extraKm'] ?? 0}/km',
        'extraHour': '₹150/hr', 
        'nightAllowance': '₹${extra['nightAllowance'] ?? 0}',
        'pickup': item['pickup']?['address'] ?? 'Not provided',
        'drop': item['drop']?['address'] ?? 'Not provided',
        'pickupDate': _formatISO(item['pickupTime'], isTime: false),
        'pickupTime': _formatISO(item['pickupTime'], isTime: true),
        'returnDate': _formatISO(item['returnTime'], isTime: false),
        'returnTime': _formatISO(item['returnTime'], isTime: true),
        'distance': pricing['distance'] != null ? '${pricing['distance']} km' : '—',
        'rentalPackage': item['rentalPackage'],
        'airportDirection': item['airportDirection'],
        'customer': item['customerName'] ?? 'User',
        'status': status,
      };
    }).toList();
  }

  String _formatISO(String? iso, {bool isTime = false}) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      if (isTime) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final minute = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        return '${hour.toString().padLeft(2, '0')}:$minute $ampm';
      } else {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (e) {
      return iso;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cancellationReasonController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationPolling() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkForNotifications();
    });
  }

  Future<void> _checkForNotifications() async {
    if (GlobalState.driverId.isEmpty) return; // Wait for profile fetch
    
    final notifications = await ApiService.fetchNotifications(driverId: GlobalState.driverId);
    if (!mounted) return;

    final newUnread = notifications.where((n) => n['isRead'] == false).toList();
    
    // If there's a new notification, check if we should show a popup
    if (newUnread.length > _unreadCount) {
      final latest = newUnread.first;
      if (latest['type'] == 'Cancellation') {
        _showCancellationPopup(latest['title'], latest['message']);
        _fetchAndPopulateData(); // Refresh list to remove cancelled rides
      }
    }

    setState(() {
      _notifications = notifications;
      _unreadCount = newUnread.length;
    });
  }

  void _showCancellationPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: txigoBlue),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: _notifications.isEmpty
              ? const Center(child: Text('No new notifications'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        n['type'] == 'Cancellation' ? Icons.cancel_outlined : Icons.notifications_none, 
                        color: n['isRead'] ? Colors.grey : txigoBlue
                      ),
                      title: Text(n['title'], style: TextStyle(fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                      subtitle: Text(n['message'], style: const TextStyle(fontSize: 12)),
                      trailing: n['isRead'] ? null : const Icon(Icons.circle, color: Colors.blue, size: 8),
                      onTap: () async {
                        await ApiService.markNotificationAsRead(n['_id']);
                        Navigator.pop(context);
                        _checkForNotifications();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
        ],
      ),
    );
  }

  void _showMissedBookingsPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: txigoBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active, size: 50, color: Color(0xFF1A73E8)),
              ),
              const SizedBox(height: 20),
              const Text('100+ Bookings Missed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'You have missed over 100 booking requests. Stay online to accept more rides and maximize your earnings!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: txigoBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _acceptRide(int index) async {
    // Basic local check for plan (can stay as a shortcut, but backend will also verify)
    if (GlobalState.selectedPlan.toLowerCase() == 'none' || GlobalState.selectedPlan == null) {
      _showSubscriptionRequiredDialog();
      return;
    }

    // Check Wallet Balance: Block if negative
    if (GlobalState.walletBalance < 0) {
      _showLowBalanceDialog();
      return;
    }

    final order = newOrders[index];
    final String bookingId = order['id'] ?? "";
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: txigoBlue)),
    );

    try {
      // Sync Booking Status with Backend
      final result = await ApiService.acceptBooking(bookingId, GlobalState.mobile);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        // Success case
        final price = order['rawPrice'] ?? 0.0;
        final calculatedCommission = price * 0.10;
        final commission = calculatedCommission > 100 ? calculatedCommission : 100.0;

        setState(() {
          newOrders.removeAt(index);
          order['status'] = 'CONFIRMED';
          confirmedOrders.add(order);
        });

        await ApiService.updateWalletBalance(
          amount: -commission,
          category: 'Commission',
          description: 'Accepted Booking ${order['bookingId']}',
        );

        _showSuccessDialog();
      } else {
        // Error handling based on backend codes
        final String errorMsg = result['message'];
        
        if (errorMsg == 'SUBSCRIPTION_REQUIRED') {
          _showSubscriptionRequiredDialog();
        } else if (errorMsg == 'LATE_ORDER_ACCEPTED') {
          // Requirement 4 & 6: "Sorry, You are Late! Another Driver has Accepted the Order."
          _showLateDialog(index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print('Error in _acceptRide: $e');
    }
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Subscription Required', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text('Please select a Subscription Plan to accept this order.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: txigoBlue),
            child: const Text('Choose Plan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLowBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Low Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 40, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              'Your current balance is ₹${GlobalState.walletBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your wallet balance is negative. Please recharge your wallet to at least ₹0 to continue accepting new rides.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: txigoBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Recharge Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLateDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sorry, You are Late!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: const Text('Another Driver has Accepted the Order.', textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  if (index < newOrders.length) {
                    newOrders.removeAt(index);
                  }
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: txigoBlue),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Congratulations 🎉', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A73E8))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You have Accepted the Order', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _tabController.animateTo(1); // Redirect to Confirmed orders
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _cancelRide(int index) async {
    _cancellationReasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Ride?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this ride? The commission will be refunded to your wallet.'),
            const SizedBox(height: 16),
            TextField(
              controller: _cancellationReasonController,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
          ElevatedButton(
            onPressed: () async {
              final reason = _cancellationReasonController.text.trim();
              Navigator.pop(context);
              await _processCancellation(index, reason: reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processCancellation(int index, {String? reason}) async {
    final order = confirmedOrders[index];
    final price = order['rawPrice'] ?? 0.0;
    
    // Commission is 10% of price or ₹100, whichever is higher
    final calculatedCommission = price * 0.10;
    final commission = calculatedCommission > 100 ? calculatedCommission : 100.0;

    try {
      final success = await ApiService.cancelBooking(order['id'] ?? "", reason: reason);
      if (success) {
        // Charge 100rs Cancellation Fee instead of refunding
        await ApiService.updateWalletBalance(
          amount: -100.0,
          category: 'Cancellation Fee',
          description: 'Pilot Cancelled Booking ${order['bookingId']}',
        );

        setState(() {
          confirmedOrders.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Cancelled and Commission Refunded'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel ride'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      print('Error cancelling ride: $e');
    }
  }

  Future<void> _completeRide(int index) async {
    final order = confirmedOrders[index];
    
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ApiService.completeBooking(order['id'] ?? "");
      if (mounted) Navigator.pop(context); // Dismiss loading

      if (success) {
        setState(() {
          confirmedOrders.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride Completed Successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete ride'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print('Error completing ride: $e');
    }
  }

  void _transferRide(int index, bool isNew) {
    setState(() {
      if (isNew) {
        newOrders.removeAt(index);
      } else {
        confirmedOrders.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ride Transferred'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F7F7),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Updated Professional AppBar (Blue)
            Container(
              color: txigoBlue,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Increased height for visibility
              child: Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Upcoming Rides',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.white, size: 28),
                        if (_unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '$_unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showNotificationsDialog,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Styled Tab Bar (Blue)
            Container(
              color: txigoBlue,
              child: TabBar(
                controller: _tabController,
                indicatorColor: goldenrod,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Confirmed'),
                ],
              ),
            ),



            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(newOrders, isNew: true),
                  _buildOrdersList(confirmedOrders, isNew: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders, {required bool isNew}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: txigoBlue));
    }

    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchAndPopulateData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  isNew ? 'No upcoming rides available' : 'No confirmed rides yet',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAndPopulateData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 100), // Increased bottom padding for visibility
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(orders[index], index, isNew);
        },
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡 ', style: TextStyle(fontSize: 20)),
              Text(
                'Get more rides with TXIGO Pro',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBullet('Priority ride alerts'),
          _buildBullet('Faster booking access'),
          _buildBullet('Higher earnings'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: txigoBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Subscribe Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF1A73E8), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
            ),
          ),
          Expanded(child: Divider(color: Colors.black.withOpacity(0.2), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> order, int index, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: #${order['bookingId']} • ${order['pickupDate'] ?? ''}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (order['status'] ?? 'PENDING').toUpperCase(),
                    style: const TextStyle(color: Color(0xFFB8860B), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['rideType'] ?? 'Out Station',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      if ((order['serviceType'] ?? '').toString().contains('Rental') && order['rentalPackage'] != null)
                        Text(
                          'Package: ${order['rentalPackage']}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      if ((order['serviceType'] ?? '').toString().contains('Airport') && order['airportDirection'] != null)
                        Text(
                          'Direction: ${order['airportDirection']}',
                          style: TextStyle(color: txigoBlue, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                Text(
                  order['price'] ?? '₹0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ],
            ),
            
            // VERY SMALL: Rates (Moved back below Type)
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildSmallRateField('Night Allowance', order['nightAllowance']),
                _buildSmallRateField('Extra Km', order['extraKm']),
                _buildSmallRateField('Extra Hr', order['extraHour']),
              ],
            ),
            
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, thickness: 1),
            const SizedBox(height: 12),

            // MAIN: Route Section (Vertical Mockup Style)
            _buildVerticalRoute(order['pickup'] ?? '', order['drop'] ?? '', order['distance'] ?? '—'),
            
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100, thickness: 1),
            const SizedBox(height: 12),

            // MAIN: Schedule (Conditional for Round Trip vs One Way)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.access_time_filled, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScheduleLine('Pickup', '${order['pickupDate']} at ${order['pickupTime']}'),
                      if ((order['wayType'] ?? '').toString().toLowerCase().contains('round') || (order['rideType'] ?? '').toString().toLowerCase().contains('round'))
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _buildScheduleLine('Return', '${order['returnDate']} at ${order['returnTime']}'),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // MINIMIZED: Customer Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, size: 16, color: Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['customer'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Cash', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Main Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isNew ? () => _acceptRide(index) : () => _cancelRide(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNew ? Colors.green.shade800 : Colors.red.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(isNew ? 'Accept Ride' : 'Cancel Ride', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isNew ? () => _transferRide(index, isNew) : () => _completeRide(index),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isNew ? Colors.red.shade700 : Colors.green.shade800,
                      side: BorderSide(color: isNew ? Colors.red.shade100 : Colors.green.shade100, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isNew ? 'Transfer' : 'Completed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalRoute(String pickup, String drop, String distance) {
    return Column(
      children: [
        // Pickup row
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pickup.split(',').first,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // Connector row with Distance Pill
        Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 2,
              height: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                distance,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),

        // Drop row
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.redAccent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                drop.split(',').first,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
    );
  }

  Widget _buildBulletPoint(String text, {bool small = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: small ? 10 : 14)),
          Expanded(child: Text(text, style: TextStyle(fontSize: small ? 10 : 14, color: Colors.grey.shade600, height: 1.1))),
        ],
      ),
    );
  }

  Widget _buildSmallRateField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value ?? '—', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  Widget _buildScheduleLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 12, color: txigoBlue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRateItem(String label, String? value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              Text(value ?? '—', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: txigoBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text('Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Txigo Partner', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.person_outline, 'My Profile', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfileScreen()));
                  }),
                  _buildDrawerItem(Icons.card_membership_outlined, 'Subscription', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                  }),
                  _buildDrawerItem(Icons.account_balance_wallet_outlined, 'Wallet', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                  }),
                  _buildDrawerItem(Icons.emoji_events_outlined, 'Incentives', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const IncentivesScreen()));
                  }),
                  _buildDrawerItem(Icons.help_outline, 'Help & Support', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  }),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A73E8)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
