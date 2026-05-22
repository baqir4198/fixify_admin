import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';

class OverviewDashboard extends StatelessWidget {
  const OverviewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen ki width check karne ke liye layout parameters
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 650 ? 1 : (screenWidth < 1100 ? 2 : 4);

    return Scaffold(
      body: SingleChildScrollView(
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
              "Welcome back, Admin. Here is what's happening today.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Responsive Counter Grid
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: screenWidth < 650 ? 3.5 : 2.2, // Adjust card shape
              children: const [
                StatCard(title: "Total Customers", value: "1,240", icon: Icons.people_alt_rounded, color: Colors.blue),
                StatCard(title: "Active Handymen", value: "84", icon: Icons.engineering_rounded, color: Colors.green),
                StatCard(title: "Total Bookings", value: "3,120", icon: Icons.assignment_rounded, color: Colors.orange),
                StatCard(title: "Platform Revenue", value: "Rs. 450K", icon: Icons.account_balance_wallet_rounded, color: Colors.purple),
              ],
            ),

            const SizedBox(height: 40),

            // Placeholder for Charts or Recent Bookings Stream
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
                      child: Text("Supabase Stream logs will appear here...", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}