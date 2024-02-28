import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'api_url.dart';

class ProjectApi {
  final FlutterSecureStorage storage;
  final baseUrl = BaseUrl.getBaseUrl();
  ProjectApi({required this.storage});

  // FETCH USER PROJECT
  Future<dynamic> fetchProjectData() async {
    // var baseUrl = urls.BaseUrl();
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/project-list'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load project data');
    }
  }
}

class UnitApi {
  final FlutterSecureStorage storage;
  final baseUrl = BaseUrl.getBaseUrl();
  UnitApi({required this.storage});

  Future<Map<String, dynamic>> fetchUnitDetails(String unitId) async {
    final token = await storage.read(key: 'auth_token');

    final unitDetailResponse = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-detail/$unitId'),
      headers: {'Authorization': 'Token $token'},
    );

    final unitReportResponse = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-reports-uid/$unitId'),
      headers: {'Authorization': 'Token $token'},
    );

    if (unitDetailResponse.statusCode == 200 &&
        unitReportResponse.statusCode == 200) {
      final unitDetails = json.decode(unitDetailResponse.body);
      final unitReportData = json.decode(unitReportResponse.body);

      Map<String, dynamic> latestReport = {};

      if (unitReportData['results'] is List &&
          unitReportData['results'].isNotEmpty) {
        latestReport = unitReportData['results'].last;
      } else {
        latestReport = <String, dynamic>{};
      }

      return {
        'unitDetails': unitDetails,
        'latestReport': latestReport,
      };
    } else {
      throw Exception('Failed to fetch unit details or reports');
    }
  }
}

class ChartDataApi {
  final FlutterSecureStorage storage;
  final baseUrl = BaseUrl.getBaseUrl();
  ChartDataApi({required this.storage});
      Future<List<FlSpot>> fetchChartData(String unitId, String parameterName) async {
    var baseUrl = BaseUrl.getBaseUrl();
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-reports-uid/$unitId'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      final currentTime = DateTime.now();
      final twentyFourHoursAgo = currentTime.subtract(const Duration(hours: 24));

      final chartData = data
          .where((report) => DateTime.parse(report['report_date']).isAfter(twentyFourHoursAgo))
          .map<FlSpot>((report) {
            double x = DateTime.parse(report['report_date']).millisecondsSinceEpoch.toDouble();
            double y = double.tryParse(report[parameterName]?.toString() ?? '0') ?? 0;
            return FlSpot(x, y);
          }).toList();

      return chartData;
    } else {
      throw Exception('Failed to fetch chart data');
    }
  }
}
