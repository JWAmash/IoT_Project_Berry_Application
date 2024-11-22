import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/config/palette.dart';

class DoorLockVisitLog extends StatefulWidget {
  final List<Map<String, dynamic>> familyList;
  final List<Map<String, dynamic>> acquaintanceList;
  const DoorLockVisitLog({super.key,required this.familyList,required this.acquaintanceList});

  @override
  State<DoorLockVisitLog> createState() => _DoorLockVisitLogState();
}


class _DoorLockVisitLogState extends State<DoorLockVisitLog> {
  late List<Map<String, dynamic>> familyList;
  late List<Map<String, dynamic>> acquaintanceList;
  late String todaytoString;
  final List<Map<String, dynamic>> dustData = [
    {'time': '12:00', 'name': '황정민','category':'가족'},
    {'time': '13:00', 'name': '사람D','category':'가족'},
    {'time': '14:00', 'name': '사람C','category':'가족'},
    {'time': '15:00', 'name': '','category':'외부인'},
    {'time': '16:00', 'name': '사람B','category':'가족'},
  ];
  late DateTime sevenDaysAgo;
  late String sevenDaysAgoString;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Color getColorByname(int name) {
  //   if (name <= 50) {
  //     return Colors.green;
  //   } else if (name <= 100) {
  //     return Colors.yellow;
  //   } else if (name <= 150) {
  //     return Colors.orange;
  //   } else {
  //     return Colors.red;
  //   }
  // }
  // List<String> familyList=[];
  // void processFamilyList(){
  //   for (var entry in widget.familyList) {
  //     String name = entry['name'];
  //     String info = entry['info'];
  //     familyList.add('$name: $info');
  //   }
  // }
  Future<Map<String, dynamic>?> _getEntryLog() async {
    print('검색날짜: $todaytoString');
    final docRef = FirebaseFirestore.instance
        .collection('data')
        .doc('doorlock')
        .collection('todayFamilyLogs')
        .doc(todaytoString);  // 여기에 실제 문서 ID를 넣어주세요

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      print('문서가 존재하지 않습니다.');
      return null;
    }
  }

  List<String> dropDownListCategory = ["전체", "가족", "지인", "외부인"];
  List<String> dropDownListName1 = ["가", "나", "다", "라"];
  List<String> dropDownListName2 = ["마", "바", "사", "아"];
  Map<String, dynamic>? selectedPerson;


