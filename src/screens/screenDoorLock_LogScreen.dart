import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> dustData = [
    {'time': '12:00', 'name': '황정민','category':'가족'},
    {'time': '13:00', 'name': '사람D','category':'가족'},
    {'time': '14:00', 'name': '사람C','category':'가족'},
    {'time': '15:00', 'name': '','category':'외부인'},
    {'time': '16:00', 'name': '사람B','category':'가족'},
  ];

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


  List<String> dropDownListCategory = ["전체", "가족", "지인", "외부인"];
  List<String> dropDownListName1 = ["가", "나", "다", "라"];
  List<String> dropDownListName2 = ["마", "바", "사", "아"];
  Map<String, dynamic>? selectedPerson;


  String? selectCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selectCategory = dropDownListCategory[0];
    });
    familyList = widget.familyList;
    acquaintanceList = widget.acquaintanceList;
    print(familyList);

  }


  List<Map<String, dynamic>> getFilteredRecords() {
    if (selectCategory == null || selectCategory == "전체") {
      // 전체를 선택한 경우 모든 데이터를 반환
      return dustData;
    }

    if (selectCategory == "외부인") {
      // 외부인을 선택한 경우 카테고리가 외부인인 데이터만 반환
      return dustData.where((item) => item['category'] == "외부인").toList();
    }

    if (selectedPerson == null) {
      // 이름이 선택되지 않은 경우 해당 카테고리의 모든 기록 반환
      return dustData.where((item) => item['category'] == selectCategory).toList();
    }

    // 가족 또는 지인을 선택한 경우 해당 카테고리와 이름에 맞는 데이터 반환
    return dustData
        .where((item) =>
    item['category'] == selectCategory &&
        item['name'] == selectedPerson!['name'])
        .toList();
  }

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
        title: Text('출입로그', style: TextStyle(fontSize: 22)),
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
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 15),
                    child: Text(
                      '금일 가족 출입',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.account_circle,size: 80,),
                        Icon(Icons.account_circle,size: 80,),
                        Icon(Icons.account_circle,size: 80,)
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 40,right: 40,top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton2(
                    items: dropDownListCategory
                        .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectCategory = value!;
                        selectedPerson = null;
                      });
                    },
                    value: selectCategory,
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  // if(selectCategory=='가족')
                  //   DropdownButton2<Map<String, dynamic>>(
                  //     hint: Text("이름을 선택하세요"),
                  //     value: selectedFamily,
                  //     onChanged: (Map<String, dynamic>? newValue) {
                  //       setState(() {
                  //         selectedFamily = newValue;
                  //       });
                  //     },
                  //     items: familyList.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> value) {
                  //       return DropdownMenuItem<Map<String, dynamic>>(
                  //         value: value,
                  //         child: Text(value['name']),
                  //       );
                  //     }).toList(),
                  // ),
                  // if(selectCategory=='지인')
                  //   DropdownButton2<Map<String, dynamic>>(
                  //     hint: Text("이름을 선택하세요"),
                  //     value: selectedAcquaintance,
                  //     onChanged: (Map<String, dynamic>? newValue) {
                  //       setState(() {
                  //         selectedAcquaintance = newValue;
                  //       });
                  //     },
                  //     items: acquaintanceList.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> value) {
                  //       return DropdownMenuItem<Map<String, dynamic>>(
                  //         value: value,
                  //         child: Text(value['name']),
                  //       );
                  //     }).toList(),
                  //   ),
                  // 두 번째 드롭다운: 이름 선택 (카테고리가 가족 또는 지인일 때만 표시)
                  if (selectCategory != null && selectCategory != "전체" && selectCategory != "외부인")
                    Container(
                      //margin: EdgeInsets.only(left: 40, right: 40, top: 20),
                      child: DropdownButton2<Map<String, dynamic>>(
                        hint: Text("이름을 선택하세요"),
                        value: selectedPerson,
                        onChanged: (Map<String, dynamic>? newValue) {
                          setState(() {
                            selectedPerson = newValue;
                          });
                        },
                        items:
                        (selectCategory == "가족" ? familyList : acquaintanceList)
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                                (Map<String, dynamic> value) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: value,
                                child: Text(value['name']),
                              );
                            }).toList(),
                      ),
                    ),
                ],
              ),
            ),

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
            Flexible(
              flex: 1,
              child:ListView(
                children: getFilteredRecords().map((record) {
                  return ListTile(
                    title: Text('시간: ${record['time']}'),
                    subtitle:
                    Text('이름: ${record['name'].isNotEmpty ? record['name'] : "이름 없음"}'),
                  );
                }).toList(),


              // ListView.separated(
              //   itemCount: dustData.length,
              //   separatorBuilder: (context, index) => Divider(
              //     color: Colors.grey, // 구분선 색상
              //     height: 1, // 구분선 높이
              //     thickness: 1, // 구분선 두께
              //   ),
              //   itemBuilder: (context, index) {
              //     var data = dustData[index];
              //     String name = data['name'];
              //     String time = data['time'];
              //     String category = data['category'];
              //     return ListTile(
              //       leading: SizedBox(width: 20,),
              //       //Icon(Icons.cloud, color: Colors.white54),
              //       title: Text('$category  | 출입자: $name,  출입시간: $time'),
              //       tileColor: Colors.black12,
              //     );
              //   },
              // )

              // ListView.builder(
              //   itemCount: dustData.length,
              //   itemBuilder: (context, index) {
              //     var data = dustData[index];
              //     int name = data['name'];
              //     String time = data['time'];
              //     // Color color = getColorByname(name);
              //
              //     return ListTile(
              //       leading: Icon(Icons.cloud, color: Colors.white54),
              //       title: Text('시간: $time, 출입자: $name'),
              //       tileColor: Colors.brown,
              //     );
              //   },
              // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
