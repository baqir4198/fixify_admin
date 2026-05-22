import 'package:flutter/material.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  // Dummy Data for UI Testing (Baad mein Supabase se aayega)
  final List<Map<String, dynamic>> _providers = [
    {"name": "Asif Ali", "profession": "Electrician", "phone": "03001234567", "status": "Pending"},
    {"name": "Kamran Khan", "profession": "Plumber", "phone": "03217654321", "status": "Approved"},
    {"name": "Sajid Mahmood", "profession": "AC Technician", "phone": "03339876543", "status": "Approved"},
    {"name": "Zain Ul Abidin", "profession": "Carpenter", "phone": "03451122334", "status": "Pending"},
  ];

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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Mobile browsers par table overflow nahi karega
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: const [
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Profession', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _providers.map((provider) {
                    bool isApproved = provider['status'] == 'Approved';
                    return DataRow(cells: [
                      DataCell(Text(provider['name'])),
                      DataCell(Text(provider['profession'])),
                      DataCell(Text(provider['phone'])),
                      // Status Badge Tag
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            provider['status'],
                            style: TextStyle(
                              color: isApproved ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      // Action Buttons (Approve / Block)
                      DataCell(
                        Row(
                          children: [
                            if (!isApproved)
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                                tooltip: "Approve Provider",
                                onPressed: () {
                                  setState(() => provider['status'] = 'Approved');
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.block_rounded, color: Colors.redAccent),
                              tooltip: "Block / Suspend",
                              onPressed: () {
                                setState(() => provider['status'] = 'Pending'); // Or blocked logic
                              },
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
      ),
    );
  }
}