  String? selectCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //   selectCategory = dropDownListCategory[0];
    // });
    DateTime nowDate = DateTime.now();
    todaytoString = '${nowDate.year}${nowDate.month.toString().padLeft(2,'0')}${nowDate.day.toString().padLeft(2,'0')}';
    sevenDaysAgo = nowDate.subtract(Duration(days: 7));
    sevenDaysAgoString =
    '${sevenDaysAgo.year}${sevenDaysAgo.month.toString().padLeft(2, '0')}${sevenDaysAgo.day.toString().padLeft(2, '0')}';
    familyList = widget.familyList;
    acquaintanceList = widget.acquaintanceList;
    print(familyList);

  }
  //
  //
  // List<Map<String, dynamic>> getFilteredRecords() {
  //   if (selectCategory == null || selectCategory == "전체") {
  //     // 전체를 선택한 경우 모든 데이터를 반환
  //     return dustData;
  //   }
  //
  //   if (selectCategory == "외부인") {
  //     // 외부인을 선택한 경우 카테고리가 외부인인 데이터만 반환
  //     return dustData.where((item) => item['category'] == "외부인").toList();
  //   }
  //
  //   if (selectedPerson == null) {
  //     // 이름이 선택되지 않은 경우 해당 카테고리의 모든 기록 반환
  //     return dustData.where((item) => item['category'] == selectCategory).toList();
  //   }
  //
  //   // 가족 또는 지인을 선택한 경우 해당 카테고리와 이름에 맞는 데이터 반환
  //   return dustData
  //       .where((item) =>
  //   item['category'] == selectCategory &&
  //       item['name'] == selectedPerson!['name'])
  //       .toList();
  // }

  // // 선택된 카테고리와 사람에 따른 기록 필터링
  // List<Map<String, dynamic>> getFilteredRecords() {
  //   if (selectCategory == null || selectedPerson == null) return [];
  //   return dustData
  //       .where((item) =>
  //   item['category'] == selectCategory &&
  //       item['name'] == selectedPerson!['name'])
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도어락 문열림 기록', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.green,
              child: Stack(
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getEntryLog(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text('데이터가 없습니다.'));
                      } else {
                        final data = snapshot.data!;
                        final entries = (data['entries'] as List<dynamic>?) ?? [];
                        print("이데이터 : $data");

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                '오늘의 가족 출입 로그',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 150, // 이미지 컨테이너의 높이 설정
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final item = entries[index] as Map<String, dynamic>;
                                  print('이건데 ${item['imageUrls']}');
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Image.network(
                                            item['imageUrls'],
                                            width: 110,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(height: 5),
                                          Text(item['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // 여기에 추가적인 정보를 표시할 수 있습니다.
                          ],
                        );
                      }
                    },
                  ),
                  // Container(
                  //   padding: EdgeInsets.only(left: 15, top: 15),
                  //   child: Text(
                  //     '금일 가족 출입',
                  //     style:
                  //         TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  // Center(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       Icon(Icons.account_circle,size: 80,),
                  //       Icon(Icons.account_circle,size: 80,),
                  //       Icon(Icons.account_circle,size: 80,)
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
            // Container(
            //   margin: EdgeInsets.only(left: 40,right: 40,top: 30),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       DropdownButton2(
            //         items: dropDownListCategory
            //             .map((item) =>
            //             DropdownMenuItem(value: item, child: Text(item)))
            //             .toList(),
            //         onChanged: (value) {
            //           setState(() {
            //             selectCategory = value!;
            //             selectedPerson = null;
            //           });
            //         },
            //         value: selectCategory,
            //         alignment: AlignmentDirectional.centerStart,
            //       ),
            //       // 두 번째 드롭다운: 이름 선택 (카테고리가 가족 또는 지인일 때만 표시)
            //       if (selectCategory != null && selectCategory != "전체" && selectCategory != "외부인")
            //         Container(
            //           //margin: EdgeInsets.only(left: 40, right: 40, top: 20),
            //           child: DropdownButton2<Map<String, dynamic>>(
            //             hint: Text("이름을 선택하세요"),
            //             value: selectedPerson,
            //             onChanged: (Map<String, dynamic>? newValue) {
            //               setState(() {
            //                 selectedPerson = newValue;
            //               });
            //             },
            //             items:
            //             (selectCategory == "가족" ? familyList : acquaintanceList)
            //                 .map<DropdownMenuItem<Map<String, dynamic>>>(
            //                     (Map<String, dynamic> value) {
            //                   return DropdownMenuItem<Map<String, dynamic>>(
            //                     value: value,
            //                     child: Text(value['name']),
            //                   );
            //                 }).toList(),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),

            // if (selectedFamily != null)
            //   Text(
            //     "Info: ${selectedFamily!['info']}",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // if (selectedAcquaintance != null)
            //   Text(
            //     "Info: ${selectedAcquaintance!['info']}",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // Flexible(
            //   flex: 1,
            //   child:ListView(
            //     children: getFilteredRecords().map((record) {
            //       return ListTile(
            //         title: Text('시간: ${record['time']}'),
            //         subtitle:
            //         Text('이름: ${record['name'].isNotEmpty ? record['name'] : "이름 없음"}'),
            //       );
            //     }).toList(),
            //   ),
            // ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              color: Colors.blue,
              child: Text('최근 7일 작동 기록',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            StreamBuilder<QuerySnapshot>(stream: _firestore
                .collection('data')
                .doc('doorlock')
                .collection('entry_logs')
                .where(FieldPath.documentId,
                isGreaterThanOrEqualTo: sevenDaysAgoString)
            // .orderBy(FieldPath.documentId, descending: true)
                .snapshots()
              , builder: (context, snapshot) {
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

                        DocumentSnapshot document=logs[logs.length-1-index];
                        // if(desc){
                        //    document = logs[logs.length - 1 - index];
                        // }else{
                        //   document = logs[index];
                        // }


                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                        String docId = document.id;


                        print("받은 기록데이터: $data");
                        Timestamp time = data['time'];
                        String name = data['name']??'이름 없음';
                        String method = data['method'];
                        String category = data['category'];
                        String opTime = DateFormat('yyyy/MM/dd a hh:mm')
                            .format(time.toDate());

                        return ListTile(
                          title: Text('작동시간: ${opTime}'),
                          subtitle: Text(
                            '카테고리: ${category} / 이름: $name / 작동방식: ${method}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    )
                );
              }
                },)
          ],
        ),
      ),
    );
  }
}
