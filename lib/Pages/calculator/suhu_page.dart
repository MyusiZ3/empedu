import 'package:flutter/material.dart';

class SuhuPage extends StatefulWidget {
  @override
  _SuhuPageState createState() => _SuhuPageState();
}

class _SuhuPageState extends State<SuhuPage> {
  final TextEditingController _controller = TextEditingController();
  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';
  String _result = '';

  void _convertTemperature() {
    try {
      double value = double.parse(_controller.text);
      double result;

      if (_fromUnit == _toUnit) {
        result = value;
      } else if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
        result = (value * 9 / 5) + 32;
      } else if (_fromUnit == 'Celsius' && _toUnit == 'Kelvin') {
        result = value + 273.15;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
        result = (value - 32) * 5 / 9;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
        result = (value - 32) * 5 / 9 + 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celsius') {
        result = value - 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Fahrenheit') {
        result = (value - 273.15) * 9 / 5 + 32;
      } else {
        result = value; // Default case
      }

      setState(() {
        _result = '${result.toStringAsFixed(2)} $_toUnit';
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temperature',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xff7b88ff),
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
            const Text(
              'Enter Temperature',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff7b88ff),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Input Field
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.thermostat, color: Color(0xff7b88ff)),
                labelText: 'Temperature',
                labelStyle: TextStyle(color: Colors.grey[600]),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _fromUnit,
                    onChanged: (value) {
                      setState(() {
                        _fromUnit = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    value: _toUnit,
                    onChanged: (value) {
                      setState(() {
                        _toUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Convert Button
            ElevatedButton(
              onPressed: _convertTemperature,
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

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final List<String> units = ['Celsius', 'Fahrenheit', 'Kelvin'];
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
        items: units.map((unit) {
          return DropdownMenuItem(
            value: unit,
            child: Row(
              children: [
                Icon(
                  unit == 'Celsius'
                      ? Icons.ac_unit
                      : unit == 'Fahrenheit'
                          ? Icons.thermostat
                          : Icons.cloud,
                  color: const Color(0xff7b88ff),
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
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
