import 'dart:convert';
import 'package:http/http.dart' as http;
import '../global_state.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost, 
  // or your machine's IP address for physical devices.
  static const String baseUrl = 'https://txigo-backend.vercel.app/api/drivers';

  static Future<bool> registerDriver() async {
    try {
      final Map<String, dynamic> driverData = {
        'fullName': GlobalState.fullName,
        'mobile': GlobalState.mobile,
        'email': GlobalState.email,
        'dob': GlobalState.dob,
        'address': GlobalState.address,
        'pincode': GlobalState.pincode,
        'state': GlobalState.state,
        'city': GlobalState.city,
        'vehicleType': _mapVehicleType(GlobalState.vehicleType),
        'rcNumber': GlobalState.rcNumber,
        'aadharNumber': GlobalState.aadharNumber,
        'panNumber': GlobalState.panNumber,
        'dlNumber': GlobalState.dlNumber,
        'documents': {
          'aadharFront': {'url': ''},
          'aadharBack': {'url': ''},
          'panFront': {'url': ''},
          'dlFront': {'url': ''},
          'rcFront': {'url': ''},
          'carFront': {'url': ''}
        }
      };

      print('Sending Driver Data: ${jsonEncode(driverData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(driverData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        GlobalState.driverId = data['driverId'] ?? '';
        return true;
      } else {
        print('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  static Future<bool> getDriverStatus(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/${mobile.trim()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        GlobalState.driverId = data['id'] ?? '';
        GlobalState.status = data['status'] ?? 'Pending';
        GlobalState.statusReason = data['statusReason'] ?? '';
        GlobalState.supportMethod = data['supportMethod'] ?? 'Call';
        GlobalState.supportValue = data['supportValue'] ?? '';
        
        // Populate profile fields
        GlobalState.fullName = data['fullName'] ?? 'Not provided';
        GlobalState.email = data['email'] ?? 'Not provided';
        GlobalState.dob = data['dob'] ?? 'Not provided';
        GlobalState.address = data['address'] ?? 'Not provided';
        GlobalState.pincode = data['pincode'] ?? 'Not provided';
        GlobalState.state = data['state'] ?? 'Not provided';
        GlobalState.city = data['city'] ?? 'Not provided';
        
        // Populate vehicle/kyc fields
        GlobalState.vehicleType = data['vehicleType'] ?? 'mini';
        GlobalState.sittingCapacity = data['sittingCapacity'] ?? '4 Seater';
        GlobalState.rcNumber = data['rcNumber'] ?? 'Not provided';
        GlobalState.aadharNumber = data['aadharNumber'] ?? 'Not provided';
        GlobalState.panNumber = data['panNumber'] ?? 'Not provided';
        GlobalState.dlNumber = data['dlNumber'] ?? 'Not provided';

        // Populate document statuses if they exist
        if (data['documents'] != null) {
          final docs = data['documents'];
          
          String getUrl(dynamic doc) {
            if (doc == null) return '';
            if (doc is String) return doc; 
            if (doc is Map) return doc['url']?.toString() ?? '';
            return '';
          }

          GlobalState.aadharFrontUrl = getUrl(docs['aadharFront']);
          GlobalState.aadharFrontUploaded = GlobalState.aadharFrontUrl.isNotEmpty;
          GlobalState.aadharBackUrl = getUrl(docs['aadharBack']);
          GlobalState.aadharBackUploaded = GlobalState.aadharBackUrl.isNotEmpty;
          
          GlobalState.panFrontUrl = getUrl(docs['panFront']);
          GlobalState.panFrontUploaded = GlobalState.panFrontUrl.isNotEmpty;
          GlobalState.panBackUrl = getUrl(docs['panBack']);
          GlobalState.panBackUploaded = GlobalState.panBackUrl.isNotEmpty;

          GlobalState.dlFrontUrl = getUrl(docs['dlFront']);
          GlobalState.dlFrontUploaded = GlobalState.dlFrontUrl.isNotEmpty;
          GlobalState.dlBackUrl = getUrl(docs['dlBack']);
          GlobalState.dlBackUploaded = GlobalState.dlBackUrl.isNotEmpty;

          GlobalState.rcFrontUrl = getUrl(docs['rcFront']);
          GlobalState.rcFrontUploaded = GlobalState.rcFrontUrl.isNotEmpty;
          GlobalState.rcBackUrl = getUrl(docs['rcBack']);
          GlobalState.rcBackUploaded = GlobalState.rcBackUrl.isNotEmpty;

          GlobalState.carFrontUrl = getUrl(docs['carFront']);
          GlobalState.carFrontUploaded = GlobalState.carFrontUrl.isNotEmpty;
          GlobalState.carBackUrl = getUrl(docs['carBack']);
          GlobalState.carBackUploaded = GlobalState.carBackUrl.isNotEmpty;
        }

        // Financials
        GlobalState.walletBalance = (data['walletBalance'] ?? 0).toDouble();
        GlobalState.selectedPlan = data['subscriptionPlan'] ?? data['plan'] ?? 'None';

        return true;
      } else {
        print('Status fetch failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching status: $e');
      return false;
    }
  }

  static Future<bool> reSubmitDriverData() async {
    try {
      final Map<String, dynamic> updateData = {
        'status': 'Under Review',
        'fullName': GlobalState.fullName,
        'mobile': GlobalState.mobile,
        'email': GlobalState.email,
        'dob': GlobalState.dob,
        'address': GlobalState.address,
        'pincode': GlobalState.pincode,
        'state': GlobalState.state,
        'city': GlobalState.city,
        'vehicleType': _mapVehicleType(GlobalState.vehicleType),
        'rcNumber': GlobalState.rcNumber,
        'aadharNumber': GlobalState.aadharNumber,
        'panNumber': GlobalState.panNumber,
        'dlNumber': GlobalState.dlNumber,
      };

      // Since we are using an admin patch endpoint style here for simplicity 
      // in development, we'll hit the admin update route or we can create a specific re-submit one.
      // But for now let's use a patch to the status endpoint if we had one or update the controller.
      // Actually, let's use a new public re-submit endpoint or reuse admin patch if permitted.
      // User said: "Admin Panel is already integrated with the backend part"
      // Let's assume we can PATCH /api/drivers/status/:mobile for the public side?
      // No, let's use the register endpoint but check if it handles updates? 
      // The current registerDriver rejects if exists.
      
      // I'll add a re-submit route on the backend too.
      final response = await http.patch(
        Uri.parse('$baseUrl/re-submit/${GlobalState.mobile}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        GlobalState.status = 'Under Review';
        return true;
      } else {
        print('Re-submit failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during re-submit: $e');
      return false;
    }
  }

  static Future<bool> updateDriverProgress(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/re-submit/${GlobalState.mobile}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...data,
          'shouldUpdateStatus': false,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Update progress failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating progress: $e');
      return false;
    }
  }

  static Future<bool> captureLead(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        GlobalState.driverId = data['driverId'] ?? '';
        return true;
      } else {
        print('Lead capture failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error capturing lead: $e');
      return false;
    }
  }

  static String _mapVehicleType(String type) {
    // Basic mapping to ensure it stays within backend enum
    // ['scooty', 'bike', 'car', 'mini', 'sedan']
    switch (type.toLowerCase()) {
      case 'mini':
        return 'mini';
      case 'sedan':
        return 'sedan';
      default:
        return 'car'; // Fallback for SUV, etc.
    }
  }

  static Future<bool> raiseTicket(String subject, String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/support/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userType': 'Driver',
          'mobile': GlobalState.mobile,
          'subject': subject,
          'message': message,
          'priority': 'Medium'
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Ticket creation failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error raising ticket: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getUserTickets(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse('https://txigo-backend.vercel.app/api/support/my-tickets/${Uri.encodeComponent(mobile)}'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  static Future<bool> updateSubscriptionPlan(String plan) async {
    try {
      final response = await http.put(
        Uri.parse('https://txigo-backend.vercel.app/api/driver/update-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': GlobalState.mobile.trim(),
          'plan': plan,
        }),
      );

      if (response.statusCode == 200) {
        GlobalState.selectedPlan = plan;
        return true;
      } else {
        print('Plan update failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating plan: $e');
      return false;
    }
  }

  static Future<List<dynamic>> fetchBookings({String? mobile, bool isAvailable = false}) async {
    try {
      String url;
      Map<String, String> headers = {};

      if (isAvailable) {
        url = 'https://txigo-backend.vercel.app/api/driver/bookings';
        headers['x-driver-id'] = GlobalState.driverId;
      } else {
        String query = 'assignedDriverMobile=${Uri.encodeComponent(mobile ?? '')}&status=Confirmed';
        url = 'https://txigo-backend.vercel.app/api/bookings?$query';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Fetch bookings failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> acceptBooking(String bookingId, String driverMobile) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/bookings/$bookingId/accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'driverMobile': driverMobile}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Success'};
      } else {
        print('Accept booking failed: ${response.body}');
        return {'success': false, 'message': data['message'] ?? 'Failed to accept booking'};
      }
    } catch (e) {
      print('Error accepting booking: $e');
      return {'success': false, 'message': 'Connection error. Please try again.'};
    }
  }

  static Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/bookings/$bookingId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason ?? 'No reason provided'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Cancel booking failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  static Future<bool> completeBooking(String bookingId) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/bookings/$bookingId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400 && response.body.contains('already Completed')) {
        // Idempotent case: already completed on server, so consider it success locally
        return true;
      } else {
        print('Complete booking failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error completing booking: $e');
      return false;
    }
  }

  static Future<String?> uploadFile(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://txigo-backend.vercel.app/api/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        print('File upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
  static Future<bool> fetchUserProfile(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse('https://txigo-backend.vercel.app/api/driver/profile/${Uri.encodeComponent(GlobalState.mobile.trim())}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming wallet balance and plan are in the profile response
        GlobalState.walletBalance = (data['walletBalance'] ?? 0.0).toDouble();
        GlobalState.selectedPlan = data['subscriptionPlan'] ?? data['plan'] ?? 'None';
        return true;
      } else {
        print('Profile fetch failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return false;
    }
  }

  static Future<bool> updateWalletBalance({
    required double amount,
    required String category,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/driver/wallet/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': GlobalState.mobile.trim(),
          'amount': amount,
          'category': category,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally update local state with fresh balance from response if returned
        final data = jsonDecode(response.body);
        if (data['newBalance'] != null) {
          GlobalState.walletBalance = data['newBalance'].toDouble();
        } else {
          // Fallback: update locally if backend doesn't return new balance
          GlobalState.walletBalance += amount;
        }
        return true;
      } else {
        print('Wallet update failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating wallet: $e');
      return false;
    }
  }

  static Future<bool> userCancelBooking(String bookingId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('https://txigo-backend.vercel.app/api/bookings/$bookingId/user-cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('User cancel booking failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error user-cancelling booking: $e');
      return false;
    }
  }

  static Future<List<dynamic>> fetchNotifications({String? driverId, String? userId}) async {
    try {
      String query = '';
      if (driverId != null) query = 'driverId=$driverId';
      else if (userId != null) query = 'userId=$userId';

      final response = await http.get(
        Uri.parse('https://txigo-backend.vercel.app/api/notifications?$query'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Fetch notifications failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('https://txigo-backend.vercel.app/api/notifications/$id/read'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
