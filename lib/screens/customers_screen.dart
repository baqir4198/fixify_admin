import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<Map<String, dynamic>>> _customersFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    setState(() {
      _customersFuture = _adminService.getAllCustomers();
    });
  }

  // Live Block/Unblock toggle handler
  Future<void> _toggleBlock(String id, bool currentStatus) async {
    bool nextStatus = !currentStatus;
    bool success = await _adminService.updateCustomerBlockStatus(id, nextStatus);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nextStatus ? "User blocked successfully." : "User unblocked successfully."),
            backgroundColor: nextStatus ? Colors.redAccent : Colors.green,
          ),
        );
      }
      _loadCustomers(); // List refresh karein
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Database validation error or missing column."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 800 ? 1 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          // 2. Error State
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Database se customers load nahi ho sakay."));
          }

          final customers = snapshot.data!;

          return SingleChildScrollView(
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

                customers.isEmpty
                    ? const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("No customers found in database.", style: TextStyle(color: Colors.grey)),
                ))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 110,
                  ),
                  itemBuilder: (context, index) {
                    final customer = customers[index];

                    // Schema ke mutabiq exact keys
                    String id = customer['id'].toString();
                    String name = customer['name'] ?? 'No Name';
                    String email = customer['email'] ?? 'No Email';

                    // Agar table mein 'is_blocked' ka column abhi tak nahi banaya toh safe toggle k liye default value false rkhi h
                    bool isBlocked = customer['is_blocked'] ?? false;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isBlocked ? Colors.red.shade50 : Colors.blue.shade50,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBlocked ? Colors.red : Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  email,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _toggleBlock(id, isBlocked),
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
          );
        },
      ),
    );
  }
}