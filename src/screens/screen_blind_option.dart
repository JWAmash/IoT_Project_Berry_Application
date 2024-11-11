import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class ScreenBlindOption extends StatefulWidget {
  const ScreenBlindOption({super.key});

  @override
  State<ScreenBlindOption> createState() => _ScreenBlindOptionState();
}

class _ScreenBlindOptionState extends State<ScreenBlindOption> {
  int sensorLowerLimit = 0;
  int sensorUpperLimit = 0;
  List<String> dropDownListCategory = ["내림", "올림"];
  String selectedOperation1 = '내림';
  String selectedOperation2 = '내림';

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    try {
      // Firestore의 sensors 컬렉션에서 sensor1 문서를 읽어옴
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('config')
          .doc('blind')
          .get();

      // 문서가 존재하면 데이터를 변수에 저장
      if (document.exists) {
        setState(() {
          sensorLowerLimit = document['sensorLowerLimit'];
          sensorUpperLimit = document['sensorUpperLimit'];
          selectedOperation1 = document['lowerOperiation'];
          selectedOperation2 = document['upperOperiation'];
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Stack(children: [
        Container(
          color: Colors.blue[100],
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '최대 높낮이 설정',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 200,
                    //color: Colors.orange,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 2.0)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(20),
                          height: double.infinity,
                          // color: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: Text(
                                  '최소 거리',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100, // 원하는 폭으로 설정 (예: 100)
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      // 숫자 키패드 표시
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter
                                            .digitsOnly, // 숫자만 입력 허용
                                      ],
                                      decoration: InputDecoration(
                                        labelText: '숫자',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 10.0), // 패딩 조정
                                      ),
                                      onTapOutside: (event) {
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text('cm'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 2.0)),
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: Text(
                                  '최대 거리',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100, // 원하는 폭으로 설정 (예: 100)
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      // 숫자 키패드 표시
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter
                                            .digitsOnly, // 숫자만 입력 허용
                                      ],
                                      decoration: InputDecoration(
                                        labelText: '숫자',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 10.0), // 패딩 조정
                                      ),
                                      onTapOutside: (event) {
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text('cm'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '조도센서 수치 설정',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 230,
                    //color: Colors.orange,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 2.0)),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          height: double.infinity,
                          // color: Colors.green,
                          child: Center(
                            child: Stack(
                              children: [
                                SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                    customWidths: CustomSliderWidths(
                                        trackWidth: 12,
                                        progressBarWidth: 12,
                                        shadowWidth: 0,
                                        handlerSize: 20
                                        //touchAreaWidth: 25,
                                        ),
                                    customColors: CustomSliderColors(
                                      trackColor: Colors.grey[800],
                                      progressBarColors: [
                                        Colors.green[100]!,
                                        Colors.green[900]!
                                      ],
                                      // gradientEndAngle: 500,
                                      // gradientStartAngle: 220,
                                      shadowColor: Colors.blue.withOpacity(0.2),
                                      shadowMaxOpacity: 0.5,
                                      dotColor: Colors.lightBlueAccent,
                                    ),
                                    startAngle: 170,
                                    angleRange: 200,
                                    // 이 값을 조정하여 슬라이더의 범위를 제한합니다
                                    size: 400.0,
                                    animationEnabled: true,
                                  ),
                                  min: 0,
                                  max: 100,
                                  initialValue: sensorLowerLimit.toDouble(),
                                  onChange: (double value) {
                                    setState(() {
                                      sensorLowerLimit = value.round();
                                    });

                                    print(value);
                                  },
                                  innerWidget: (double value) {
                                    return Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${value.round()}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text('까지')
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                            //margin: EdgeInsets.all(10),
                                            child: DropdownButton2(
                                              buttonStyleData:
                                                  const ButtonStyleData(),
                                              items: dropDownListCategory
                                                  .map((item) =>
                                                      DropdownMenuItem(
                                                          value: item,
                                                          child: Text(
                                                            item,
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          )))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedOperation1 = value!;
                                                });
                                              },
                                              value: selectedOperation1,
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0)),
                                              onPressed: () {
                                                if (sensorLowerLimit <=
                                                    sensorUpperLimit) {
                                                  FirebaseFirestore.instance
                                                      .collection('config')
                                                      .doc('blind')
                                                      .update({
                                                    'sensorLowerLimit':
                                                        sensorLowerLimit,
                                                    'lowerOperiation':
                                                        selectedOperation1
                                                    // 초 단위로 저장
                                                  });
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('경고'),
                                                        content: Text(
                                                            '하한값이 상한값보다 클 수 없습니다.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // 팝업 닫기
                                                            },
                                                            child: Text('확인'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Text(
                                                '저장',
                                                style: TextStyle(fontSize: 14),
                                              )),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        )),
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.black, width: 2.0)),
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Center(
                                child: SleekCircularSlider(
                                  appearance: CircularSliderAppearance(
                                    customWidths: CustomSliderWidths(
                                        trackWidth: 12,
                                        progressBarWidth: 12,
                                        shadowWidth: 0,
                                        handlerSize: 20
                                        //touchAreaWidth: 25,
                                        ),
                                    customColors: CustomSliderColors(
                                      trackColors: [
                                        Colors.green[100]!,
                                        Colors.green[900]!
                                      ],
                                      progressBarColor: Colors.grey[800],
                                      shadowColor: Colors.blue.withOpacity(0.2),
                                      shadowMaxOpacity: 0.5,
                                      dotColor: Colors.lightBlueAccent,
                                    ),
                                    startAngle: 170,
                                    angleRange: 200,
                                    // 이 값을 조정하여 슬라이더의 범위를 제한합니다
                                    size: 400.0,
                                    animationEnabled: true,
                                  ),
                                  min: 0,
                                  max: 100,
                                  initialValue: sensorUpperLimit.toDouble(),
                                  onChange: (double value) {
                                    setState(() {
                                      sensorUpperLimit = value.round();
                                    });

                                    print(value.toInt());
                                  },
                                  innerWidget: (double value) {
                                    return Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${value.round()}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text('부터')
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        //margin: EdgeInsets.all(10),
                                        child: DropdownButton2(
                                          buttonStyleData:
                                              const ButtonStyleData(),
                                          items: dropDownListCategory
                                              .map((item) => DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOperation2 = value!;
                                            });
                                          },
                                          value: selectedOperation2,
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0)),
                                            onPressed: () {
                                              if (sensorLowerLimit <=
                                                  sensorUpperLimit) {
                                                FirebaseFirestore.instance
                                                    .collection('config')
                                                    .doc('blind')
                                                    .update({
                                                  'sensorUpperLimit':
                                                      sensorUpperLimit,
                                                  'upperOperiation':
                                                      selectedOperation2
                                                });
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('경고'),
                                                      content: Text(
                                                          '상한값이 하한값보다 작을 수 없습니다.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // 팝업 닫기
                                                          },
                                                          child: Text('확인'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child: Text(
                                              '저장',
                                              style: TextStyle(fontSize: 14),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2.0)),
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black, width: 2.0)),
                            ),
                            child: const Text(
                              '설명',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('최대 높낮이 설정',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                Text(
                                  '블라인드는 최소거리와 최대거리를 기반으로 동작됩니다.\n최대와 최소거리 이상의 동작은 일어나지 않습니다 \n*최소 거리: 최대로 내렸을 때 바닥으로부터의 거리\n*최대 거리: 최대로 올렸을 때 바닥으로부터의 거리\n',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text('조도센서 수치 설정',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                Text('조도 센서는 주변의 밝기를 측정하는 센서로\n밝을수록 수치가 낮아지고 어두울수록 수치가 높아집니다. \n좌측 설정은 해당 수치 미만일 때 동작하도록 제어할 수 있고\n우측 설정은 해당 수치 이상일 때 동작하도록 제어할 수 있습니다.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        ],
                      ))
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }
}
