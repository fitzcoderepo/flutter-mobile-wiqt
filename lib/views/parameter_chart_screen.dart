import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:wateriqcloud_mobile/core/theme/app_pallete.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import '../services/wiqc_api_services/api_services.dart';
import 'dart:math';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

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
  final _apiService = ChartDataApi(storage: SecureStorageManager.storage);
  int yAxisInterval = 2;

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

  Future<void> _fetchChartData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _apiService.fetchChartData(
          widget.unitId.toString(), widget.parameterName);
      setState(() {
        chartData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching chart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.darkBlue,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: darkBlue),
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/CircleLogo.svg',
                height: 45,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChartData,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (chartData.isEmpty) {
      return const Center(child: Text('No data available.'));
    } else {
      return _buildChartData(context);
    }
  }

  Widget _buildChartData(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.10,
          bottom: MediaQuery.of(context).size.height * 0.01,
          right: MediaQuery.of(context).size.width * 0.04,
          left: MediaQuery.of(context).size.width * 0.02,
        ),
        child: Column(
          children: <Widget>[
            Text(
              '${widget.parameterName} chart',
              style: const TextStyle(
                color: darkBlue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            _buildLineChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.4,
      child: LineChart(
        _lineChartData(),
      ),
    );
  }

  LineChartData _lineChartData() {
    Map<String, Map<String, double>> parameterRanges = {
      'cport2': {'minY': 120.0, 'maxY': 128.0},
      'vport2': {'minY': 0.0, 'maxY': 6.0},
      'vport1': {'minY': 0.0, 'maxY': 6.0},
      'temp': {'minY': 0.0, 'maxY': 100.0},
      'ph': {'minY': 0.0, 'maxY': 10.0},
      'orp': {'minY': 150.0, 'maxY': 500.0},
      'spcond': {'minY': 2600.0, 'maxY': 2750.0},
      'turb': {'minY': -15.0, 'maxY': 25.0},
      'chl': {'minY': 100.0, 'maxY': 135.0},
      'bg': {'minY': 300.0, 'maxY': 450.0},
      'hdo': {'minY': 0.0, 'maxY': 15.0},
      'hdo_per': {'minY': 0.0, 'maxY': 100.0},
    };

    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 0;

    double minY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(min) : 0;
    double maxY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(max) : 0;

    if (parameterRanges.containsKey(widget.parameterName)) {
      minY = parameterRanges[widget.parameterName]!['minY']!;
      maxY = parameterRanges[widget.parameterName]!['maxY']!;
    }

    return LineChartData(
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            if (selectedSpot != null) {
              return [getTooltipForSelectedSpot(selectedSpot!)];
            }
            return [];
          },
        ),
        touchCallback:
            (FlTouchEvent event, LineTouchResponse? lineTouchResponse) {
          if (!(event is FlPanEndEvent || event is FlLongPressEnd)) {
            setState(() {
              if (lineTouchResponse?.lineBarSpots != null &&
                  lineTouchResponse!.lineBarSpots!.isNotEmpty) {
                selectedSpot = lineTouchResponse.lineBarSpots!.first;
              }
            });
          }
        },
        handleBuiltInTouches: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              // Find the index of the current value in the chartData
              int index = chartData.indexWhere((spot) => spot.x == value);

              // Check if the current index is a multiple of 4
              if (index % 4 == 0 || index == chartData.length - 1) {
                final DateTime time =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                final String text = DateFormat('MM/dd').format(time);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(text,
                      style: const TextStyle(
                          color: darkBlue,
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
            getTitlesWidget: (value, meta) {
              // Your logic for left titles
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 3,
                  child: Text(value.toStringAsFixed(0),
                      style: const TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10))); // Implement this based on your logic
            },
          ),
        ),
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color.fromARGB(255, 108, 108, 108),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: chartData,
          color: const Color.fromARGB(255, 15, 98, 165),
          barWidth: 1.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: false,
          ),
        ),
      ],
    );
  }
}
