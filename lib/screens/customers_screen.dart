import 'package:flutter/material.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // Dummy Customers Data for UI setup
  final List<Map<String, dynamic>> _customers = [
    {"name": "Babar Azam", "email": "babar@gmail.com", "bookings": 14, "isBlocked": false},
    {"name": "Rizwan Ahmed", "email": "rizwan@gmail.com", "bookings": 8, "isBlocked": false},
    {"name": "Shaheen Shah", "email": "shaheen@gmail.com", "bookings": 22, "isBlocked": true},
    {"name": "Haris Rauf", "email": "haris@gmail.com", "bookings": 3, "isBlocked": false},
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Badi screen par 2 items aik line mein, mobile par 1 item per line
    int crossAxisCount = screenWidth < 800 ? 1 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customers Directory",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              "View registered users, monitor their platform usage, and manage access restrictions.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Responsive Layout Grid for Customers
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _customers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 100, // Fixed height for each customer row card
              ),
              itemBuilder: (context, index) {
                final customer = _customers[index];
                bool isBlocked = customer['isBlocked'];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      // User Profile Initial Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isBlocked ? Colors.red.shade50 : Colors.blue.shade50,
                        child: Text(
                          customer['name'][0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isBlocked ? Colors.red : Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Customer Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              customer['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              customer['email'],
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Orders: ${customer['bookings']}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo),
                            ),
                          ],
                        ),
                      ),
                      // Block / Unblock Action Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            customer['isBlocked'] = !customer['isBlocked'];
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBlocked ? Colors.green : Colors.red.shade50,
                          foregroundColor: isBlocked ? Colors.white : Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          isBlocked ? "Unblock" : "Block User",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}