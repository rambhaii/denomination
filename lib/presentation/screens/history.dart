import 'package:denomination/core/data/db_helper.dart';
import 'package:denomination/logic/HomeController.dart';
import 'package:denomination/logic/NumberToWordsConverter.dart';

import 'package:denomination/presentation/screens/home_sceen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:denomination/core/data/db_helper.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dbHelper = DatabaseHelper.instance;

  late HomeController controller;
  String formatNumberWithComma(int number) {
    final formatter = NumberFormat("#,##0");
    return formatter.format(number);
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
  }

  void doNothing(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.fetchSaves(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final saves = snapshot.data!;
          return ListView.builder(
            itemCount: saves.length,
            itemBuilder: (context, index) {
              final save = saves[index];

              return Slidable(
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await _dbHelper.deleteSave(save['id']);
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Item deleted successfully')),
                          );

                          (context as Element).markNeedsBuild();
                        });
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) async {
                        final details =
                            await _dbHelper.fetchDetails(save['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                items: details,
                                isEdit: true,
                                id: save['id'],
                                oldRemak: save['remark']),
                          ),
                        );
                      },
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF21B7CA),
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) async {
                       var shareContent = '''
Denomination
General
Denomination 
${save['created_at']}
${save['remark']}
------------------------------
Rupees x Counts = Total
''';

                        final details =
                            await _dbHelper.fetchDetails(save['id']);
                        for (int i = 0; i < details.length; i++) {
                          print("ksjdfgkg  ${details[i]['multiplier']}");
                          final amount = details[i]['amount'];
                          final multiplier = details[i]['multiplier'];
                          final result = amount * multiplier;

                          shareContent += '''
$amount x $multiplier = ₹$result
''';
                        }

                        shareContent += '''
------------------------------
Grand Total Amount: 
₹ ${formatNumberWithComma(save['total'])}
Amount in Words:
${NumberToWordsConverter.convert(save['total'])} only/-}
''';

                        // Share the content
                        await Share.share(shareContent,
                            subject: 'Shared via Denomination App');

                        // Optionally, show a Snackbar as confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Shared successfully!')),
                        );
                      },
                      backgroundColor: Color.fromARGB(255, 52, 176, 83),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'Share',
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: Color(0xFF39424B),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Genral",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '₹ ${formatNumberWithComma(save['total'])}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        save['remark'],
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () async {
                       
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
