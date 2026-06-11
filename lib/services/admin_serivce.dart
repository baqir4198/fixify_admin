import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Total Customers Count Fetch Karein (users table jahan role == customer)
  Future<int> getCustomersCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'customer')
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print("Error fetching customers count: $e");
      return 0;
    }
  }

  // 2. Active Handymen (Providers) Count Fetch Karein (users table jahan role == provider)
  Future<int> getProvidersCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('role', 'provider')
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print("Error fetching providers count: $e");
      return 0;
    }
  }

  // 3. Total Bookings Count Fetch Karein (bookings table se)
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

  // 4. Total Platform Revenue Calculate Karein (bookings jahan status == Completed)
  Future<double> getTotalRevenue() async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select('price')
          .eq('status', 'Completed');

      double total = 0;
      for (var booking in response) {
        // Price text data type hai schema mein, isliye double.tryParse must hai
        total += double.tryParse(booking['price'].toString()) ?? 0.0;
      }
      return total;
    } catch (e) {
      print("Error calculating revenue: $e");
      return 0.0;
    }
  }

  // 5. Tamam Providers ki List Fetch Karein (users table jahan role == provider)
  Future<List<Map<String, dynamic>>> getAllProviders() async {
    try {
      final List<dynamic> response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'provider')
          .order('updated_at', ascending: false); // schema mein updated_at hai

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching providers list: $e");
      return [];
    }
  }

  // 6. Tamam Customers ki List Fetch Karein (users table jahan role == customer)
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final List<dynamic> response = await _supabase
          .from('users')
          .select('*')
          .eq('role', 'customer')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching customers list: $e");
      return [];
    }
  }

  // 7. Provider Ka Status ya Role Update Karein
  Future<bool> updateProviderStatus(String providerId, String newStatus) async {
    try {
      await _supabase
          .from('users')
          .update({'role': newStatus}) // Agar custom status column dala hai toh 'role' ki jagah uska naam likhein
          .eq('id', providerId);

      return true;
    } catch (e) {
      print("Error updating provider status: $e");
      return false;
    }
  }

  // 8. Customer Ko Block ya Unblock Karein
  Future<bool> updateCustomerBlockStatus(String customerId, bool isBlocked) async {
    try {
      // Note: Agar aapne users table mein baad mein 'is_blocked' ka column dala hai toh yeh chalega.
      // Agar nahi dala toh pehle database mein column add karna hoga.
      await _supabase
          .from('users')
          .update({'is_blocked': isBlocked})
          .eq('id', customerId);

      return true;
    } catch (e) {
      print("Error updating customer block status: $e");
      return false;
    }
  }
  // 9. Recent Bookings ki Live Stream (Real-time updates ke liye)
  Stream<List<Map<String, dynamic>>> getRecentBookingsStream() {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false) // Nayi bookings top par aayengi
        .limit(5); // Dashboard par sirf top 5 recent activities dikhane k liye
  }


  // 10. Tamam Bookings ki List Fetch Karein (Global Log)
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select('*')
          .order('created_at', ascending: false); // Nayi bookings top par aayengi

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching global bookings list: $e");
      return [];
    }
  }

  // 11. Kisi Bhi Booking Ka Status Update Karein (e.g., Pending -> Ongoing -> Completed)
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);

      return true;
    } catch (e) {
      print("Error updating booking status: $e");
      return false;
    }
  }
}