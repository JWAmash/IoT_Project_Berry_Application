import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iot_project_berry/src/blocs/mqtt_bloc.dart';
import 'package:iot_project_berry/src/blocs/timer_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenTemporaryPassword extends StatefulWidget {
  const ScreenTemporaryPassword({super.key});

  @override
  State<ScreenTemporaryPassword> createState() =>
      _ScreenTemporaryPasswordState();
}

class _ScreenTemporaryPasswordState extends State<ScreenTemporaryPassword> {
  //String? ti

  String? _temporaryPassword;
  int _timeLeft = 0;
  int _tempTimeLeft = 0;
  DateTime? _endTime;
  DateTime? _endTime2;
  int defaulttime = 600;
  Timer? _timer;
  Timer? _tempTimer;

  void startTimer(int seconds) {
    _timeLeft = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          print('$_timeLeft: 남았다1');
        });
      } else {
        timer.cancel();
        // setState(() {
        //   //temporaryPassword = null;
        // });
      }
    });
  }

  void startTimer2(int seconds) {
    _tempTimeLeft = seconds;
    _tempTimer?.cancel();
    _tempTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_tempTimeLeft > 0) {
        setState(() {
          _tempTimeLeft--;
          print('$_tempTimeLeft 남았다는데2');
        });
      } else {
        timer.cancel();
        setState(() {
          _temporaryPassword = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('임시 비밀번호 발급'),
        ),
        body: Stack(children: [
          Container(
            color: Colors.blue,
          ),
          Center(
            child:
                BlocBuilder<TimerBloc, TimerState>(builder: (context, state) {
              print('설마 이거도?');
              if (state.remainingSeconds > 0) {
                _endTime = state.endTime;
                final now = DateTime.now();
                startTimer(_endTime!.difference(now).inSeconds);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TimerBloc>().add(StartTimer()),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          (_timeLeft > 0)
                              ? Icon(
                                  Icons.lock_open,
                                  size: 70,
                                )
                              : Icon(
                                  Icons.lock,
                                  size: 70,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '1차 인증 해제',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), padding: EdgeInsets.all(24)),
                  ),

                  // if (temporaryPassword != null)
                  //   Column(
                  //     children: [
                  //       Text('임시 비밀번호: $temporaryPassword'),
                  //       Text('남은 시간: $timeLimit 초'),
                  //     ],
                  //   ),
                  SizedBox(height: 20),
                  Text(
                    (_timeLeft > 0)
                        ? '인증 해제: ${_timeLeft}'
                        // '인증 해제: ${_timeLeft ~/ 60}분 ${_timeLeft % 60}초'
                        : '1차 인증 필요',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 40),

                  ElevatedButton(
                      onPressed: () =>
                          _showDisposablePasswordDialog(context, '1회용 비밀번호'),
                      child: Text('1회용 출입번호 발급')),

                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () =>
                          _showTemporaryPasswordDialog(context, DateTime.now()),
                      child: Text('임시 비밀번호 발급')),
                  // ElevatedButton(
                  //   onPressed: generateTemporaryPassword,
                  //   child: Text('임시 비밀번호 발급'),
                  // ),
                ],
              );
            }),
          ),
        ]));
  }

// void _showTemporaryPasswordDialog(BuildContext context, String title) {
//   DateTime selectedDay= DateTime.now();
//   DateTime focusedDay = DateTime.now();
//
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(title),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               color: Colors.blue,
//               padding: EdgeInsets.all(15),
//               child: Column(
//                 children: [
//                   TableCalendar(
//                     firstDay: DateTime(2020),
//                     lastDay: DateTime(2030),
//                     focusedDay: focusedDay,
//                     selectedDayPredicate: (day) => isSameDay(selectedDay, day),
//                     onDaySelected: (selectedDay, focusedDay) {
//                       setState(() {
//                         this.selectedDay = selectedDay;
//                         this.focusedDay = focusedDay;
//                       });
//                       // 선택된 날짜를 사용할 수 있습니다.
//                       print("선택된 날짜: $selectedDay");
//                     },
//                   ),
//                   Container(
//                       alignment: Alignment.center,
//                       color: Colors.purple,
//                       child: Text('5일')),
//                   SizedBox(height: 5),
//                   Row(
//                     children: [
//                       Container(
//                           color: Colors.yellow,
//                           alignment: Alignment.center,
//                           child: Text('!SADFASDf')),
//                       Container(
//                           color: Colors.brown,
//                           alignment: Alignment.center,
//                           child: Text('asdfasdf'))
//                     ],
//                   ),
//                   ElevatedButton(onPressed: () {}, child: Text('버튼입니다'),style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
//                   ),)
//                 ],
//               ),
//             ),
//             Column(
//               children: [
//                 Container(
//                   color: Colors.brown,
//                   padding: EdgeInsets.all(15),
//                   child: Column(
//                     children: [
//                       Container(
//                           width: double.infinity,
//                           alignment: Alignment.center,
//                           color: Colors.amber,
//                           child: Text('123456',
//                               style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold))),
//                       Container(
//                           color: Colors.green,
//                           alignment: Alignment.center,
//                           width: double.infinity,
//                           child: Text(
//                             '유효기간: 2024-11-07',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ))
//                     ],
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('취소'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('저장'),
//             onPressed: () {
//               // 설정 저장 로직
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
}

