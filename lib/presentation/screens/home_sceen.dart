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

  HomeScreen(
      {super.key, this.items, required this.isEdit, this.id, this.oldRemak});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController controller;

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
  }

  Future<void> _saveUpdatedDetails() async {
    List<Map<String, dynamic>> updatedDetails = [];


    for (var i = 0; i < controller.controllers.length; i++) {
      int updatedMultiplier = int.parse(controller.controllers[i].text);
      int updatedAmount = controller.items[i]['amount']!;
      int updatedResult = updatedAmount * updatedMultiplier;

      print("dkjfhjkghjh  ${controller.items[i]}");

      updatedDetails.add({
        'id': controller.items[i]['id'],
        'amount': updatedAmount,
        'multiplier': updatedMultiplier,
        'result': updatedResult,
      });
    }

    
    Map<String, dynamic> saveData = {
      'remark': widget.oldRemak, 
      'total': updatedDetails.fold(
          0, (int total, detail) => total + detail['result'] as int),
      'created_at': DateTime.now().toString(),
    };

   
    await controller.updateSaveAndDetails(widget.id!, saveData['remark'],
        saveData['total'], saveData, updatedDetails);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: buildSpeedDial(context, controller),
      body: CustomScrollView(
        slivers: [
           SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percentage = (constraints.maxHeight - kToolbarHeight) /
                    (200 - kToolbarHeight);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.symmetric(horizontal: 16),
                  title: percentage < 0.6
                      ? Obx(() => controller.getTotalResult() > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '₹ ${controller.getTotalResult()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                            ))
                      : SizedBox.shrink(),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/currency_banner.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(() {
                            final total = controller.getTotalResult();
                            return controller.getTotalResult() > 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '₹ $total',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${NumberToWordsConverter.convert(total)} only/-',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Denomination",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
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
                        vertical: 10.0, horizontal: 10.0),
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
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              controller.updateResult(index, value);
                            },
                          ),
                        ),
                        const SizedBox(width: 20.0), // Spacing
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

  SpeedDial buildSpeedDial(
    BuildContext context,
    HomeController controller,
  ) {
    final List<String> items = [];
    String? selectedValue;
    final remarkController = TextEditingController();

    if (widget.isEdit) {
      remarkController.text = widget.oldRemak!;
    }

    return SpeedDial(
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
                widget.isEdit = false;
              }
            });
          },
          label: 'Clear',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black.withOpacity(0.5),
        ),
        SpeedDialChild(
          child: Icon(Icons.download, color: Colors.white),
          backgroundColor: Colors.black.withOpacity(0.5),
          onTap: () {
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
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                isExpanded: true,
                                hint: Row(
                                  children: const [
                                    Expanded(
                                      child: Text(
                                        'General',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                items: items
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: selectedValue,
                                onChanged: (value) {},
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
                                  //  width: 160,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5)),
                                    color: Color(0xFF39424B),
                                  ),
                                  elevation: 2,
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 200,
                                  elevation: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5)),
                                    color: Color(0xFF39424B),
                                  ),
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            TextField(
                              maxLines: 2,
                              controller: remarkController,
                              readOnly: widget.isEdit ? true : false,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your remark here',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFF39424B),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final remark = remarkController.text;
                                if (widget.isEdit) {
                                  _saveUpdatedDetails();
                                  // await controller.updateSaveAndDetails(remark,widget.id!);
                                } else {
                                  await controller.saveData(remark);
                                }

                                Navigator.of(context).pop();
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
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
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
          },
          label: 'Save',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelBackgroundColor: Colors.black.withOpacity(0.5),
        ),
      ],
    );
  }

  Future<void> _showSaveDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          title: Text(
            "Data Saved Successfully",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Click the History button to view saved data or wait to dismiss.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );

                // Close the dialog
              },
              child: Text(
                "Done",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
