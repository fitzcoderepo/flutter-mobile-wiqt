import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_services.dart';

class DataService {
  final ProjectApi _projectApiService =
      ProjectApi(storage: SecureStorageManager.storage);
  final UnitApi _unitApiService =
      UnitApi(storage: SecureStorageManager.storage);

  Future<Map<String, dynamic>> fetchProjectData() async {
    return await _projectApiService.fetchProjectData();
  }

  Future<void> fetchAllUnitDetails(List<dynamic> units) async {
    List<Future> fetchTasks = [];
    for (var unit in units) {
      var unitId = unit['id'];
      if (unitId == null) continue;
      var task =
          _unitApiService.fetchUnitDetails(unitId.toString()).then((result) {
        // result
      }).catchError((e) {
        // error
      });

      fetchTasks.add(task);
    }
    await Future.wait(fetchTasks);
  }

  Future<List<dynamic>> loadInitialData(BuildContext context) async {
    List<dynamic> units = [];
    try {
      Map<String, dynamic> projectData = await fetchProjectData();
      units = projectData['units'];
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
