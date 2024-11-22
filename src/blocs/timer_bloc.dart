import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

abstract class TimerEvent {}
class StartTimer extends TimerEvent {}
class StopTimer extends TimerEvent {}
class CheckTimer extends TimerEvent {}
class SetActiveStatus extends TimerEvent{
  final bool isActive;
  SetActiveStatus(this.isActive);
}

class TimerState {
  final DateTime? endTime;
  final int remainingSeconds;
  final bool isActive; // 현재 탭이 활성 상태인지
  TimerState({this.endTime, this.remainingSeconds = 0,this.isActive =false});

  TimerState copyWith({
    DateTime? endTime,
    int? remainingSeconds,
    bool? isActive,
  }) {
    return TimerState(
      endTime: endTime ?? this.endTime,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActive: isActive ?? this.isActive,
    );
  }
  PrintTimer(){
    print("$endTime, $remainingSeconds, $isActive");
  }
}

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final String timerId;
  DateTime? _endTime;
  Timer? _timer;

  TimerBloc(this.timerId) : super(TimerState()) {
    on<StartTimer>(_onStartTimer);
    on<StopTimer>(_onStopTimer);
    on<CheckTimer>(_onCheckTimer);
    on<SetActiveStatus>(_onSetActiveState);
  }

  void _onStartTimer(StartTimer event, Emitter<TimerState> emit) {
    _endTime = DateTime.now().add(Duration(minutes: 5));
    _saveEndTime(_endTime!);
    //_startPeriodicTimer(emit);
    _emitRemainingTime(emit);
  }

  void _onStopTimer(StopTimer event, Emitter<TimerState> emit) {
    _endTime = null;
    _saveEndTime(null);
    //_stopPeriodicTimer();
    emit(TimerState(isActive: state.isActive));
  }

  void _onCheckTimer(CheckTimer event, Emitter<TimerState> emit) {
    _emitRemainingTime(emit);
    if(state.remainingSeconds>0&&state.isActive){
      //_startPeriodicTimer(emit);
    }
  }
  void _onSetActiveState(SetActiveStatus event, Emitter<TimerState> emit) {
    // emit(state.copyWith(isActive: event.isActive));
    // if (event.isActive) {
    //   _emitRemainingTime(emit);
    // }
    if (event.isActive) {
      emit(state.copyWith(isActive: true));
      _emitRemainingTime(emit);
      if (state.remainingSeconds > 0) {
        //_startPeriodicTimer(emit);
      }
    } else {
      //_stopPeriodicTimer();
      emit(state.copyWith(isActive: false));
    }
  }

  void _emitRemainingTime(Emitter<TimerState> emit) {
    if (_endTime != null && state.isActive) {
      final now = DateTime.now();
      if (now.isBefore(_endTime!)) {
        emit(TimerState(
          endTime: _endTime,
          remainingSeconds: _endTime!.difference(now).inSeconds,
          isActive: true,
        ));
      } else {
        //_stopPeriodicTimer();
        _endTime = null;
        _saveEndTime(null);
        emit(TimerState(endTime: null,remainingSeconds:0,isActive: true));
      }
    } else {
      emit(TimerState(endTime:null,remainingSeconds:0,isActive: state.isActive));
    }
  }

  void _saveEndTime(DateTime? endTime) {
    if (endTime != null) {
      FirebaseFirestore.instance.collection('data')
          .doc('doorlock').collection('timers').doc(timerId).set({
        'endTime': endTime.toUtc().millisecondsSinceEpoch ~/ 1000 // 초 단위로 저장
      });
    } else {
      FirebaseFirestore.instance.collection('timers').doc(timerId).delete();
    }
  }
  // void _startPeriodicTimer(Emitter<TimerState> emit){
  //   _stopPeriodicTimer();
  //   _timer=Timer.periodic(Duration(seconds: 1), (_){
  //     _emitRemainingTime(emit);
  //     print("남은시간 : ${state.remainingSeconds}");
  //     if(state.remainingSeconds<=0||!state.isActive){
  //       print("${state.remainingSeconds}: 시간 끝남");
  //       _stopPeriodicTimer();
  //     }
  //   });
  // }
  // void _stopPeriodicTimer(){
  //   _timer?.cancel();
  //   _timer=null;
  // }

  Future<void> loadSavedTimer() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc('doorlock')
        .collection('timers')
        .doc(timerId)
        .get();
    print("시간 가져옴");
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('endTime')) {
        final endTimeSeconds = data['endTime'] as int;
        _endTime = DateTime.fromMillisecondsSinceEpoch(endTimeSeconds * 1000, isUtc: true).toLocal();
        if (_endTime!.isAfter(DateTime.now())) {
          add(CheckTimer());
        } else {
          _endTime = null;
          _saveEndTime(null);
        }
      }
    }
  }
}