void _showDisposablePasswordDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BlocProvider<TimerBloc2>(
        create: (context) {
          final bloc = TimerBloc2('temporarypassword');
          bloc.add(SetActiveStatus(true));
          bloc.loadSavedTimer();
          return bloc;
        },
        child: DisposablePasswordDialog(title: title),
      );
    },
  );
}

class DisposablePasswordDialog extends StatefulWidget {
  final String title;

  DisposablePasswordDialog({Key? key, required this.title}) : super(key: key);

  @override
  _DisposablePasswordDialogState createState() =>
      _DisposablePasswordDialogState();
}

class _DisposablePasswordDialogState extends State<DisposablePasswordDialog> {
  Timer? _timer;
  int _timeLeft = 0;
  String? _temporaryPassword;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer(int seconds) {
    _timeLeft = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          print('남은시간: ${_timeLeft}');
        });
      } else {
        timer.cancel();
        setState(() {
          _temporaryPassword = null;
          print('남은시간 없음 타이머 종료');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TimerBloc2>().add(SetActiveStatus(false));
            },
          ),
        ],
      ),
      content: BlocConsumer<TimerBloc2, TimerState2>(
        listener: (context, state) {
          if (state.remainingSeconds > 0 && state.password != null) {
            _temporaryPassword = state.password;
            startTimer(state.remainingSeconds);
          }
        },
        builder: (context, state) {
          print('test1');
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_timeLeft > 0 && _temporaryPassword != null) ...[
                Text('$_temporaryPassword'),
                Text('남은시간 : $_timeLeft')
              ] else
                Text('발급된 임시 비밀번호가 없습니다'),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () => context.read<TimerBloc2>().add(StartTimer()),
                child: Text('발급'),
              )
            ],
          );
        },
      ),
      // actions: <Widget>[
      //   TextButton(
      //     child: Text('취소'),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   TextButton(
      //     child: Text('저장'),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //       context.read<TimerBloc2>().add(SetActiveStatus(false));
      //     },
      //   ),
      // ],
    );
  }
}

void _showTemporaryPasswordDialog(BuildContext context, DateTime initTime) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return TemporaryPasswordDialog(
        initialDate: initTime,
      );
    },
  );
}

class TemporaryPasswordDialog extends StatefulWidget {
  final DateTime initialDate;

  const TemporaryPasswordDialog({super.key, required this.initialDate});

  @override
  State<TemporaryPasswordDialog> createState() =>
      _TemporaryPasswordDialogState();
}

class _TemporaryPasswordDialogState extends State<TemporaryPasswordDialog> {
  late DateTime selectedDay;
  late DateTime focusedDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.initialDate;
    focusedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('임시 비밀번호 발급'),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // color: Colors.blue,
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    height: 350,
                    width: 400,
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      locale: 'ko_KR',
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          this.selectedDay = selectedDay;
                          this.focusedDay = focusedDay;
                        });
                        // 선택된 날짜를 사용할 수 있습니다.
                        print("선택된 날짜: $selectedDay");
                      },
                    ),
                  ),
                  // Container(
                  //     alignment: Alignment.center,
                  //     color: Colors.purple,
                  //     child: Text('5일')),
                  // SizedBox(height: 5),
                  // Row(
                  //   children: [
                  //     Container(
                  //         color: Colors.yellow,
                  //         alignment: Alignment.center,
                  //         child: Text('!SADFASDf')),
                  //     Container(
                  //         color: Colors.brown,
                  //         alignment: Alignment.center,
                  //         child: Text('asdfasdf'))
                  //   ],
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '선택날짜: ${DateFormat('yyyy-MM-dd').format(selectedDay)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('등록'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0))),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      // color: Colors.brown,
                      border: Border.all(color: Colors.black, width: 2.0)),
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          color: Colors.blueAccent,
                          child: Text('PASSWORD: 123456',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                      Container(
                          //color: Colors.green,
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text(
                            '유효기간: 2024-11-07',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     child: Text('취소'),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      //   TextButton(
      //     child: Text('저장'),
      //     onPressed: () {
      //       // 설정 저장 로직
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    );
  }
}
