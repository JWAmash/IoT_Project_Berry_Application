import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/config/palette.dart';

class ScreenLanternLog extends StatefulWidget {
  const ScreenLanternLog({super.key});

  @override
  State<ScreenLanternLog> createState() => _ScreenLanternLogState();
}

class _ScreenLanternLogState extends State<ScreenLanternLog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime sevenDaysAgo;
  late String sevenDaysAgoString;
  bool desc =true;

  @override
  void initState() {
    sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    sevenDaysAgoString =
    'lantern_data_${sevenDaysAgo.year}${sevenDaysAgo.month.toString().padLeft(2, '0')}${sevenDaysAgo.day.toString().padLeft(2, '0')}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // 상태 표시줄 배경을 투명하게 설정
          statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘을 어둡게 설정 (밝은 배경일 때)
        ),
        title: Text("랜턴 작동 기록",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: Palette.logIntro,
              child: Text('최근 7일 작동 기록',style: TextStyle(fontWeight: FontWeight.bold,color: Palette.buttonColor),),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     ElevatedButton(onPressed: (){
            //       setState(() {
            //         desc = true;
            //       });
            //     }, child: Text('내림차순')),
            //     ElevatedButton(onPressed: (){setState(() {
            //       desc = false;
            //     });}, child: Text('오름차순')),
            //   ],
            // ),

            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('data')
                  .doc('lantern')
                  .collection('logs')
                  .where(FieldPath.documentId,
                  isGreaterThanOrEqualTo: sevenDaysAgoString)
              // .orderBy(FieldPath.documentId, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                print('몇번가져오는지1');
                if (snapshot.hasError) {
                  return Text("오류발생");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  print('몇번가져오는지2');
                  return CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("데이터가 없습니다"));
                } else {
                  final logs= snapshot.data!.docs;
                  return Expanded(
                      child: ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(),
                        itemBuilder: (context, index) {
                          print('몇번가져오는지3');
                          DocumentSnapshot document=logs[logs.length - 1 - index];
                          // if(desc){
                          //    document = logs[logs.length - 1 - index];
                          // }else{
                          //   document = logs[index];
                          // }


                          Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                          String docId = document.id;
                          String dateTime =
                          docId.substring(15); // 'YYYYMMDD_HHMMSS' 부분 추출
                          Timestamp time = data['operationTime'];
                          String operation = data['operationCommand'];
                          String operationMode = data['operationMode'];
                          double IdrValue = data['ldrValue'].toDouble();
                          String opTime = DateFormat('yyyy/MM/dd a hh:mm')
                              .format(time.toDate());

                          return ListTile(
                            title: Text('작동시간: ${opTime}'),
                            subtitle: Text(
                              '동작: ${operation} 작동방식: ${operationMode} 조도센서수치: ${IdrValue}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
