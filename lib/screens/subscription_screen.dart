import 'package:flutter/material.dart';
import '../global_state.dart';
import '../services/api_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late int _selectedPlan;

  static const Color accentYellow = Color(0xFFFDBF00);
  static const Color txigoBlue = Color(0xFF1A73E8);

  @override
  void initState() {
    super.initState();
    if (GlobalState.selectedPlan == 'Prime') {
      _selectedPlan = 2;
    } else {
      _selectedPlan = 1; // Default to Regular if not Prime
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: txigoBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Unlock Your Potential',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1D1D1F), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the plan that best fits your driving lifestyle and maximize your earnings.',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w400, height: 1.4),
                      ),
                      const SizedBox(height: 32),

                      _buildEnhancedPlanCard(
                        index: 1,
                        title: 'REGULAR',
                        price: '1200',
                        commission: '15%',
                        colors: [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
                        benefits: [
                          'Standard Commission (15%)',
                          'Basic Support Access',
                          'Standard Ride Notifications',
                          'Lifetime Validity',
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildEnhancedPlanCard(
                        index: 2,
                        title: 'PRIME',
                        price: '2000',
                        commission: '5%',
                        colors: [
                          const Color(0xFFE2B05E), 
                          const Color(0xFFF8E0A0), 
                          const Color(0xFFB8860B),
                        ],
                        isPopular: true,
                        benefits: [
                          'Lowest Commission (5%)',
                          'Priority Support Access',
                          'Priority Ride Notifications',
                          'Exclusive Partner Benefits',
                          'Lifetime Validity',
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Validity : Lifetime',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '* Taxes and gateway charges are extra.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(int index) async {
    final String plan;
    if (index == 2) {
      plan = 'Prime';
    } else if (index == 1) {
      plan = 'Regular';
    } else {
      plan = 'None';
    }

    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: accentYellow),
      ),
    );

    final success = await ApiService.updateSubscriptionPlan(plan);

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading

    if (success) {
      setState(() => _selectedPlan = index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Subscribed to $plan Successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Subscription failed. Please try again.'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildEnhancedPlanCard({
    required int index,
    required String title,
    required String price,
    required String commission,
    required List<Color> colors,
    required List<String> benefits,
    bool isPopular = false,
  }) {
    final bool isSelected = _selectedPlan == index;
    final bool isGoldCard = colors.contains(const Color(0xFFE2B05E));
    final Color contentColor = isGoldCard ? const Color(0xFF332200) : Colors.white;
    final Color subContentColor = isGoldCard ? const Color(0xFF554411) : Colors.white.withOpacity(0.7);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      builder: (context, double value, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.08 * value)
            ..scale(1.0 + (0.02 * value)),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 25,
                    offset: Offset(0, 15 + (10 * value)),
                    spreadRadius: -5,
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: accentYellow.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    if (isPopular)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isGoldCard 
                                ? [const Color(0xFF1E1E2C), const Color(0xFF232335)] 
                                : [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium, 
                                color: isGoldCard ? const Color(0xFFFFD700) : Colors.white, 
                                size: 14
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: isGoldCard ? const Color(0xFFFFD700) : Colors.white, 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 0.8
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? accentYellow : contentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isSelected ? Colors.black : contentColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    commission,
                                    style: TextStyle(color: contentColor, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2),
                                  ),
                                  Text(
                                    'COMMISSION',
                                    style: TextStyle(color: subContentColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('LIFETIME ACCESS', style: TextStyle(color: subContentColor, fontSize: 10, fontWeight: FontWeight.w700)),
                                  Text(
                                    '₹$price',
                                    style: TextStyle(color: contentColor, fontSize: 32, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Divider(color: contentColor.withOpacity(0.1), thickness: 1.5),
                          const SizedBox(height: 20),
                          ...benefits.map((benefit) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(isGoldCard ? 0.1 : 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 14, color: Colors.blue),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      benefit,
                                      style: TextStyle(color: contentColor.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )).toList(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: InkWell(
                        onTap: () => _handleSubscription(index),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? accentYellow : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: (isSelected ? accentYellow : Colors.white).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SUBSCRIBE',
                                style: TextStyle(
                                  color: isSelected ? Colors.black : txigoBlue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: isSelected ? Colors.black : txigoBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
