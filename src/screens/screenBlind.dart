import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/screens/screen_blind_option.dart';
import 'package:iot_project_berry/src/screens/screen_blind_schedule.dart';

class ScreenBlind extends StatefulWidget {
  const ScreenBlind({super.key});

  @override
  State<ScreenBlind> createState() => _ScreenBlindState();
}

class _ScreenBlindState extends State<ScreenBlind> {
  final String blindTopic= 'blinds/control';
  bool blindAuto = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final now = DateTime.now().hour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '블라인드',
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                blindAuto = !blindAuto;
              });
            },
            child: blindAuto ? Text('Auto ON') : Text('Auto OFF'),
            style: ElevatedButton.styleFrom(
                minimumSize: Size(110, 35),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: blindAuto ? Colors.grey : Colors.white,
                foregroundColor: blindAuto ? Colors.white : Colors.black,
                elevation: blindAuto ? 5 : 0),
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
                  color: Colors.brown,
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
                      child: Image.asset(
                        'assets/blind_up.png',
                        // width: 200,
                        // height: 200,
                        fit: BoxFit.contain,
                      ),
                    )),
                  ]),
                ),
                Expanded(
                  child: Container(
                    //margin: EdgeInsets.only(top: 30),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTapDown:(_){
                                context.read<MqttBloc>().add(
                                    PublishMessage(topic: blindTopic, message: 'UP_PRESS'));
                              },
                              onTapCancel: (){
                                context.read<MqttBloc>().add(
                                    PublishMessage(topic: blindTopic, message: 'UP_RELEASE'));
                              },
                              child: ElevatedButton(
                                onPressed: () {
                                },
                                child: Text('올림',style: TextStyle(
                                  fontSize: 20
                                ),),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(150, 60),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTapDown: (_){
                                context.read<MqttBloc>().add(
                                    PublishMessage(topic: blindTopic, message: 'DOWN_PRESS'));
                              },
                              onTapCancel: (){
                                context.read<MqttBloc>().add(
                                    PublishMessage(topic: blindTopic, message: 'DOWN_RELEASE'));
                              },

                              child: ElevatedButton(
                                  onPressed: () {
                                  },
                                  child: Text('내림',style: TextStyle(
                                      fontSize: 20
                                  )),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(150, 60),
                                  )),
                            )
                          ],
                        ),
                        //SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {context.read<MqttBloc>().add(
                                  PublishMessage(topic: blindTopic, message: 'FULL_UP'));},
                              child: Text('최대 올림',style: TextStyle(
                                  fontSize: 20
                              )),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(150, 60),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {context.read<MqttBloc>().add(
                                    PublishMessage(topic: blindTopic, message: 'FULL_DOWN'));},
                                child: Text('최대 내림',style: TextStyle(
                                    fontSize: 20
                                )),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(150, 60),
                                ))
                          ],
                        ),
                        //SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ScreenBlindSchedule()));
                              },
                              child: Text('예약',style: TextStyle(
                                  fontSize: 20
                              )),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(150, 60),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ScreenBlindOption()));
                                },
                                child: Text('상세옵션',style: TextStyle(
                                    fontSize: 20
                                )),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(150, 60),
                                ))
                          ],
                        ),
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
