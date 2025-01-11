import 'package:flutter/material.dart';

class BeratPage extends StatefulWidget {
  @override
  _BeratPageState createState() => _BeratPageState();
}

class _BeratPageState extends State<BeratPage> {
  final TextEditingController _controller = TextEditingController();
  String _fromUnit = 'Kilogram';
  String _toUnit = 'Gram';
  String _result = '';

  void _convertWeight() {
    try {
      double value = double.parse(_controller.text);
      double result;

      if (_fromUnit == _toUnit) {
        result = value;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Gram') {
        result = value * 1000;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Pound') {
        result = value * 2.20462;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Ounce') {
        result = value * 35.274;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Ton') {
        result = value / 1000;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Milligram') {
        result = value * 1000000;
      } else if (_fromUnit == 'Kilogram' && _toUnit == 'Carat') {
        result = value * 5000;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Kilogram') {
        result = value / 1000;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Pound') {
        result = value * 0.00220462;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Ounce') {
        result = value * 0.035274;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Ton') {
        result = value / 1000000;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Milligram') {
        result = value * 1000;
      } else if (_fromUnit == 'Gram' && _toUnit == 'Carat') {
        result = value * 5;
      } else {
        result = value;
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
        title: Text(
          'Weight Conversion',
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
              'Enter Weight',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff7b88ff),
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
                prefixIcon: Icon(Icons.scale, color: const Color(0xff7b88ff)),
                labelText: 'Weight',
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
              onPressed: _convertWeight,
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
        items: [
          'Kilogram',
          'Gram',
          'Pound',
          'Ounce',
          'Ton',
          'Milligram',
          'Carat',
        ]
            .map(
              (unit) => DropdownMenuItem(
                value: unit,
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xff7b88ff)),
      ),
    );
  }
}
