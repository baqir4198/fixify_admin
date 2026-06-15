import 'package:flutter/material.dart';
import '../services/admin_service.dart';
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

  // Live status ke mutabiq colors badalne ke liye helper function
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Ongoing': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 650 ? 1 : (screenWidth < 1100 ? 2 : 4);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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

                // Platform Activity Area (100% Live with StreamBuilder)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Recent Platform Activity",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
                      ),
                      const SizedBox(height: 20),

                      // Live Bookings Listener
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _adminService.getRecentBookingsStream(),
                        builder: (context, streamSnapshot) {
                          if (streamSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: LinearProgressIndicator(color: Colors.blue));
                          }
                          if (streamSnapshot.hasError || !streamSnapshot.hasData || streamSnapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("No recent booking logs found.", style: TextStyle(color: Colors.grey)),
                              ),
                            );
                          }

                          final liveBookings = streamSnapshot.data!;

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: liveBookings.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final booking = liveBookings[index];

                              // Schema ke mutabiq exact columns
                              String service = booking['service_name'] ?? 'Unknown Service';
                              String client = booking['customer_name'] ?? 'Client';
                              String price = booking['price'] ?? '0';
                              String status = booking['status'] ?? 'Pending';

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                                  child: Icon(Icons.circle_notifications_rounded, color: _getStatusColor(status)),
                                ),
                                title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text("Booked by $client", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Rs. $price", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Text(
                                        status,
                                        style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 11)
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
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