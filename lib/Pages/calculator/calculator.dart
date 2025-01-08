import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

import 'suhu_page.dart';
import 'matauang_page.dart';
import 'berat_page.dart';

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
        _input = _evaluateExpression(_input);
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
                  "Pilih Konversi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800], // Elegan
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreativeConversionButton(
                      icon: Icons.thermostat_outlined,
                      label: 'Suhu',
                      color: Colors.blueGrey[100]!,
                      page: SuhuPage(),
                    ),
                    _buildCreativeConversionButton(
                      icon: Icons.attach_money,
                      label: 'Mata Uang',
                      color: Colors.green[100]!,
                      page: MataUangPage(),
                    ),
                    _buildCreativeConversionButton(
                      icon: Icons.fitness_center,
                      label: 'Berat',
                      color: Colors.pink[100]!,
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
              color: Colors.grey[800], // Elegan
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
        backgroundColor: Colors.white, // Latar belakang AppBar putih
        elevation: 0, // Menghilangkan border bagian atas
        centerTitle: true,
        title: IconButton(
          icon: Icon(Icons.swap_horiz, color: Colors.blueGrey[700]),
          onPressed: _showConversionPopup,
        ),
      ),
      backgroundColor: Colors.white, // Latar belakang keseluruhan putih
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _input,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700], // Elegan
                        ),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final buttonText = _getButtonText(index);
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey[300], // Soft grey for normal buttons
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                100), // Rounded corners for buttons
                          ),
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
                            color: buttonText == 'C' || buttonText == '='
                                ? Colors.red[600] // Red for 'C' and '=' text
                                : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
      '+'
    ];
    return buttons[index];
  }
}
