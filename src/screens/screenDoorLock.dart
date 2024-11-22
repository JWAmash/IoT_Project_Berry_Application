import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/config/mqtt_topic.dart';
import 'package:iot_project_berry/src/config/palette.dart';
import 'package:iot_project_berry/src/screens/screenDoorLock_LogScreen.dart';
import 'package:iot_project_berry/src/screens/screen_doorLock_temporarypassword.dart';
import 'package:iot_project_berry/src/screens/screen_doorlock_faceadd.dart';

class screenDoorLock extends StatefulWidget {
  const screenDoorLock({super.key});

  @override
  State<screenDoorLock> createState() => _screenDoorLockState();
}

class _screenDoorLockState extends State<screenDoorLock> {
  List<Map<String, dynamic>> familyList=[];
  List<Map<String, dynamic>> acquaintanceList=[];
  //Topic
  late DateTime twoDaysAgo;
  late String twoDaysAgoString;
  late String todaytoString;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //DateTime nowDate= DateTime.now();
    DateTime nowDate= DateTime.now();
    twoDaysAgo = nowDate.subtract(Duration(days: 7));
    todaytoString = '${nowDate.year}${nowDate.month.toString().padLeft(2,'0')}${nowDate.day.toString().padLeft(2,'0')}';
    twoDaysAgoString =
    '${twoDaysAgo.year}${twoDaysAgo.month.toString().padLeft(2, '0')}${twoDaysAgo.day.toString().padLeft(2, '0')}';
  }
  final List<Map<String, dynamic>> statistics = [
    {"title": "사람 A", "category": "가족", "value": '2024/05/16'},
    {"title": "사람 B", "category": "지인", "value": '2024/05/16'},
    {"title": "사람 C", "category": "가족", "value": '2024/05/16'},
    {"title": "사람 D", "category": "가족", "value": '2024/05/16'},
    {"title": "사람 E", "category": "지인", "value": '2024/05/16'},
    {"title": "사람 F", "category": "가족", "value": '2024/05/16'},
    {"title": "사람 A", "category": "지인", "value": '2024/05/16'},
    {"title": "사람 B", "category": "가족", "value": '2024/05/16'},
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<List<Map<String, dynamic>>> _fetchPeople(String category) async {
    if (category == '가족') {
      return [
        {
          'name': '홍길동',
          'imageUrls': ['https://placehold.co/100x100'], // 임시 이미지 URL,
          'info': '아버지'
        },
        {
          'name': '김철수',
          'imageUrls': ['https://placehold.co/100x100'], // 임시 이미지 URL
          'info': '아들'
        },
        {
          'name': '이영희',
          'imageUrls': ['https://placehold.co/100x100'], // 임시 이미지 URL
          'info': '딸'
        },
      ];
    } else {
      return [];
    }
  }
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


  // 등록인원 목록 카드
  Widget _buildCard(Map<String, dynamic> person) {
    print('이 데이터 테스트하는데$person');
    return GestureDetector(
      onTap: () => _showDetailDialog(context, person),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Image.network(person['imageUrls'][0],
                width: 100,
                height: 100,
                fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, size: 100); // 오류 발생 시 대체 위젯
            }),
            SizedBox(height: 8),
            Text(person['name']),
          ],
        ),
      ),
    );
  }

  // 카드 선택시 기본 정보 출력창
  void _showDetailDialog(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(person['name']),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // 정보 수정 로직
                      _showEditOptions(context, person);
                      print('정보 수정');
                    },
                  ),
                ],
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: person['imageUrls'].map<Widget>((url) {
                    return GestureDetector(
                      onTap: () {
                        //Navigator.of(context).pop();
                        _showImageDialog(context, url);
                      },
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 100);
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8),
                Text(
                    '기본 정보: ${person['info'].isEmpty ? '등록된 정보가 없습니다.' : person['info']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deletePerson(context, person);
              },
              child: Text('정보 삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _deletePerson(BuildContext context, Map<String, dynamic> person) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('정보 삭제'),
        content: Text('정말로 이 정보를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm) {
      // Firestore 문서 삭제
      await FirebaseFirestore.instance
          .collection('data')
          .doc('doorlock')
          .collection('FaceCategory')
          .doc(person['category'])
          .collection('people')
          .doc(person['documentId'])
          .delete();

      // Firebase Storage 이미지 삭제
      for (String url in person['imageUrls']) {
        Reference ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      }

      Navigator.of(context).pop(); // 다이얼로그 닫기
    }
  }





  //이미지 선택시 조금 크게 확대
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // 현재 이미지 다이얼로그 닫기
                  },
                ),
              ),
              Image.network(imageUrl),
            ],
          ),
        );
      },
    );
  }

  //수정 버튼시 이미지 또는 기본정보 수정 버튼 생성
  void _showEditOptions(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수정 옵션'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editImage(context, person);
                },
                child: Text('이미지 수정'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editInfo(context, person);
                },
                child: Text('기본 정보 수정'),
              ),
            ],
          ),
        );
      },
    );
  }
  // 이미지 수정 로직 구현
  void _editInfo(BuildContext context, Map<String, dynamic> person) {
    final TextEditingController nameController =
        TextEditingController(text: person['name']);
    final TextEditingController infoController =
        TextEditingController(text: person['info'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('기본 정보 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: infoController,
                decoration: InputDecoration(labelText: '기본 정보'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                String newInfo = infoController.text.trim();

                if (newName.isEmpty) {
                  // 이름이 비어있으면 경고 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이름은 필수 입력 사항입니다.')));
                  return;
                }

                if (newName != person['name'] ||
                    newInfo != (person['info'] ?? '')) {
                  // 변경 사항이 있을 경우 Firestore 업데이트
                  await FirebaseFirestore.instance
                      .collection('data')
                      .doc('doorlock')
                      .collection('FaceCategory')
                      .doc(person['category'])
                      .collection('people')
                      .doc(person['documentId'])
                      .update({
                    'name': newName,
                    'info': newInfo,
                  });
                  print('정보 수정 변경이 일어났습니다');

                  // 다이얼로그 닫기
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  // 변경 사항이 없으면 그냥 닫기
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 기본 정보 수정 로직 구현
  void _editImage(BuildContext context, Map<String, dynamic> person) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도어락',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          PopupMenuButton<int>(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              // 선택된 메뉴에 따라 동작
              if (value == 0) {
                print('얼굴등록');
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ScreenAddFace()));
              } else if (value == 1) {
                print('방문기록');
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DoorLockVisitLog(familyList: familyList,acquaintanceList: acquaintanceList,)));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text('얼굴등록'),
              ),
              PopupMenuItem(
                value: 1,
                child: Text('방문기록'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.blue[100],
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   alignment: Alignment.center,
                  //   height: 400,
                  //   width: MediaQuery.of(context).size.width,
                  //   color: Colors.orange,
                  //   child: Container(
                  //     height: MediaQuery.of(context).size.width / 2,
                  //     width: MediaQuery.of(context).size.width / 2,
                  //     color: Colors.green,
                  //   ),
                  // ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.blueAccent,
                    child: Stack(
                      children: [
                        // Container(
                        //   padding: EdgeInsets.only(left: 15, top: 15),
                        //   child: Text(
                        //     '금일 가족 출입',
                        //     style:
                        //     TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        //   ),
                        // ),

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
                                  SizedBox(height: 10),
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
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    //padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            color: Colors.white,
                            child: Text(
                              '최근 출입기록',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            )),
                        // Container(
                        //   height: 150,
                        //   child: ListView.builder(
                        //     itemCount: statistics.length,
                        //     itemBuilder: (context, index) {
                        //       return ListTile(
                        //         title: Text(
                        //             '${statistics[index]['category']}  : ${statistics[index]['title']}'),
                        //         subtitle:
                        //             Text('출입일: ${statistics[index]['value']}'),
                        //       );
                        //     },
                        //   ),
                        // ),
                        StreamBuilder<QuerySnapshot>(stream: _firestore
                            .collection('data')
                            .doc('doorlock')
                            .collection('entry_logs')
                            .where(FieldPath.documentId,
                            isGreaterThanOrEqualTo: twoDaysAgoString)
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
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                  ),
                  Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<MqttBloc>().add(
                                PublishMessage(topic: MyTopic.doorLockUnLockTopic, message: '{"unlock" : "true"}'));
                          },
                          child: Text(
                            'OPEN',
                            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(250, 60),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10))
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'CCTV 확인',
                            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(250, 60),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10))
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (_) => DoorLockVisitLog()));
                        //   },
                        //   child: Text(
                        //     '방문기록',
                        //     style: TextStyle(fontSize: 20),
                        //   ),
                        //   style: ElevatedButton.styleFrom(
                        //     minimumSize: Size(200, 60),
                        //   ),
                        // ),
                        // Expanded(
                        //   child: Container(
                        //       color: Colors.white24,
                        //       height: 400,
                        //       child: ListView.builder(
                        //           itemCount: statistics.length,
                        //           itemBuilder: (context, index) {
                        //             return ListTile(
                        //               title: Text(statistics[index]['title']),
                        //               subtitle: Text(
                        //                   'Value: ${statistics[index]['value']}'),
                        //             );
                        //           })),
                        // ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.brown,
                        child: Column(
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 10, bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '가족',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            // FutureBuilder<List<Map<String, dynamic>>>(
                            //   future: _fetchPeople('가족'),
                            //   builder: (context, snapshot) {
                            //     if (snapshot.connectionState ==
                            //         ConnectionState.waiting) {
                            //       return Center(
                            //           child: CircularProgressIndicator());
                            //     } else if (snapshot.hasError) {
                            //       return Center(child: Text('오류 발생'));
                            //     } else if (!snapshot.hasData ||
                            //         snapshot.data!.isEmpty) {
                            //       return Container(
                            //           height: 150,
                            //           child:
                            //           Center(child: Text('등록된 인원이 없습니다')));
                            //     } else {
                            //       return SizedBox(
                            //         height: 150,
                            //         child: ListView.builder(
                            //           scrollDirection: Axis.horizontal,
                            //           itemCount: snapshot.data!.length,
                            //           itemBuilder: (context, index) {
                            //             return _buildCard(
                            //                 snapshot.data![index]);
                            //           },
                            //         ),
                            //       );
                            //     }
                            //   },
                            // ),
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('data')
                                  .doc('doorlock')
                                  .collection('FaceCategory')
                                  .doc('가족')
                                  .collection('people')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('오류 발생'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Container(
                                      height: 150,
                                      color: Colors.white,
                                      child:
                                          Center(child: Text('등록된 인원이 없습니다')));
                                } else {
                                  familyList = snapshot.data!.docs.map((doc) {
                                              Map<String, dynamic> person = doc.data() as Map<String, dynamic>;
                                              person['documentId'] = doc.id;
                                              person['category'] = '가족';
                                              return person;
                                            }).toList();
                                  return Container(
                                    height: 150,

                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> person =
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>;
                                        person['documentId'] =
                                            snapshot.data!.docs[index].id;
                                        person['category'] = '가족';
                                        return _buildCard(person);
                                      },
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.brown[200],
                        child: Column(
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 10, bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '지인',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _fetchPeople('지인'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('오류 발생'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Container(
                                      height: 150,
                                      color: Colors.white,
                                      child:
                                      Center(child: Text('등록된 인원이 없습니다.')));
                                } else {
                                  return SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return _buildCard(
                                            snapshot.data![index]);
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
