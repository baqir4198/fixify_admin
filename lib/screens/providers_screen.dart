import 'package:flutter/material.dart';
import '../services/admin_service.dart'; // Connected directly to live service

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<Map<String, dynamic>>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _providersFuture = _adminService.getAllProviders();
    });
  }

  // Live Approval/Status Change Trigger
  Future<void> _changeStatus(String id, String newStatus) async {
    bool success = await _adminService.updateProviderStatus(id, newStatus);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Provider status changed to $newStatus!"),
              backgroundColor: newStatus == 'provider' ? Colors.green : Colors.orange
          ),
        );
      }
      _loadProviders(); // Data reload taake table live update ho jaye
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status update karne mein masla hua."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          // 2. Error State
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Database se providers load nahi ho sakay."));
          }

          final liveProviders = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Service Providers Management",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Verify, approve, or suspend handymen registered on the platform.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Main Table Container
                liveProviders.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("No handymen found in database.", style: TextStyle(color: Colors.grey)),
                  ),
                )
                    : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                      columns: const [
                        DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Profession', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: liveProviders.map((provider) {
                        String id = provider['id'].toString();
                        String name = provider['name'] ?? 'No Name';
                        String profession = provider['profession'] ?? 'General';
                        String phone = provider['phone'] ?? 'N/A';

                        // Role ke mutabiq status handle karna (provider == Approved, pending_provider == Pending)
                        String roleStatus = provider['role'] ?? 'provider';
                        bool isApproved = roleStatus == 'provider';

                        return DataRow(cells: [
                          DataCell(Text(name)),
                          DataCell(Text(profession)),
                          DataCell(Text(phone)),
                          // Dynamic Status Badge Tag
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isApproved ? "Approved" : "Pending",
                                style: TextStyle(
                                  color: isApproved ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          // Real Action Buttons (Approve / Suspend)
                          DataCell(
                            Row(
                              children: [
                                if (!isApproved)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                                    tooltip: "Approve Provider",
                                    onPressed: () => _changeStatus(id, 'provider'),
                                  ),
                                if (isApproved)
                                  IconButton(
                                    icon: const Icon(Icons.block_rounded, color: Colors.redAccent),
                                    tooltip: "Suspend / Set Pending",
                                    onPressed: () => _changeStatus(id, 'pending_provider'), // Suspended/Pending status set krne k liye
                                  ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}