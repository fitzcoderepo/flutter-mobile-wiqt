import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:wateriqcloud_mobile/services/api_service.dart';
import 'base_scaffold.dart';
import 'dart:math';

class ParameterChartScreen extends StatefulWidget {
  final int unitId;
  final String parameterName;

  const ParameterChartScreen(
      {super.key, required this.unitId, required this.parameterName});

  @override
  _ParameterChartScreenState createState() => _ParameterChartScreenState();
}

class _ParameterChartScreenState extends State<ParameterChartScreen> {
  List<FlSpot> chartData = [];
  FlSpot? selectedSpot; //state variable for selected spots
  bool isLoading = true;
  int yAxisInterval = 2; // Adjust this value as needed

  LineTooltipItem getTooltipForSelectedSpot(FlSpot spot) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
    final String formattedTime = DateFormat.Hm().format(time);
    return LineTooltipItem(
      '${spot.y} at $formattedTime',
      const TextStyle(color: Color.fromARGB(255, 11, 11, 11)),
    );
  }

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

  final _apiService = ChartDataApi(storage: const FlutterSecureStorage());

  Future<void> _fetchChartData() async {
    try {
      final data = await _apiService.fetchChartData(
          widget.unitId.toString(), widget.parameterName);
      setState(() {
        chartData = data;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        isLoading = true;
      });
      throw Exception(e);
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
    // double minY = 0;
    // double maxY = 50;

    return BaseScaffold(
      title: ('${widget.parameterName} Chart'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chartData.isEmpty
              ? const Center(child: Text('No data available.'))
              : Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        0.10, // 10% of screen height
                    bottom: MediaQuery.of(context).size.height *
                        0.01, // 1% of screen height
                    right: MediaQuery.of(context).size.width *
                        0.02, // 2% of screen width
                    left: MediaQuery.of(context).size.width *
                        0.02, // 2% of screen width
                  ),
                  child: Column(
                    children: <Widget>[
                      Text('${widget.parameterName} chart',
                          style: const TextStyle(
                            color: darkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: LineChart(
                          LineChartData(
                            lineTouchData: LineTouchData(
                              // keep tooltip displayed after touch
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? lineTouchResponse) {
                                if (event is! FlPanEndEvent &&
                                    event is! FlLongPressEnd) {
                                  setState(() {
                                    if (lineTouchResponse?.lineBarSpots !=
                                        null) {
                                      selectedSpot = lineTouchResponse
                                          ?.lineBarSpots?.first;
                                    } else {
                                      selectedSpot = null;
                                    }
                                  });
                                }
                              },
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.blue,
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                getTooltipItems:
                                    (List<LineBarSpot> touchedSpots) {
                                  if (selectedSpot != null) {
                                    return [
                                      getTooltipForSelectedSpot(selectedSpot!)
                                    ];
                                  }
                                  return [];
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (value, meta) {
                                    // Find the index of the current value in the chartData
                                    int index = chartData
                                        .indexWhere((spot) => spot.x == value);

                                    // Check if the current index is a multiple of 4
                                    if (index % 4 == 0 ||
                                        index == chartData.length - 1) {
                                      final DateTime time =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              value.toInt());
                                      final String text =
                                          DateFormat('MM/dd').format(time);
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 4,
                                        child: Text(text,
                                            style: const TextStyle(
                                                color: Color(0xff68737d),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10)),
                                      );
                                    } else {
                                      return Container(); // Return an empty container for non-4th values
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  // interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 3, // Adjust the space as needed
                                      child: Text(value.toStringAsFixed(0),
                                          style: const TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) => const FlLine(
                                color: Color(0xff37434d),
                                strokeWidth: 0.5,
                              ),
                              getDrawingVerticalLine: (value) => const FlLine(
                                color: Color(0xff37434d),
                                strokeWidth: 0.5,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                  color: const Color(0xff37434d), width: 0.5),
                            ),
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartData,
                                isStepLineChart: false,
                                isCurved: false,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                shadow: const Shadow(
                                    color: Colors.black,
                                    blurRadius: 4.5,
                                    offset: Offset(2, 2)),
                                dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (spot, barData) {
                                    // Logic to determine if the dot should be shown for each spot
                                    return true; // example: return true to show all dots
                                  },
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 3, // custom radius
                                      color: Colors.blue, // custom color
                                      strokeWidth: 1,
                                      strokeColor: Colors.black,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: false,
                                  color: Colors.blue.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
    );
  }
}
