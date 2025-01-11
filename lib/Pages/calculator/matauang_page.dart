import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MataUangPage extends StatefulWidget {
  @override
  _MataUangPageState createState() => _MataUangPageState();
}

class _MataUangPageState extends State<MataUangPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _result = '';

  // List of 10 currencies with country codes for flags
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'country': 'us'},
    {'code': 'IDR', 'country': 'id'},
    {'code': 'EUR', 'country': 'eu'},
    {'code': 'JPY', 'country': 'jp'},
    {'code': 'AUD', 'country': 'au'},
    {'code': 'CAD', 'country': 'ca'},
    {'code': 'CHF', 'country': 'ch'},
    {'code': 'CNY', 'country': 'cn'},
    {'code': 'SGD', 'country': 'sg'},
  ];

  void _convertCurrency() {
    try {
      double amount = double.parse(_amountController.text);
      double rate = _getExchangeRate(_fromCurrency, _toCurrency);
      double convertedAmount = amount * rate;

      // Format the conversion result
      String formattedResult =
          NumberFormat('#,###.##', 'en_US').format(convertedAmount);

      setState(() {
        _result = '$formattedResult $_toCurrency';
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  double _getExchangeRate(String from, String to) {
    // Simulated exchange rates
    Map<String, double> rates = {
      'USD-IDR': 15000,
      'IDR-USD': 0.000067,
      'USD-EUR': 0.85,
      'EUR-USD': 1.18,
      'IDR-EUR': 0.000057,
      'EUR-IDR': 17500,
      'USD-JPY': 110.0,
      'JPY-USD': 0.0091,
      'IDR-JPY': 0.0064,
      'JPY-IDR': 1550.0,
      'USD-AUD': 1.35,
      'AUD-USD': 0.74,
      'USD-CAD': 1.24,
      'CAD-USD': 0.81,
      'USD-CHF': 0.92,
      'CHF-USD': 1.09,
      'USD-CNY': 6.45,
      'CNY-USD': 0.155,
      'USD-SGD': 1.35,
      'SGD-USD': 0.74,
    };

    return rates['$from-$to'] ?? 1.0; // Default if no rate is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Currency Converter',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: const Color(0xff7b88ff),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff7b88ff),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Enter Amount',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff7b88ff),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    Icon(Icons.attach_money, color: const Color(0xff7b88ff)),
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // Dropdowns for currency selection
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _toCurrency,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Convert Button
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7b88ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Convert',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Conversion Result
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _result.isEmpty
                    ? 'The result will appear here'
                    : 'Result: $_result',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7b88ff),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        items: _currencies.map((currency) {
          return DropdownMenuItem(
            value: currency['code'],
            child: Row(
              children: [
                Image.network(
                  'https://flagcdn.com/w40/${currency['country']}.png',
                  width: 30,
                  height: 20,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 10),
                Text(
                  currency['code']!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xff7b88ff)),
      ),
    );
  }
}
