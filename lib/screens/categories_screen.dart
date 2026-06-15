import 'package:flutter/material.dart';

import '../services/admin_service.dart'; // Exact connected service path

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories(); // App start hotay hi database se fetch karein
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = _adminService.getAllCategoriesWithCount();
    });
  }

  // Database se text code read karke Flutter Icon return karne ka utility function
  IconData _getIconData(String iconCode) {
    switch (iconCode) {
      case 'bolt': return Icons.bolt_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'ac': return Icons.ac_unit_rounded;
      case 'chair': return Icons.chair_rounded;
      case 'paint': return Icons.format_paint_rounded;
      default: return Icons.construction_rounded;
    }
  }

  // Live Add Category Request
  Future<void> _handleAddCategory() async {
    String text = _categoryController.text.trim();
    if (text.isEmpty) return;

    bool success = await _adminService.addCategory(text);
    if (success) {
      _categoryController.clear();
      if (mounted) Navigator.pop(context); // Dialog band karein
      _loadCategories(); // Grid live refresh karein
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Database Insertion Failed! Table name ya RLS check karein."),
              backgroundColor: Colors.redAccent
          ),
        );
      }
    }
  }

  // Live Delete Category Request
  Future<void> _handleDeleteCategory(dynamic id) async {
    bool success = await _adminService.deleteCategory(id);
    if (success) {
      _loadCategories(); // Table refresh
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category delete nahi ho saki."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // Nayi category add karne ka Dialog Box popup
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Add New Service Category", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            hintText: "e.g., Home Cleaner, Car Mechanic",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _handleAddCategory, // Connected directly to live Supabase trigger
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Add Category", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 1100 ? 2 : 3);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Category", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          // 2. Error State
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                  "Supabase Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent)
              ),
            );
          }

          final liveCategories = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "App Service Categories",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create, update, or remove active service types shown on the client application.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Responsive Grid for Dynamic Category Cards
                liveCategories.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("No categories found in database. Add one to start!", style: TextStyle(color: Colors.grey)),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 90,
                  ),
                  itemBuilder: (context, index) {
                    final cat = liveCategories[index];
                    dynamic id = cat['id'];
                    String name = cat['name'] ?? 'Unknown';
                    String iconCode = cat['icon_code'] ?? 'construction';
                    int count = cat['providersCount'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_getIconData(iconCode), color: Colors.blue, size: 28),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text("$count Handymen Active", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _handleDeleteCategory(id),
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