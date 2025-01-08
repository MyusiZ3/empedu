import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Impor intl

class MataUangPage extends StatefulWidget {
  @override
  _MataUangPageState createState() => _MataUangPageState();
}

class _MataUangPageState extends State<MataUangPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _result = '';

  // Daftar 10 mata uang dengan kode negara untuk bendera
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

      // Menggunakan NumberFormat untuk memformat hasil konversi
      String formattedResult =
          NumberFormat('#,###.##', 'id_ID').format(convertedAmount);

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
    // Simulasi nilai tukar
    Map<String, double> rates = {
      'USD-IDR': 15000, // USD ke IDR
      'IDR-USD': 0.000067, // IDR ke USD
      'USD-EUR': 0.85, // USD ke EUR
      'EUR-USD': 1.18, // EUR ke USD
      'IDR-EUR': 0.000057, // IDR ke EUR
      'EUR-IDR': 17500, // EUR ke IDR
      'USD-JPY': 110.0, // USD ke JPY
      'JPY-USD': 0.0091, // JPY ke USD
      'IDR-JPY': 0.0064, // IDR ke JPY
      'JPY-IDR': 1550.0, // JPY ke IDR
      'EUR-JPY': 129.0, // EUR ke JPY
      'JPY-EUR': 0.0078, // JPY ke EUR
      'USD-AUD': 1.35, // USD ke AUD
      'AUD-USD': 0.74, // AUD ke USD
      'IDR-AUD': 0.000091, // IDR ke AUD
      'AUD-IDR': 11000.0, // AUD ke IDR
      'EUR-AUD': 1.59, // EUR ke AUD
      'AUD-EUR': 0.63, // AUD ke EUR
      'USD-CAD': 1.24, // USD ke CAD
      'CAD-USD': 0.81, // CAD ke USD
      'IDR-CAD': 0.000083, // IDR ke CAD
      'CAD-IDR': 12000.0, // CAD ke IDR
      'EUR-CAD': 1.47, // EUR ke CAD
      'CAD-EUR': 0.68, // CAD ke EUR
      'USD-CHF': 0.92, // USD ke CHF
      'CHF-USD': 1.09, // CHF ke USD
      'IDR-CHF': 0.000061, // IDR ke CHF
      'CHF-IDR': 16000.0, // CHF ke IDR
      'EUR-CHF': 0.98, // EUR ke CHF
      'CHF-EUR': 1.02, // CHF ke EUR
      'USD-CNY': 6.45, // USD ke CNY
      'CNY-USD': 0.155, // CNY ke USD
      'IDR-CNY': 0.00042, // IDR ke CNY
      'CNY-IDR': 2350.0, // CNY ke IDR
      'EUR-CNY': 7.57, // EUR ke CNY
      'CNY-EUR': 0.13, // CNY ke EUR
      'USD-SGD': 1.35, // USD ke SGD
      'SGD-USD': 0.74, // SGD ke USD
      'IDR-SGD': 0.000048, // IDR ke SGD
      'SGD-IDR': 21000.0, // SGD ke IDR
      'EUR-SGD': 1.49, // EUR ke SGD
      'SGD-EUR': 0.67, // SGD ke EUR
    };

    return rates['$from-$to'] ?? 1.0; // Default jika pasangan tidak ditemukan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Konversi Mata Uang',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            Text(
              'Masukkan Jumlah Uang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
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
                prefixIcon: Icon(Icons.money, color: Colors.grey[800]),
                labelText: 'Jumlah',
                labelStyle: TextStyle(color: Colors.grey[700]),
              ),
              style: TextStyle(color: Colors.grey[800], fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency['code'],
                              child: Row(
                                children: [
                                  Image.network(
                                    'https://flagcdn.com/w40/${currency['country']}.png',
                                    width: 30,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Text(currency['code']!),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Dari',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    items: _currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency['code'],
                              child: Row(
                                children: [
                                  Image.network(
                                    'https://flagcdn.com/w40/${currency['country']}.png',
                                    width: 30,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Text(currency['code']!),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Ke',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Konversi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _result.isEmpty
                    ? 'Hasil konversi akan tampil di sini'
                    : 'Hasil: $_result',
                style: TextStyle(
                  fontSize: 14,
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
