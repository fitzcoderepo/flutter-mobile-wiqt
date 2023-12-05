import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:io' show Platform;

class ParameterChartScreen extends StatefulWidget {
  final int unitId;
  final String parameterName;

  ParameterChartScreen(
      {Key? key, required this.unitId, required this.parameterName})
      : super(key: key);

  @override
  _ParameterChartScreenState createState() => _ParameterChartScreenState();
}

class _ParameterChartScreenState extends State<ParameterChartScreen> {
  List<FlSpot> chartData = [];
  bool isLoading = true;
  bool _isLocalIphone = false;
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else if (_isLocalIphone) {
      return "http://192.168.1.139:8000";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }

  int yAxisInterval = 4; // Adjust this value as needed

  String getLeftTitles(double value) {
    // Check if the value is an integer multiple of the interval
    if ((value % yAxisInterval).toInt() == 0) {
      return value.toStringAsFixed(0); // Remove decimal places for integers
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    var baseUrl = getBaseUrl();
    final _storage = FlutterSecureStorage();
    final token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-reports-uid/${widget.unitId}'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      final currentTime = DateTime.now();
      final twentyFourHoursAgo = currentTime.subtract(Duration(hours: 24));

      setState(() {
        chartData = data
            .where((report) => DateTime.parse(report['report_date'])
                .isAfter(twentyFourHoursAgo))
            .map<FlSpot>((report) {
          double x = DateTime.parse(report['report_date'])
              .millisecondsSinceEpoch
              .toDouble();
          double y = double.tryParse(
                  report[widget.parameterName]?.toString() ?? '0') ??
              0;
          return FlSpot(x, y);
        }).toList();
        isLoading = false;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    // Providing default values for minX and maxX
    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 0;
    double minY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(min) : 0;
    double maxY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(max) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.parameterName} Chart'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : chartData.isEmpty
              ? Center(child: Text('No data available.'))
              : Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: false,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0xff37434d),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: const Color(0xff37434d),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTextStyles: (context, value) => const TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          getTitles: (value) {
                            var date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return DateFormat('MM/dd')
                                .format(date); // Format as Month/Day
                          },
                          margin: 8,
                        ),
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (context, value) => const TextStyle(
                            color: Color(0xff67727d),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          getTitles: getLeftTitles,
                          reservedSize: 28,
                          margin: 12,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                            color: const Color(0xff37434d), width: 1),
                      ),
                      minX: minX,
                      maxX: maxX,
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: false,
                          colors: [Colors.blue],
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) {
                              // Logic to determine if the dot should be shown for each spot
                              return true; // example: return true to show all dots
                            },
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3, // custom radius
                                color: Colors.blue, // custom color
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            colors: [Colors.blue.withOpacity(0.3)],
                          ),
                        ),
                      ],
                    ),
                  )),
    );
  }
}
