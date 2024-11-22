import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/config/palette.dart';
import 'package:iot_project_berry/src/screens/screen_lantern_Schedule.dart';
import 'package:iot_project_berry/src/screens/screen_lantern_log.dart';
import 'package:iot_project_berry/src/screens/screen_lantern_option.dart';

class screenLantern extends StatefulWidget {
  const screenLantern({super.key});

  @override
  State<screenLantern> createState() => _screenLanternState();
}

class _screenLanternState extends State<screenLantern> {
  final String lanternTopic = 'lantern/control';
  bool lanternAuto = true;
  String lanternState = "";
  final now = DateTime.now().hour;

  StreamSubscription<DocumentSnapshot>? _listenerSubscription;

  @override
  void initState() {
    listenToDocument();
    super.initState();
  }

  void listenToDocument() {
    print("반복케이스 1");
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('config')
        .doc('lanternstate'); // 특정 문서 ID

    _listenerSubscription =
        docRef.snapshots().listen((DocumentSnapshot snapshot) {
      print("반복케이스 2");
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        print("Document data: $data");
        print("반복케이스 3");
        setState(() {
          // 필드 값 업데이트
          lanternState = data['state'];
          lanternAuto = data['auto'];
        });
      } else {
        print("Document does not exist.");
      }
    }, onError: (error) {
      print("Error listening to document: $error");
    });
  }

  @override
  void dispose() {
    _listenerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '조명',style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('config')
                  .doc('lanternstate')
                  .update({
                'auto': !lanternAuto
              });
            },
            child: lanternAuto ? Text('Auto ON') : Text('Auto OFF'),
            style: ElevatedButton.styleFrom(
                minimumSize: Size(110, 35),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: lanternAuto ? Colors.grey : Colors.white,
                foregroundColor: lanternAuto ? Colors.white : Colors.black,
                elevation: lanternAuto ? 5 : 0),
          ),
        ],
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.blue[100],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 300,
                  child: Stack(children: [
                    if (now >= 6 && now < 12)
                      Container(
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: [
                            Colors.orangeAccent,
                            Colors.yellowAccent,
                            Colors.lightBlue,
                            Colors.lightBlueAccent
                          ],
                          stops: [0.2, 0.4, 0.6, 1.0],
                        )),
                      ),
                    if (now >= 12 && 19 > now)
                      Container(
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: 1.0,
                          colors: [
                            Colors.orangeAccent,
                            Colors.orange,
                            Colors.yellow,
                            Colors.lightBlueAccent
                          ],
                          stops: [0.2, 0.4, 0.6, 1.0],
                        )),
                      ),
                    if (now >= 19 || 6 > now) ...[
                      Container(
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.0,
                          colors: [
                            Colors.white70,
                            Colors.indigo,
                            Colors.indigo[900]!
                          ],
                          stops: [0.2, 0.6, 1.0],
                        )),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.topCenter,
                        height: 250,
                        child: Image.asset(
                          'assets/stars.png',
                          repeat: ImageRepeat.repeatX,
                          width: double.infinity,
                        ),
                      ),
                    ],
                    Center(
                        child: Container(
                      padding: EdgeInsets.all(20),
                      //     height: 200,
                      // width: 200,
                      child: (lanternState == "on")
                          ? Image.asset(
                              'assets/lanternOn.png',
                              // width: 200,
                              // height: 200,
                              fit: BoxFit.contain,
                            )
                          : ((lanternState == "off")
                              ? Image.asset(
                                  'assets/lanternOff.png',
                                  // width: 200,
                                  // height: 200,
                                  fit: BoxFit.contain,
                                )
                              : CircularProgressIndicator()),
                    )),
                  ]),
                ),
                Expanded(
                  child: Container(
                    //margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.read<MqttBloc>().add(PublishMessage(
                                    topic: lanternTopic, message: 'ON'));
                              },
                              child: Text('ON', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor)),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(150, 100),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  context.read<MqttBloc>().add(PublishMessage(
                                      topic: lanternTopic, message: 'OFF'));
                                },
                                child:
                                    Text('OFF', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor)),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(150, 100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ScreenLanternSchedule()));
                              },
                              child: Text('예약', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor)),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(150, 100),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ScreenLanternOption()));
                                },
                                child: Text('상세옵션',
                                    style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor)),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(150, 100),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ScreenLanternLog()));
                            },
                            child:
                                Text('조명 작동기록', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Palette.buttonColor)),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                minimumSize: Size.fromHeight(100),
                                maximumSize: Size.infinite))
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
