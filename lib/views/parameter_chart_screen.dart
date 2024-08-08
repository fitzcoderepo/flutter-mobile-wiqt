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
        iconTheme: const IconThemeData(
            color: Colors.white,
          )
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
          right: MediaQuery.of(context).size.width * 0.05,
          left: MediaQuery.of(context).size.width * 0.03,
        ),
        child: Column(
          children: <Widget>[
            Text(
              widget.parameterName.toUpperCase(),
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
    

    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 0;

    double minY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(min) : 0;
    double maxY =
        chartData.isNotEmpty ? chartData.map((e) => e.y).reduce(max) : 0;

    // add padding to minY and maxY
    double padding = (maxY - minY) * 0.1; // 10%
    minY -= padding;
    maxY += padding;
    // round min and max Y to nearest whole number
    minY = minY.floorToDouble();
    maxY = maxY.ceilToDouble();

    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,

      lineBarsData: [
        LineChartBarData(
          spots: chartData,
          color: const Color.fromARGB(255, 15, 98, 165),
          barWidth: .5,
        ),
      ],
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
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 17,
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
                  fitInside: const SideTitleFitInsideData(enabled: true, distanceFromEdge: -13, axisPosition: 0, parentAxisSize: 0),
                  space: 2,
                  child: Text(text,
                      style: const TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 8)),
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
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 1.0,
                  angle: -0.3,
                  child: Text(value.toStringAsFixed(1),
                      style: const TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 8,
                      ),
                    ),
                );
            },
          ),
        ),
      ),
    );
  }
}
