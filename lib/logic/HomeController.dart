import 'package:denomination/core/data/db_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
 
  var controllers = <TextEditingController>[];

  var items = [
    {
      "amount": 2000,
      "multiplier": 0,
      "result": 0,
    },
    {"amount": 500, "multiplier": 0, "result": 0},
    {"amount": 200, "multiplier": 0, "result": 0},
    {"amount": 100, "multiplier": 0, "result": 0},
    {"amount": 20, "multiplier": 0, "result": 0},
    {"amount": 10, "multiplier": 0, "result": 0},
    {"amount": 5, "multiplier": 0, "result": 0},
    {"amount": 2, "multiplier": 0, "result": 0},
    {"amount": 1, "multiplier": 0, "result": 0},
  ].obs;

  // Initialize controllers
  @override
  void onInit() {
    super.onInit();
    controllers = List.generate(
      items.length,
      (_) => TextEditingController(),
    );
  }

  var remark = ""; 
  // Dispose of controllers
  @override
  void onClose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.onClose();
  }

 
  void updateResult(int index, String value) {
    final multiplier =
        int.tryParse(value) ?? 0; 
    items[index]['multiplier'] = multiplier;

   
    items[index]['result'] =
        (items[index]['amount']! * multiplier).toInt(); 

    items.refresh(); 
  }

  int getTotalResult() {
    return items.fold(0, (int sum, item) => sum + (item['result'] as int));
  }

  final _dbHelper = DatabaseHelper.instance;

  Future<void> saveData(String remark) async {
    
    final total = getTotalResult();
    final saveId = await _dbHelper.insertSave({
      'remark': remark,
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });


    for (var item in items) {
      await _dbHelper.insertDetail({
        'save_id': saveId,
        'amount': item['amount'],
        'multiplier': item['multiplier'],
        'result': item['result'],
      });
    }
  }

  Future<void> updateSaveAndDetails(
      int saveId,
      String remark,
      int total,
      Map<String, dynamic> saveData,
      List<Map<String, dynamic>> updatedDetails) async {
   
    await _dbHelper.updateSave(saveId, {
      'remark': remark,
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });
    for (var detail in updatedDetails) {
      if (detail['id'] == null) {
        print("Error: Missing ID for detail: $detail");
        throw Exception("Cannot update a detail without an ID.");
      }
    }


    for (var detail in updatedDetails) {
      print("Detail ID: ${detail['id']}");

      if (detail['id'] != null) {
     
        await _dbHelper.updateDetail(
          detail['id'], 
          {
            'amount': detail['amount'],
            'multiplier': detail['multiplier'],
            'result': detail['result'],
          },
        );
      } else {
        // Insert new detail if no ID exists
        // await _dbHelper.insertDetail({
        //   'save_id': saveId,
        //   'amount': detail['amount'],
        //   'multiplier': detail['multiplier'],
        //   'result': detail['result'],
        // });
      }
    }
  }
}
