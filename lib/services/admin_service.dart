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
        total += double.tryParse(booking['price'].toString()) ?? 0.0;
      }
      return total;
    } catch (e) {
      print("Error calculating revenue: $e");
      return 0.0;
    }
  }

  // 5. Tamam Providers ki List Fetch Karein (Case-Insensitive Fixed)
  Future<List<Map<String, dynamic>>> getAllProviders() async {
    try {
      // .ilike se uppercase/lowercase (Provider ya provider) dono fetch ho jate hain
      final List<dynamic> response = await _supabase
          .from('users')
          .select('*')
          .ilike('role', 'provider');

      print("Fetched Providers Data Successfully: ${response.length} records found");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching providers list: $e");
      return [];
    }
  }

  // 6. Tamam Customers ki List Fetch Karein (Case-Insensitive Fixed)
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      // .ilike se Customer ya customer dono match ho jayenge
      final List<dynamic> response = await _supabase
          .from('users')
          .select('*')
          .ilike('role', 'customer');

      print("Fetched Customers Data Successfully: ${response.length} records found");
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
          .update({'role': newStatus})
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

  // 9. Recent Bookings ki Live Stream (Real-time updates ke liye 100% Fixed)
  Stream<List<Map<String, dynamic>>> getRecentBookingsStream() {
    try {
      return _supabase
          .from('bookings')
          .stream(primaryKey: ['id']) // Custom UUID supported via stream engine
          .order('created_at', ascending: false) // Handled safely inside native parser
          .limit(5); // Top 5 recent job alerts for dashboard logs
    } catch (e) {
      print("Realtime Stream Initialization Error: $e");
      // Fallback: Agar stream fail ho toh empty stream return karein taake UI crash na ho
      return const Stream.empty();
    }
  }

  // 10. Tamam Bookings ki List Fetch Karein (Safe Raw Fetch with Error Tracking)
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select('*'); // Bina kisi configuration query ke direct select

      print("DEBUG BOOKINGS -> Total records in database: ${response.length}");
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stacktrace) {
      // Agar table name ya type casting ka koi error hoga toh exact yahan print hoga
      print("Error fetching global bookings list: $e");
      print("Stacktrace: $stacktrace");
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

  // ==========================================
  // 🔥 NEW: CATEGORIES METHODS (Yahan Add Kar Diye Hain)
  // ==========================================

  // 12. Tamam Categories Fetch Karein + Unke Active Handymen Ka Count Bhi Layein
  Future<List<Map<String, dynamic>>> getAllCategoriesWithCount() async {
    try {
      final List<dynamic> catResponse = await _supabase
          .from('categories')
          .select('*')
          .order('name', ascending: true);

      List<Map<String, dynamic>> finalCategories = [];

      for (var cat in catResponse) {
        String catName = cat['name'] ?? '';

        final providersCountResponse = await _supabase
            .from('users')
            .select()
            .eq('role', 'provider')
            .eq('profession', catName) // Users table mein jo profession field hai
            .count(CountOption.exact);

        finalCategories.add({
          "id": cat['id'],
          "name": catName,
          "icon_code": cat['icon_code'] ?? 'construction',
          "providersCount": providersCountResponse.count ?? 0,
        });
      }

      return finalCategories;
    } catch (e) {
      print("Error fetching categories with count: $e");
      return [];
    }
  }

  // 13. Nayi Category Insert Karein
  Future<bool> addCategory(String categoryName) async {
    try {
      await _supabase.from('categories').insert({
        'name': categoryName,
        'icon_code': 'construction', // Default text code jo screen par check hota h
      });
      return true;
    } catch (e) {
      print("Error adding category to Supabase: $e");
      return false;
    }
  }

  // 14. Category Delete Karein
  Future<bool> deleteCategory(dynamic categoryId) async {
    try {
      await _supabase.from('categories').delete().eq('id', categoryId);
      return true;
    } catch (e) {
      print("Error deleting category from Supabase: $e");
      return false;
    }
  }
}