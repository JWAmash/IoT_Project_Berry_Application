import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ScreenBlindSchedule extends StatefulWidget {
  const ScreenBlindSchedule({super.key});

  @override
  State<ScreenBlindSchedule> createState() => _ScreenBlindScheduleState();
}

class _ScreenBlindScheduleState extends State<ScreenBlindSchedule> {
  final List<String> operation = ['상승', '하강'];
  String? selectedOperation = '상승';
  int _selectedHour = 12; // 초기값: 12시
  int _selectedMinute = 0; // 초기값: 0분
  String _selectedPeriod = 'AM'; // 초기값: AM
  bool deleteMode = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore에 시간 저장하는 함수
  Future<void> _saveTimeToFirestore() async {
    try {
      DateTime selectedDateTime = _convertToDateTime();
      await _firestore
          .collection('data')
          .doc('blind')
          .collection('schedules')
          .add({
        'time': Timestamp.fromDate(selectedDateTime),
        'active': true,
        'operation': selectedOperation,
        'timestamp': FieldValue.serverTimestamp(), // 서버 타임스탬프 추가 (정렬용)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시간이 성공적으로 저장되었습니다!')),
      );
    } catch (e) {
      print('Error saving time to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('시간 저장 중 오류가 발생했습니다.')),
      );
    }
    //Navigator.pop(context); // 팝업 닫기
  }

  // Firestore에서 스케줄의 활성화 여부 (active) 업데이트
  Future<void> _updateActiveStatus(String docId, bool isActive) async {
    try {
      await _firestore
          .collection('data')
          .doc('blind')
          .collection('schedules')
          .doc(docId)
          .update({
        'active': isActive, // active 필드를 업데이트
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄 활성화 상태가 업데이트되었습니다!')),
      );
    } catch (e) {
      print('Error updating active status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상태 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  // Firestore에서 스케줄 삭제
  Future<void> _deleteSchedule(String docId) async {
    try {
      await _firestore
          .collection('data')
          .doc('blind')
          .collection('schedules')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄이 삭제되었습니다!')),
      );
    } catch (e) {
      print('Error deleting schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  // void _onHourChanged(int index) {
  //   int hour = (index % 12) + 1; // 시간은 항상 1~12로 순환
  //   setState(() {
  //     _selectedHour = hour;
  //
  //     // 시간이 12에서 다시 1로 넘어가면 AM/PM 자동 전환
  //     if (_selectedHour == 12 && _selectedPeriod == 'AM') {
  //       _selectedPeriod = 'PM';
  //     } else if (_selectedHour == 12 && _selectedPeriod == 'PM') {
  //       _selectedPeriod = 'AM';
  //     }
  //   });
  // }

  //// 분 변경 시 호출되는 함수 (0~59 순환)
  // void _onMinuteChanged(int index) {
  //   int minute = index % 60; // 분은 항상 0~59로 순환
  //   setState(() {
  //     _selectedMinute = minute;
  //   });
  // }
  //
  // // AM/PM 변경 시 호출되는 함수
  // void _onPeriodChanged(String period) {
  //   setState(() {
  //     _selectedPeriod = period;
  //   });
  // }

  // 선택된 시간을 DateTime으로 변환하는 함수
  DateTime _convertToDateTime() {
    int hour = _selectedHour;
    if (_selectedPeriod == 'PM' && hour != 12) {
      hour += 12; // PM이면 시간을 12시간 더함 (단, 오후 12시는 그대로 유지)
    } else if (_selectedPeriod == 'AM' && hour == 12) {
      hour = 0; // 오전 12시는 자정(00시)으로 처리
    }
    return DateTime(1970, 1, 1, hour, _selectedMinute); // 임시 날짜와 함께 시간 설정
  }

  // 시간 선택 팝업을 보여주는 함수
  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // 시간 변경 시 호출되는 함수
            void _onHourChanged(int index) {
              int hour = (index % 12) + 1; // 시간은 항상 1~12로 순환
              setModalState(() {
                _selectedHour = hour;

                // 시간이 12에서 다시 1로 넘어가면 AM/PM 자동 전환
                if (_selectedHour == 12 && _selectedPeriod == 'AM') {
                  _selectedPeriod = 'PM';
                } else if (_selectedHour == 12 && _selectedPeriod == 'PM') {
                  _selectedPeriod = 'AM';
                }
              });
            }

            //// 분 변경 시 호출되는 함수 (0~59 순환)
            void _onMinuteChanged(int index) {
              int minute = index % 60; // 분은 항상 0~59로 순환
              setModalState(() {
                _selectedMinute = minute;
              });
            }

            // AM/PM 변경 시 호출되는 함수
            void _onPeriodChanged(String period) {
              setModalState(() {
                _selectedPeriod = period;
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 팝업 상단에 현재 선택된 시간 표시
                  Text(
                    '선택된 시간 : ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $_selectedPeriod',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  // 시간과 분 선택기 (ListWheelScrollView 사용)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 시간 선택기 (1~12 순환)
                      SizedBox(
                        height: 150, // 고정된 높이를 지정
                        width: 100, // 고정된 너비를 지정 (선택 사항)
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          onSelectedItemChanged: (index) {
                            setModalState(() => _onHourChanged(index));
                          },
                          physics: FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              int hour = (index % 12) + 1; // 시간은 항상 1~12로 순환
                              return Center(
                                  child: Text('$hour',
                                      style: TextStyle(fontSize: 24)));
                            },
                            childCount: null, // 무한 스크롤을 위해 null 설정
                          ),
                        ),
                      ),
                      Text(
                        '시',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 20),
                      // 분 선택기 (0~59 순환)
                      SizedBox(
                        height: 150, // 고정된 높이를 지정
                        width: 100, // 고정된 너비를 지정 (선택 사항)
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          onSelectedItemChanged: (index) {
                            setModalState(() => _onMinuteChanged(index));
                          },
                          physics: FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              int minute = index % 60; // 분은 항상 0~59로 순환
                              return Center(
                                  child: Text('$minute',
                                      style: TextStyle(fontSize: 24)));
                            },
                            childCount: null, // 무한 스크롤을 위해 null 설정
                          ),
                        ),
                      ),
                      Text(
                        '분',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 60,
                      ),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setModalState(() => _onPeriodChanged(newValue));
                          }
                        },
                        items: <String>['AM', 'PM']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // AM/PM 선택 드롭다운 버튼

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton2(
                          items: operation
                              .map((String item) => DropdownMenuItem(
                              value: item, child: Text(item)))
                              .toList(),
                          value: selectedOperation,
                          alignment: AlignmentDirectional.centerStart,
                          onChanged: (value) {
                            setModalState(() {
                              selectedOperation = value;
                            });
                          }),
                      ElevatedButton(
                        onPressed: () {
                          _saveTimeToFirestore();
                          Navigator.pop(context); // 팝업 닫기
                        },
                        child: Text('저장'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('블라인드 시간 설정',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 현재 선택된 시간 표시
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showTimePicker(context), // 팝업 열기
                          child: Text(
                            '시간 추가',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              deleteMode = !deleteMode;
                            });
                          }, // 팝업 열기
                          child: deleteMode
                              ? Text(
                            '시간 삭제 취소',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,color: Colors.black87),
                          )
                              : Text(
                            '시간 삭제',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('data')
                      .doc('blind')
                      .collection('schedules')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('오류 발생');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final schedules = snapshot.data!.docs;
                    return Expanded(
                        child: ListView.builder(
                            itemCount: schedules.length,
                            itemBuilder: (context, index) {
                              final schedule = schedules[index].data()
                              as Map<String, dynamic>;
                              final time =
                              (schedule['time'] as Timestamp).toDate();

                              // AM/PM 형식으로 시간 변환 (24시간 -> AM/PM)
                              final formattedHour =
                              time.hour % 12 == 0 ? 12 : time.hour % 12;
                              final amPm = time.hour >= 12 ? 'PM' : 'AM';
                              final formattedTime =
                                  '$formattedHour:${time.minute.toString().padLeft(2, '0')} $amPm';
                              final listOperation = schedule['operation'];
                              final isActive = schedule['active'];
                              final docId = schedules[index].id;
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                                child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    title: Text(
                                      formattedTime,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '동작: $listOperation',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '활성화: ${isActive ? "ON" : "OFF"}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    trailing: deleteMode
                                        ? IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text("스케줄 삭제"),
                                                    content: Text(
                                                        "정말로 이 스케줄을 삭제하시겠습니까?"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                          },
                                                          child:
                                                          Text("취소")),
                                                      TextButton(
                                                          onPressed: () {
                                                            _deleteSchedule(
                                                                docId);
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            "삭제",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red),
                                                          ))
                                                    ]);
                                              });
                                        })
                                        : Switch(
                                      value: isActive,
                                      onChanged: (bool value) {
                                        // 스위치 상태 변경 시 Firestore에서 active 상태 업데이트
                                        _updateActiveStatus(docId, value);
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                    )),
                              );
                            }));
                  },
                ),
                SizedBox(height: 20),
                // 시간 선택 버튼

                // 저장 버튼
              ],
            ),
          )
        ],
      ),
    );
  }
}
