import 'package:flutter/material.dart';
import '../services/admin_serivce.dart';
import '../widgets/stat_card.dart';

class OverviewDashboard extends StatefulWidget {
  const OverviewDashboard({super.key});

  @override
  State<OverviewDashboard> createState() => _OverviewDashboardState();
}

class _OverviewDashboardState extends State<OverviewDashboard> {
  final AdminService _adminService = AdminService();
  late Future<List<dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    // Saare data counters ko ek sath parallel mein fetch shuru karwaya
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dashboardData = Future.wait([
        _adminService.getCustomersCount(),
        _adminService.getProvidersCount(),
        _adminService.getBookingsCount(),
        _adminService.getTotalRevenue(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 650 ? 1 : (screenWidth < 1100 ? 2 : 4);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Refresh karne ke liye top par button ya option rakh sakte hain
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Supabase se data lanay mein masla hoa:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          }

          // 3. Data Loaded State
          final customersCount = snapshot.data![0].toString();
          final providersCount = snapshot.data![1].toString();
          final bookingsCount = snapshot.data![2].toString();
          final double revenue = snapshot.data![3];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Overview",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome back, Admin. Real-time data connected securely to Supabase.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Responsive Counter Grid (Live Data Linked)
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: screenWidth < 650 ? 3.5 : 2.2,
                  children: [
                    StatCard(
                      title: "Total Customers",
                      value: customersCount,
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: "Active Handymen",
                      value: providersCount,
                      icon: Icons.engineering_rounded,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: "Total Bookings",
                      value: bookingsCount,
                      icon: Icons.assignment_rounded,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: "Platform Revenue",
                      value: "Rs. ${revenue.toStringAsFixed(0)}",
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Platform Activity Area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recent Platform Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "Live database counters linked completely.",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}