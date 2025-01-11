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
      } else if (_fromUnit == 'Pound' && _toUnit == 'Kilogram') {
        result = value / 2.20462;
      } else if (_fromUnit == 'Pound' && _toUnit == 'Gram') {
        result = value * 453.592;
      } else if (_fromUnit == 'Pound' && _toUnit == 'Ounce') {
        result = value * 16;
      } else if (_fromUnit == 'Pound' && _toUnit == 'Ton') {
        result = value / 2000;
      } else if (_fromUnit == 'Pound' && _toUnit == 'Milligram') {
        result = value * 453592;
      } else if (_fromUnit == 'Pound' && _toUnit == 'Carat') {
        result = value * 2267.96;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Kilogram') {
        result = value / 35.274;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Gram') {
        result = value * 28.3495;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Pound') {
        result = value / 16;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Ton') {
        result = value / 35273.92;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Milligram') {
        result = value * 28349.5;
      } else if (_fromUnit == 'Ounce' && _toUnit == 'Carat') {
        result = value * 1417.48;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Kilogram') {
        result = value * 1000;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Gram') {
        result = value * 1000000;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Pound') {
        result = value * 2000;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Ounce') {
        result = value * 35273.92;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Milligram') {
        result = value * 1000000000;
      } else if (_fromUnit == 'Ton' && _toUnit == 'Carat') {
        result = value * 5000000;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Kilogram') {
        result = value / 1000000;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Gram') {
        result = value / 1000;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Pound') {
        result = value * 0.00000220462;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Ounce') {
        result = value * 0.000035274;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Ton') {
        result = value * 0.000000001;
      } else if (_fromUnit == 'Milligram' && _toUnit == 'Carat') {
        result = value * 0.005;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Kilogram') {
        result = value / 5000;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Gram') {
        result = value / 5;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Pound') {
        result = value * 0.000440924;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Ounce') {
        result = value * 0.017753;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Ton') {
        result = value * 0.000002;
      } else if (_fromUnit == 'Carat' && _toUnit == 'Milligram') {
        result = value * 200;
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
        title: Text(
          'Weight Conversion',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[800],
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[200]!, Colors.grey[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Enter Weight',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Input field
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
                prefixIcon: Icon(Icons.scale, color: Colors.grey[800]),
                labelText: 'Weight',
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            // Dropdowns for unit selection
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _fromUnit,
                      items: [
                        'Kilogram',
                        'Gram',
                        'Pound',
                        'Ounce',
                        'Ton',
                        'Milligram',
                        'Carat'
                      ]
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _fromUnit = value!;
                        });
                      },
                      underline: SizedBox(),
                      isExpanded: true,
                      icon:
                          Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _toUnit,
                      items: [
                        'Kilogram',
                        'Gram',
                        'Pound',
                        'Ounce',
                        'Ton',
                        'Milligram',
                        'Carat'
                      ]
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _toUnit = value!;
                        });
                      },
                      underline: SizedBox(),
                      isExpanded: true,
                      icon:
                          Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Convert Button
            ElevatedButton(
              onPressed: _convertWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Convert',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Conversion Result
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _result.isEmpty
                    ? 'The result will appear here'
                    : 'Result: $_result',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
