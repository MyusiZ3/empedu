import 'package:flutter/material.dart';

class SuhuPage extends StatefulWidget {
  @override
  _SuhuPageState createState() => _SuhuPageState();
}

class _SuhuPageState extends State<SuhuPage> {
  final TextEditingController _controller = TextEditingController();
  String _fromUnit = 'Celcius';
  String _toUnit = 'Fahrenheit';
  String _result = '';

  void _convertTemperature() {
    try {
      double value = double.parse(_controller.text);
      double result;

      if (_fromUnit == _toUnit) {
        result = value;
      } else if (_fromUnit == 'Celcius' && _toUnit == 'Fahrenheit') {
        result = (value * 9 / 5) + 32;
      } else if (_fromUnit == 'Celcius' && _toUnit == 'Kelvin') {
        result = value + 273.15;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celcius') {
        result = (value - 32) * 5 / 9;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
        result = (value - 32) * 5 / 9 + 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celcius') {
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
        title: Text(
          'Konversi Suhu',
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
            // Judul
            Text(
              'Masukkan Suhu',
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
                prefixIcon: Icon(Icons.thermostat, color: Colors.grey[800]),
                labelText: 'Suhu',
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            // Dropdowns untuk unit suhu dengan desain lebih menarik
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
                      items: ['Celcius', 'Fahrenheit', 'Kelvin']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Row(
                                  children: [
                                    Icon(
                                      unit == 'Celcius'
                                          ? Icons.ac_unit
                                          : unit == 'Fahrenheit'
                                              ? Icons.thermostat
                                              : Icons.cloud,
                                      color: Colors.grey[800],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      unit,
                                      style: TextStyle(fontFamily: 'Raleway'),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _fromUnit = value!;
                        });
                      },
                      underline: SizedBox(), // Remove default underline
                      isExpanded: true, // Make it expand
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
                      items: ['Celcius', 'Fahrenheit', 'Kelvin']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Row(
                                  children: [
                                    Icon(
                                      unit == 'Celcius'
                                          ? Icons.ac_unit
                                          : unit == 'Fahrenheit'
                                              ? Icons.thermostat
                                              : Icons.cloud,
                                      color: Colors.grey[800],
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      unit,
                                      style: TextStyle(fontFamily: 'Raleway'),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _toUnit = value!;
                        });
                      },
                      underline: SizedBox(), // Remove default underline
                      isExpanded: true, // Make it expand
                      icon:
                          Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Tombol Konversi
            ElevatedButton(
              onPressed: _convertTemperature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], // Sesuaikan warna tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Konversi',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Hasil Konversi
            Container(
              padding: EdgeInsets.all(10), // Menurunkan padding
              decoration: BoxDecoration(
                color: Colors.white, // Ganti dengan warna putih
                borderRadius: BorderRadius.circular(10), // Menurunkan radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8, // Menurunkan blur radius
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _result.isEmpty
                    ? 'Hasil akan tampil di sini'
                    : 'Hasil: $_result',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16, // Menurunkan ukuran font
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
