import 'package:empedu/pages/calculator/berat_page.dart';
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:intl/intl.dart'; // Untuk format angka dengan koma

import 'suhu_page.dart';
import 'matauang_page.dart';
import 'package:empedu/pages/calculator/berat_page.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '';

  void _appendToInput(String text) {
    setState(() {
      _input += text;
    });
  }

  void _clearInput() {
    setState(() {
      _input = '';
    });
  }

  void _calculateResult() {
    try {
      setState(() {
        String result = _evaluateExpression(_input);
        _input = _formatWithCommas(result); // Format hasil dengan koma
      });
    } catch (e) {
      setState(() {
        _input = 'Error';
      });
    }
  }

  String _evaluateExpression(String expression) {
    try {
      final expr = Expression.parse(expression);
      final evaluator = ExpressionEvaluator();
      final result = evaluator.eval(expr, {});
      if (result is num) {
        if (result % 1 == 0) {
          return result.toInt().toString();
        }
        return result.toString();
      }
      return 'Error';
    } catch (e) {
      return 'Error';
    }
  }

  /// Fungsi untuk memformat angka dengan koma (1,000 / 10,000)
  String _formatWithCommas(String input) {
    if (input == 'Error') return input; // Jika error, kembalikan langsung
    try {
      final number = double.parse(input.replaceAll(',', '')); // Parsing angka
      final formatter = NumberFormat('#,###'); // Format dengan koma
      return formatter.format(number);
    } catch (e) {
      return input; // Jika parsing gagal, kembalikan input asli
    }
  }

  void _showConversionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Choose Conversion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreativeConversionButton(
                      icon: Icons.thermostat_outlined,
                      label: 'Temperature',
                      color: Color(0xff7b88ff),
                      page: SuhuPage(),
                    ),
                    _buildCreativeConversionButton(
                      icon: Icons.attach_money,
                      label: 'Currency',
                      color: Color(0xff7b88ff),
                      page: MataUangPage(),
                    ),
                    _buildCreativeConversionButton(
                      icon: Icons.monitor_weight,
                      label: 'Weight',
                      color: Color(0xff7b88ff),
                      page: BeratPage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreativeConversionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: IconButton(
          icon: Icon(Icons.swap_horiz, color: Color(0xff7b88ff)),
          onPressed: _showConversionPopup,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xff7b88ff),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Display area (Proportional Flex)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // 40% dari layar
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _input,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff7b88ff),
                  ),
                ),
              ),
            ),
          ),
          // Buttons area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xfff5f5f5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  final buttonText = _getButtonText(index);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonText == 'C' || buttonText == '='
                          ? Color(0xff7b88ff)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black26,
                    ),
                    onPressed: () {
                      if (buttonText == 'C') {
                        _clearInput();
                      } else if (buttonText == '=') {
                        _calculateResult();
                      } else {
                        _appendToInput(buttonText);
                      }
                    },
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: buttonText == 'C' || buttonText == '='
                            ? Colors.white
                            : Color(0xff7b88ff),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText(int index) {
    const buttons = [
      '7',
      '8',
      '9',
      '/',
      '4',
      '5',
      '6',
      '*',
      '1',
      '2',
      '3',
      '-',
      'C',
      '0',
      '=',
      '+',
    ];
    return buttons[index];
  }
}