class TimerState2 {
  final DateTime? endTime;
  final int remainingSeconds;
  final String? password;
  final bool isActive; // 현재 탭이 활성 상태인지
  TimerState2({this.endTime, this.remainingSeconds = 0,this.password,this.isActive =false});

  TimerState2 copyWith({
    DateTime? endTime,
    int? remainingSeconds,
    bool? isActive,
  }) {
    return TimerState2(
      endTime: endTime ?? this.endTime,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActive: isActive ?? this.isActive,
    );
  }
  PrintTimer(){
    print("$endTime, $remainingSeconds, $isActive");
  }
}


//팝업타이머
class TimerBloc2 extends Bloc<TimerEvent, TimerState2> {
  final String timerId;
  DateTime? _endTime;
  Timer? _timer;
  String? temporaryPassword;


  TimerBloc2(this.timerId) : super(TimerState2()) {
    on<StartTimer>(_onStartTimer);
    on<StopTimer>(_onStopTimer);
    on<CheckTimer>(_onCheckTimer);
    on<SetActiveStatus>(_onSetActiveState);
  }

  void _onStartTimer(StartTimer event, Emitter<TimerState2> emit) {
    _endTime = DateTime.now().add(Duration(minutes: 5));

    temporaryPassword = Random().nextInt(999999).toString().padLeft(6, '0');

    _saveEndTime(_endTime!,temporaryPassword);
    //_startPeriodicTimer(emit);
    print('시작한번');
    _emitRemainingTime(emit);
  }

  void _onStopTimer(StopTimer event, Emitter<TimerState2> emit) {
    _endTime = null;
    _saveEndTime(null,null);
    //_stopPeriodicTimer();
    emit(TimerState2(isActive: state.isActive));
  }

  void _onCheckTimer(CheckTimer event, Emitter<TimerState2> emit) {
    print('체크한번');
    _emitRemainingTime(emit);
    if(state.remainingSeconds>0&&state.isActive){
      //_startPeriodicTimer(emit);
    }
  }
  void _onSetActiveState(SetActiveStatus event, Emitter<TimerState2> emit) {
    if (event.isActive) {
      emit(state.copyWith(isActive: true));
      _emitRemainingTime(emit);
      if (state.remainingSeconds > 0) {
      }
    } else {
      emit(state.copyWith(isActive: false));
    }
  }

  void _emitRemainingTime(Emitter<TimerState2> emit) {
    print('일단 계산한번');
    if (_endTime != null && state.isActive) {
      final now = DateTime.now();
      if (now.isBefore(_endTime!)) {
        emit(TimerState2(
          endTime: _endTime,
          remainingSeconds: _endTime!.difference(now).inSeconds,
          password: temporaryPassword,
          isActive: true,
        ));
        print('emit한번');
      } else {
        _endTime = null;
        _saveEndTime(null,null);
        emit(TimerState2(endTime: null,remainingSeconds:0,password: null,isActive: true));
      }
    } else {
      emit(TimerState2(endTime:null,remainingSeconds:0,password: null,isActive: state.isActive));
    }
  }

  void _saveEndTime(DateTime? endTime,temporaryPassword) {
    if (endTime != null) {
      FirebaseFirestore.instance.collection('data')
          .doc('doorlock').collection('timers').doc(timerId).set({
        'endTime': endTime.toUtc().millisecondsSinceEpoch ~/ 1000, // 초 단위로 저장
        'password': temporaryPassword
      });

    } else {
      FirebaseFirestore.instance.collection('timers').doc(timerId).delete();
    }
  }

  Future<void> loadSavedTimer() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc('doorlock')
        .collection('timers')
        .doc(timerId)
        .get();
    print('불러왔는데?');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('endTime')) {
        final endTimeSeconds = data['endTime'] as int;
        _endTime = DateTime.fromMillisecondsSinceEpoch(endTimeSeconds * 1000, isUtc: true).toLocal();
        temporaryPassword = data['password'];
        if (_endTime!.isAfter(DateTime.now())) {
          add(CheckTimer());
        } else {
          _endTime = null;
          _saveEndTime(null,null);
        }
      }
    }
  }
}