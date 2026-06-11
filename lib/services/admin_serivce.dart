import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Total Customers Count Fetch Karein
  Future<int> getCustomersCount() async {
    try {
      // Bilkul clean aur latest syntax, na FetchOptions ki zaroorat na positional argument ka error
      final response = await _supabase
          .from('profiles')
          .select()
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print("Error fetching customers count: $e");
      return 0;
    }
  }

  // 2. Active Handymen (Providers) Count Fetch Karein
  Future<int> getProvidersCount() async {
    try {
      final response = await _supabase
          .from('providers')
          .select()
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print("Error fetching providers count: $e");
      return 0;
    }
  }

  // 3. Total Bookings Count Fetch Karein
  Future<int> getBookingsCount() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print("Error fetching bookings count: $e");
      return 0;
    }
  }

  // 4. Total Platform Revenue Calculate Karein
  Future<double> getTotalRevenue() async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select('price')
          .eq('status', 'Completed');

      double total = 0;
      for (var booking in response) {
        total += double.tryParse(booking['price'].toString()) ?? 0.0;
      }
      return total;
    } catch (e) {
      print("Error calculating revenue: $e");
      return 0.0;
    }
  }

  // 5. Tamam Providers ki List Fetch Karein
  Future<List<Map<String, dynamic>>> getAllProviders() async {
    try {
      final List<dynamic> response = await _supabase
          .from('providers')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching providers list: $e");
      return [];
    }
  }

  // 6. Provider Ka Status Update Karein
  Future<bool> updateProviderStatus(String providerId, String newStatus) async {
    try {
      await _supabase
          .from('providers')
          .update({'status': newStatus})
          .eq('id', providerId);

      return true;
    } catch (e) {
      print("Error updating provider status: $e");
      return false;
    }
  }
  // 7. Tamam Customers ki List Fetch Karein
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      // Assuming customers are in 'profiles' table where type/role is 'customer'
      // Agar aapke paas role ka column nahi hai, toh simple select('*') bhi kar sakte hain
      final List<dynamic> response = await _supabase
          .from('profiles')
          .select('*')
          .eq('role', 'customer') // Agar customer filtering karni ho
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching customers list: $e");
      return [];
    }
  }

  // 8. Customer Ko Block ya Unblock Karein
  Future<bool> updateCustomerBlockStatus(String customerId, bool isBlocked) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_blocked': isBlocked}) // Assuming column name is 'is_blocked'
          .eq('id', customerId);

      return true;
    } catch (e) {
      print("Error updating customer block status: $e");
      return false;
    }
  }
}