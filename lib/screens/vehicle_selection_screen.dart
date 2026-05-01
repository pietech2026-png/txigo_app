import 'package:flutter/material.dart';
import '../global_state.dart';
import '../services/api_service.dart';
import 'document_hub_screen.dart';
import 'home_screen.dart';

class City {
  final int id;
  final String name;
  final String state;

  City({required this.id, required this.name, required this.state});
}

class VehicleSelectionScreen extends StatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  City? selectedCity;
  String? selectedVehicle;
  bool _isLoading = false;
  final TextEditingController _citySearchController = TextEditingController();

  final List<City> cities = [
    City(id: 1, name: 'Mumbai', state: 'Maharashtra'),
    City(id: 2, name: 'Pune', state: 'Maharashtra'),
    City(id: 3, name: 'Nashik', state: 'Maharashtra'),
    City(id: 4, name: 'Nagpur', state: 'Maharashtra'),
    City(id: 5, name: 'Aurangabad', state: 'Maharashtra'),
    City(id: 6, name: 'Shirdi', state: 'Maharashtra'),
    City(id: 7, name: 'Lonavala', state: 'Maharashtra'),
    City(id: 8, name: 'Kolhapur', state: 'Maharashtra'),
    City(id: 9, name: 'Delhi', state: 'Delhi'),
    City(id: 10, name: 'New Delhi', state: 'Delhi'),
    City(id: 11, name: 'Gurgaon', state: 'Haryana'),
    City(id: 12, name: 'Noida', state: 'Uttar Pradesh'),
    City(id: 13, name: 'Faridabad', state: 'Haryana'),
    City(id: 14, name: 'Bangalore', state: 'Karnataka'),
    City(id: 15, name: 'Mysore', state: 'Karnataka'),
    City(id: 16, name: 'Mangalore', state: 'Karnataka'),
    City(id: 17, name: 'Hubli', state: 'Karnataka'),
    City(id: 18, name: 'Hyderabad', state: 'Telangana'),
    City(id: 19, name: 'Warangal', state: 'Telangana'),
    City(id: 20, name: 'Karimnagar', state: 'Telangana'),
    City(id: 21, name: 'Chennai', state: 'Tamil Nadu'),
    City(id: 22, name: 'Coimbatore', state: 'Tamil Nadu'),
    City(id: 23, name: 'Madurai', state: 'Tamil Nadu'),
    City(id: 24, name: 'Salem', state: 'Tamil Nadu'),
    City(id: 25, name: 'Tiruchirappalli', state: 'Tamil Nadu'),
    City(id: 26, name: 'Kolkata', state: 'West Bengal'),
    City(id: 27, name: 'Howrah', state: 'West Bengal'),
    City(id: 28, name: 'Durgapur', state: 'West Bengal'),
    City(id: 29, name: 'Asansol', state: 'West Bengal'),
    City(id: 30, name: 'Siliguri', state: 'West Bengal'),
    City(id: 31, name: 'Jaipur', state: 'Rajasthan'),
    City(id: 32, name: 'Udaipur', state: 'Rajasthan'),
    City(id: 33, name: 'Jodhpur', state: 'Rajasthan'),
    City(id: 34, name: 'Kota', state: 'Rajasthan'),
    City(id: 35, name: 'Ajmer', state: 'Rajasthan'),
    City(id: 36, name: 'Ahmedabad', state: 'Gujarat'),
    City(id: 37, name: 'Surat', state: 'Gujarat'),
    City(id: 38, name: 'Vadodara', state: 'Gujarat'),
    City(id: 39, name: 'Rajkot', state: 'Gujarat'),
    City(id: 40, name: 'Bhavnagar', state: 'Gujarat'),
    City(id: 41, name: 'Indore', state: 'Madhya Pradesh'),
    City(id: 42, name: 'Bhopal', state: 'Madhya Pradesh'),
    City(id: 43, name: 'Gwalior', state: 'Madhya Pradesh'),
    City(id: 44, name: 'Jabalpur', state: 'Madhya Pradesh'),
    City(id: 45, name: 'Kanpur', state: 'Uttar Pradesh'),
    City(id: 46, name: 'Lucknow', state: 'Uttar Pradesh'),
    City(id: 47, name: 'Varanasi', state: 'Uttar Pradesh'),
    City(id: 48, name: 'Agra', state: 'Uttar Pradesh'),
    City(id: 49, name: 'Prayagraj', state: 'Uttar Pradesh'),
    City(id: 50, name: 'Ghaziabad', state: 'Uttar Pradesh'),
    City(id: 51, name: 'Patna', state: 'Bihar'),
    City(id: 52, name: 'Gaya', state: 'Bihar'),
    City(id: 53, name: 'Muzaffarpur', state: 'Bihar'),
    City(id: 54, name: 'Ranchi', state: 'Jharkhand'),
    City(id: 55, name: 'Jamshedpur', state: 'Jharkhand'),
    City(id: 56, name: 'Dhanbad', state: 'Jharkhand'),
    City(id: 57, name: 'Bhubaneswar', state: 'Odisha'),
    City(id: 58, name: 'Puri', state: 'Odisha'),
    City(id: 59, name: 'Cuttack', state: 'Odisha'),
    City(id: 60, name: 'Guwahati', state: 'Assam'),
    City(id: 61, name: 'Dibrugarh', state: 'Assam'),
    City(id: 62, name: 'Silchar', state: 'Assam'),
    City(id: 63, name: 'Chandigarh', state: 'Chandigarh'),
    City(id: 64, name: 'Amritsar', state: 'Punjab'),
    City(id: 65, name: 'Ludhiana', state: 'Punjab'),
    City(id: 66, name: 'Jalandhar', state: 'Punjab'),
    City(id: 67, name: 'Patiala', state: 'Punjab'),
    City(id: 68, name: 'Shimla', state: 'Himachal Pradesh'),
    City(id: 69, name: 'Manali', state: 'Himachal Pradesh'),
    City(id: 70, name: 'Dharamshala', state: 'Himachal Pradesh'),
    City(id: 71, name: 'Dehradun', state: 'Uttarakhand'),
    City(id: 72, name: 'Haridwar', state: 'Uttarakhand'),
    City(id: 73, name: 'Rishikesh', state: 'Uttarakhand'),
    City(id: 74, name: 'Srinagar', state: 'Jammu and Kashmir'),
    City(id: 75, name: 'Jammu', state: 'Jammu and Kashmir'),
    City(id: 76, name: 'Leh', state: 'Ladakh'),
    City(id: 77, name: 'Panaji', state: 'Goa'),
    City(id: 78, name: 'Margao', state: 'Goa'),
    City(id: 79, name: 'Vasco da Gama', state: 'Goa'),
    City(id: 80, name: 'Raipur', state: 'Chhattisgarh'),
    City(id: 81, name: 'Bilaspur,', state: 'Chhattisgarh'),
    City(id: 82, name: 'Durg', state: 'Chhattisgarh'),
    City(id: 83, name: 'Visakhapatnam', state: 'Andhra Pradesh'),
    City(id: 84, name: 'Vijayawada', state: 'Andhra Pradesh'),
    City(id: 85, name: 'Tirupati', state: 'Andhra Pradesh'),
    City(id: 86, name: 'Nellore', state: 'Andhra Pradesh'),
    City(id: 87, name: 'Kochi', state: 'Kerala'),
    City(id: 88, name: 'Thiruvananthapuram', state: 'Kerala'),
    City(id: 89, name: 'Kozhikode', state: 'Kerala'),
    City(id: 90, name: 'Thrissur', state: 'Kerala'),
    City(id: 91, name: 'Alappuzha', state: 'Kerala'),
    City(id: 92, name: 'Imphal', state: 'Manipur'),
    City(id: 93, name: 'Shillong', state: 'Meghalaya'),
    City(id: 94, name: 'Aizawl', state: 'Mizoram'),
    City(id: 95, name: 'Kohima', state: 'Nagaland'),
    City(id: 96, name: 'Itanagar', state: 'Arunachal Pradesh'),
    City(id: 97, name: 'Gangtok', state: 'Sikkim'),
    City(id: 98, name: 'Agartala', state: 'Tripura'),
    City(id: 99, name: 'Port Blair', state: 'Andaman and Nicobar Islands'),
    City(id: 100, name: 'Daman', state: 'Daman and Diu'),
    City(id: 101, name: 'Silvassa', state: 'Dadra and Nagar Haveli'),
    City(id: 102, name: 'Kavaratti', state: 'Lakshadweep'),
    City(id: 103, name: 'Pondicherry', state: 'Puducherry'),
    City(id: 104, name: 'Karur', state: 'Tamil Nadu'),
    City(id: 105, name: 'Erode', state: 'Tamil Nadu'),
    City(id: 106, name: 'Tirunelveli', state: 'Tamil Nadu'),
    City(id: 107, name: 'Vellore', state: 'Tamil Nadu'),
    City(id: 108, name: 'Belgaum', state: 'Karnataka'),
    City(id: 109, name: 'Bidar', state: 'Karnataka'),
    City(id: 110, name: 'Bijapur', state: 'Karnataka'),
    City(id: 111, name: 'Solapur', state: 'Maharashtra'),
    City(id: 112, name: 'Amravati', state: 'Maharashtra'),
    City(id: 113, name: 'Akola', state: 'Maharashtra'),
    City(id: 114, name: 'Sangli', state: 'Maharashtra'),
    City(id: 115, name: 'Satara', state: 'Maharashtra'),
    City(id: 116, name: 'Aligarh', state: 'Uttar Pradesh'),
    City(id: 117, name: 'Meerut', state: 'Uttar Pradesh'),
    City(id: 118, name: 'Bareilly', state: 'Uttar Pradesh'),
    City(id: 119, name: 'Mathura', state: 'Uttar Pradesh'),
    City(id: 120, name: 'Noida Extension', state: 'Uttar Pradesh'),
    City(id: 121, name: 'Ujjain', state: 'Madhya Pradesh'),
    City(id: 122, name: 'Sagar', state: 'Madhya Pradesh'),
    City(id: 123, name: 'Rewa', state: 'Madhya Pradesh'),
    City(id: 124, name: 'Bhilai', state: 'Chhattisgarh'),
    City(id: 125, name: 'Rourkela', state: 'Odisha'),
    City(id: 126, name: 'Sambalpur', state: 'Odisha'),
    City(id: 127, name: 'Hisar', state: 'Haryana'),
    City(id: 128, name: 'Rohtak', state: 'Haryana'),
    City(id: 129, name: 'Karnal', state: 'Haryana'),
    City(id: 130, name: 'Sonipat', state: 'Haryana'),
    City(id: 131, name: 'Tiruppur', state: 'Tamil Nadu'),
    City(id: 132, name: 'Hosur', state: 'Tamil Nadu'),
    City(id: 133, name: 'Kanchipuram', state: 'Tamil Nadu'),
    City(id: 134, name: 'Palakkad', state: 'Kerala'),
    City(id: 135, name: 'Kottayam', state: 'Kerala'),
    City(id: 136, name: 'Kannur', state: 'Kerala'),
    City(id: 137, name: 'Anantapur', state: 'Andhra Pradesh'),
    City(id: 138, name: 'Kurnool', state: 'Andhra Pradesh'),
    City(id: 139, name: 'Eluru', state: 'Andhra Pradesh'),
    City(id: 140, name: 'Tezpur', state: 'Assam'),
    City(id: 141, name: 'Nagaon', state: 'Assam'),
    City(id: 142, name: 'Bongaigaon', state: 'Assam'),
    City(id: 143, name: 'Haldwani', state: 'Uttarakhand'),
    City(id: 144, name: 'Rudrapur', state: 'Uttarakhand'),
    City(id: 145, name: 'Pithoragarh', state: 'Uttarakhand'),
    City(id: 146, name: 'Bikaner', state: 'Rajasthan'),
    City(id: 147, name: 'Alwar', state: 'Rajasthan'),
    City(id: 148, name: 'Bharatpur', state: 'Rajasthan'),
    City(id: 149, name: 'Bhuj', state: 'Gujarat'),
    City(id: 150, name: 'Gandhinagar', state: 'Gujarat'),
  ];

  final List<String> vehicleTypes = [
    'MINI',
    'SEDAN',
    'SUV',
    'SUV+',
    'TEMPO TRAVELER',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Need Help?'),
                  content: const Text('Please contact our support team at support@txigo.com if you face any issues during onboarding.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline, color: Color(0xFF1A73E8)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Profile Setup',
                  style: TextStyle(
                    color: Color(0xFF1A73E8),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search your city and pick your vehicle type.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 45),
                _buildLabel('Select Your City'),
                const SizedBox(height: 12),
                _buildSearchableCityBar(),
                const SizedBox(height: 35),
                _buildLabel('Select Your Vehicle Type'),
                const SizedBox(height: 12),
                _buildVehicleDropdown(),
                const SizedBox(height: 60),
                _buildContinueButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchableCityBar() {
    return Autocomplete<City>(
      displayStringForOption: (City option) => '${option.name}, ${option.state}',
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<City>.empty();
        }
        return cities.where((City option) {
          return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                 option.state.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (City selection) {
        setState(() {
          selectedCity = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Type to search city...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1A73E8)),
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF1A73E8)),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              height: 300,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final City option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(option.state),
                    leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVehicle,
          hint: Text('Choose your vehicle', style: TextStyle(color: Colors.grey.shade500)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1A73E8)),
          items: vehicleTypes.map((vehicle) {
            return DropdownMenuItem(
              value: vehicle,
              child: Text(vehicle),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedVehicle = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final bool isReady = selectedCity != null && selectedVehicle != null;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isReady && !_isLoading
            ? () async {
                setState(() => _isLoading = true);

                // Save city & vehicleType to GlobalState
                GlobalState.city = selectedCity!.name;
                // Normalize vehicle type for backend (MINI -> mini)
                GlobalState.vehicleType = selectedVehicle!.toLowerCase();

                // Persist city + vehicleType to backend immediately
                await ApiService.updateDriverProgress({
                  'city': GlobalState.city,
                  'vehicleType': GlobalState.vehicleType,
                });

                if (mounted) {
                  setState(() => _isLoading = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentHubScreen()),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Finish Setup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
