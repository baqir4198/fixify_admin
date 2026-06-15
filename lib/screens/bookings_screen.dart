import 'package:flutter/material.dart';
import '../services/admin_service.dart'; // Spelling typo fix kiya: serivce -> service

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _bookingsFuture = _adminService.getAllBookings();
    });
  }

  // Live Status Change Handler
  Future<void> _updateStatus(String id, String newStatus) async {
    bool success = await _adminService.updateBookingStatus(id, newStatus);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking status updated to $newStatus!"), backgroundColor: Colors.green),
        );
      }
      _loadBookings(); // UI automatically refresh ho jayegi
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status update karne mein masla hua."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          // 2. Error State
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Database se bookings load nahi ho saki."));
          }

          final liveBookings = snapshot.data!;

          return SingleChildScrollView(
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

                // Live Bookings Generator
                liveBookings.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("No bookings found in database.", style: TextStyle(color: Colors.grey)),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveBookings.length,
                  itemBuilder: (context, index) {
                    final booking = liveBookings[index];

                    // Schema ke exact columns
                    String id = booking['id'].toString();
                    String serviceName = booking['service_name'] ?? 'General Service';
                    String customerName = booking['customer_name'] ?? 'Client';
                    String providerId = booking['provider_id']?.toString() ?? '';
                    String price = booking['price'] ?? '0';
                    String status = booking['status'] ?? 'Pending';
                    String date = booking['booking_date'] ?? '';
                    String time = booking['booking_time'] ?? '';

                    Color statusColor = _getStatusColor(status);

                    // Provider name/ID safe fallback check string short krne k liye
                    String displayProvider = providerId.isEmpty
                        ? 'Not Assigned'
                        : (providerId.length > 6 ? providerId.substring(0, 6) : providerId);

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
                          // Left Side: Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "ID: ${id.length > 8 ? id.substring(0, 8) : id}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 14),
                                    ),
                                    const SizedBox(width: 10),

                                    // Interactive Status Badge Dropdown
                                    PopupMenuButton<String>(
                                      onSelected: (nextStatus) => _updateStatus(id, nextStatus),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'Pending', child: Text('Set to Pending')),
                                        const PopupMenuItem(value: 'Ongoing', child: Text('Set to Ongoing')),
                                        const PopupMenuItem(value: 'Completed', child: Text('Set to Completed')),
                                        const PopupMenuItem(value: 'Cancelled', child: Text('Cancel Booking')),
                                      ],
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              status,
                                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.arrow_drop_down, size: 14, color: statusColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  serviceName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 20,
                                  runSpacing: 5,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("Client: $customerName", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.engineering_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("Handyman ID: $displayProvider", style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                      ],
                                    ),
                                    if (date.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text("$date ($time)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Right Side: Price
                          Text(
                            "Rs. $price",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}