import 'dart:async';

import 'package:denomination/logic/HomeController.dart';
import 'package:denomination/logic/NumberToWordsConverter.dart';
import 'package:denomination/presentation/screens/history.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'dart:io';

import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? items;

  bool isEdit;
  final int? id;
  final String? oldRemak;

  final String? category;

  HomeScreen(
      {super.key,
      this.items,
      required this.isEdit,
      this.id,
      this.oldRemak,
      this.category});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController controller;

  final remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());

    if (widget.isEdit) {
      for (var i = 0; i < widget.items!.length; i++) {
        controller.items[i]['id'] = widget.items![i]['id'];

        controller.controllers[i].text =
            widget.items![i]['multiplier'].toString();

        controller.items[i]['multiplier'] = widget.items![i]['multiplier'];
        controller.items[i]['result'] =
            widget.items![i]['amount'] * controller.items[i]['multiplier'];
      }
    }

    if (widget.isEdit) {
      controller.setSavedCategory(widget.category!);
      remarkController.text = widget.oldRemak!;
    }
  }

  Future<void> _saveUpdatedDetails(String updatedRemark) async {
    List<Map<String, dynamic>> updatedDetails = [];

    for (var i = 0; i < controller.controllers.length; i++) {
      int updatedMultiplier = int.parse(controller.controllers[i].text);
      int updatedAmount = controller.items[i]['amount']!;
      int updatedResult = updatedAmount * updatedMultiplier;

      updatedDetails.add({
        'id': controller.items[i]['id'],
        'amount': updatedAmount,
        'multiplier': updatedMultiplier,
        'result': updatedResult,
      });
    }

    Map<String, dynamic> saveData = {
      'remark': updatedRemark,
      'total': updatedDetails.fold(
          0, (int total, detail) => total + detail['result'] as int),
      'created_at': DateTime.now().toString(),
    };

    await controller.updateSaveAndDetails(widget.id!, saveData['remark'],
        saveData['total'], saveData, updatedDetails);

    Navigator.pop(context);
  }

  int number = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: SpeedDial(
        icon: Icons.bolt,
        animatedIconTheme: IconThemeData(size: 28.0),
        backgroundColor: Colors.blue,
        visible: true,
        curve: Curves.bounceInOut,
        children: [
          SpeedDialChild(
            child: Icon(Icons.refresh, color: Colors.white),
            backgroundColor: Colors.black.withOpacity(0.5),
            onTap: () {
              setState(() {
                for (int i = 0; i < controller.items.length; i++) {
                  controller.items[i]['multiplier'] = 0;
                  controller.controllers[i].text = ''.toString();
                  controller.items[i]['result'] = 0;
                }
                controller.setSavedCategory('');
                remarkController.text = '';
                widget.isEdit = false;
              });
            },
            label: 'Clear',
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            labelBackgroundColor: Colors.black.withOpacity(0.5),
          ),
          SpeedDialChild(
            child: Icon(Icons.download, color: Colors.white),
            backgroundColor: Colors.black.withOpacity(0.5),
            onTap: () {
              if (controller.getTotalResult() > 0) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: Material(
                        color: Color(0xFF12171d),
                        child: Container(
                          width: 400,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Obx(() => DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: Row(
                                          children: const [
                                            Expanded(
                                              child: Text(
                                                'Category',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        items: controller.categoryList.value
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        // Show the saved value in the dropdown
                                        value: controller.categoryList.contains(
                                                controller
                                                    .selectedCategory.value)
                                            ? controller.selectedCategory.value
                                            : null,
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.selectedCategory.value =
                                                value;
                                          }
                                        },
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 20,
                                          iconEnabledColor: Colors.black,
                                          iconDisabledColor: Colors.blue,
                                        ),
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          padding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  Colors.grey, // Border color
                                              width: 1.0, // Border width
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color(0xFF39424B),
                                          ),
                                          elevation: 2,
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                              left: 14, right: 14),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          elevation: 8,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color(0xFF39424B),
                                          ),
                                          scrollbarTheme: ScrollbarThemeData(
                                            radius: const Radius.circular(40),
                                            thickness:
                                                MaterialStateProperty.all(6),
                                            thumbVisibility:
                                                MaterialStateProperty.all(true),
                                          ),
                                        ),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextField(
                                  maxLines: 2,
                                  controller: remarkController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Fill your remark(if any)',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Color(0xFF39424B),
                                    hintStyle: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    //  Navigator.of(context).pop();
                                    _showSaveDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color(0xFF39424B).withOpacity(0.5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: const Text(
                                      "Save",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white, // Text color
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please add some number')),
                );
              }
            },
            label: 'Save',
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            labelBackgroundColor: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 15, bottom: 10),
              title: Obx(() {
                final total = controller.getTotalResult();

                return total > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '₹ $total',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${NumberToWordsConverter.convert(total)} only/-',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Denomination",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
              }),
              background: Image.asset(
                'assets/images/currency_banner.jpg',
                fit: BoxFit.cover,
                cacheWidth: 800,
              ),
            ),
            actions: [
              PopupMenuButton<int>(
                iconColor: Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => HistoryScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                color: Colors.white,
                elevation: 2,
              ),
            ],
          ),
          Obx(() {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final item = controller.items[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "₹ ${item['amount']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          " X",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: controller.controllers[index],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: const Color(0xFF39424B),
                              hintStyle: const TextStyle(color: Colors.white70),
                              hintText: '',
                              suffixIcon: controller
                                          .controllers[index].text.isNotEmpty &&
                                      controller.controllers[index].text != "0"
                                  ? IconButton(
                                      onPressed: () {
                                        controller.controllers[index].clear();
                                        controller.updateResult(index, '');
                                      },
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              controller.updateResult(index, value);
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "= ₹ ${item['result']}",
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.items.length,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF39424B),
          title: Text(
            "Confirmation",
            style: TextStyle(color: Colors.blue),
          ),
          content: Text(
            "Are you sure ?",
            style: TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 52, 55, 57)),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: const Text(
                  "No",
                  style: TextStyle(
                    color: Colors.blueAccent, // Text color
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 52, 55, 57)),
              ),
              onPressed: () async {
                final remark = remarkController.text;
                if (widget.isEdit) {
                  _saveUpdatedDetails(remark);
                  // await controller.updateSaveAndDetails(remark,widget.id!);
                } else {
                  await controller.saveData(remark);
                }
                Navigator.pop(context);
                Navigator.pop(context);
                setState(() {
                  for (int i = 0; i < controller.items.length; i++) {
                    controller.items[i]['multiplier'] = 0;
                    controller.controllers[i].text = ''.toString();
                    controller.items[i]['result'] = 0;
                    widget.isEdit = false;
                  }
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.blueAccent, // Text color
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
