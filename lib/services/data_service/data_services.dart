import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_services.dart';

class DataService {
  final ProjectApi _projectApiService =
      ProjectApi(storage: SecureStorageManager.storage);
  final UnitApi _unitApiService =
      UnitApi(storage: SecureStorageManager.storage);

  Future<Map<String, dynamic>> fetchUserUnits() async {
    return await _projectApiService.fetchUserUnits();
  }


  Future<void> fetchAllUnitDetails(List<dynamic> units) async {
    List<Future> fetchDetails = [];
    for (var unit in units) {
      var unitId = unit['id'];
      if (unitId == null) continue;
      var fetchTask =
          _unitApiService.fetchUnitDetails(unitId.toString()).then((result) {
      }).catchError((e) {
        // error
      });

      fetchDetails.add(fetchTask);
    }
    await Future.wait(fetchDetails);
  }

  Future<List<dynamic>> loadInitialData(BuildContext context) async {
    List<dynamic> units = [];
    try {
      Map<String, dynamic> projectData = await fetchUserUnits();
      units = projectData['units'] ?? [];

      await fetchAllUnitDetails(units);
    } catch (e) {
      _showErrorDialog(context);
    }
    return units;
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content:
            const Text('Failed to load project data. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
