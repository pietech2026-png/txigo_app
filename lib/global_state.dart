class GlobalState {
  static String driverId = '';
  static String mobile = '';
  static String status = 'New'; // New, Pending, Active, Blocked, Under Review
  static String statusReason = '';
  static String supportMethod = 'Call';
  static String supportValue = '';
  static String city = 'Not provided';
  static String vehicleType = 'mini';
  static String sittingCapacity = '4 Seater'; 
  static String fullName = 'Not provided';
  static String dob = 'Not provided';
  static String email = 'Not provided';
  static String address = 'Not provided';
  static String pincode = 'Not provided';
  static String state = 'Not provided';

  // KYC
  static String aadharNumber = 'Not provided';
  static bool aadharFrontUploaded = false;
  static String aadharFrontUrl = '';
  static bool aadharBackUploaded = false;
  static String aadharBackUrl = '';

  static String panNumber = 'Not provided';
  static bool panFrontUploaded = false;
  static String panFrontUrl = '';
  static bool panBackUploaded = false;
  static String panBackUrl = '';

  static String dlNumber = 'Not provided';
  static bool dlFrontUploaded = false;
  static String dlFrontUrl = '';
  static bool dlBackUploaded = false;
  static String dlBackUrl = '';

  // Vehicle
  static String rcNumber = 'Not provided';
  static bool rcFrontUploaded = false;
  static String rcFrontUrl = '';
  static bool rcBackUploaded = false;
  static String rcBackUrl = '';
  static bool carFrontUploaded = false;
  static String carFrontUrl = '';
  static bool carBackUploaded = false;
  static String carBackUrl = '';
  static String selectedPlan = 'None'; // Regular, Prime, None
  static double walletBalance = 0.0;

  static double get commissionRate => selectedPlan == 'Regular' ? 0.15 : (selectedPlan == 'Prime' ? 0.05 : 0.0);

  static bool get isProfileComplete => 
    fullName != 'Not provided' && 
    dob != 'Not provided' &&
    address != 'Not provided' &&
    pincode != 'Not provided' &&
    state != 'Not provided';

  static bool get isKYCComplete => 
    aadharNumber != 'Not provided' && aadharFrontUploaded &&
    panNumber != 'Not provided' && panFrontUploaded &&
    dlNumber != 'Not provided' && dlFrontUploaded;

  static bool get isVehicleComplete => 
    rcNumber != 'Not provided' && rcFrontUploaded &&
    carFrontUploaded;

  static bool get hasAllDocuments => isProfileComplete && isKYCComplete && isVehicleComplete;

  static Map<String, dynamic> toBackendDocuments() {
    return {
      'aadharFront': {'url': aadharFrontUrl},
      'aadharBack':  {'url': aadharBackUrl},
      'panFront':    {'url': panFrontUrl},
      'panBack':     {'url': panBackUrl},
      'dlFront':     {'url': dlFrontUrl},
      'dlBack':      {'url': dlBackUrl},
      'rcFront':     {'url': rcFrontUrl},
      'rcBack':      {'url': rcBackUrl},
      'carFront':    {'url': carFrontUrl},
      'carBack':     {'url': carBackUrl},
    };
  }
}

