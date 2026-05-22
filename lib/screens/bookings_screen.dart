import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  // Dummy Bookings Data for UI Setup
  final List<Map<String, dynamic>> _bookings = const [
    {"id": "FIX-1092", "customer": "Babar Azam", "provider": "Asif Ali", "service": "AC Repairing", "price": "Rs. 2,500", "status": "Ongoing"},
    {"id": "FIX-1091", "customer": "Rizwan Ahmed", "provider": "Kamran Khan", "service": "Plumbing Leakage", "price": "Rs. 1,200", "status": "Pending"},
    {"id": "FIX-1090", "customer": "Imran Khan", "provider": "Sajid Mahmood", "service": "Switchboard Fixing", "price": "Rs. 800", "status": "Completed"},
    {"id": "FIX-1089", "customer": "Haris Rauf", "provider": "Zain Ul Abidin", "service": "Door Lock Repair", "price": "Rs. 1,500", "status": "Cancelled"},
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Global Bookings Logs",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              "Monitor live job requests, transactions, and service fulfillment statuses.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Bookings List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                Color statusColor = _getStatusColor(booking['status']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Side: Booking Core Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  booking['id'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking['status'],
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              booking['service'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 8),
                            // Customer & Provider Info Row
                            Wrap(
                              spacing: 20,
                              runSpacing: 5,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("Client: ${booking['customer']}", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.engineering_outlined, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("Handyman: ${booking['provider']}", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Right Side: Price Tag
                      Text(
                        booking['price'],
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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