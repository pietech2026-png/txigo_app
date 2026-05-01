import 'package:flutter/services.dart';

class HindiToEnglishDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    const hindi = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < hindi.length; i++) {
      text = text.replaceAll(hindi[i], english[i]);
    }
    
    // Also remove any other non-digit characters to keep it clean
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
