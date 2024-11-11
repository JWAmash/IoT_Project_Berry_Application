import 'package:intl/intl.dart';

class TimeCalculator{
  DateTime? now;
  // 생성자를 통해 초기 now설정 -> 오류 해결 위함 맞는 방식인지 확인해야함
  TimeCalculator() : now = DateTime.now();

  setCurSystime(){
    now = DateTime.now();
  }
  DateTime getSysTime(){
    if(now == null){
      throw Exception("현재 시간이 설정되지 않았습니다. setCurSystime()을 호출하세요.");
    }
    return now!;
  }
  String getDateTime(){
    return DateFormat("yyyyMMdd").format(now!);
  }

  String getYesDateTime(){
    return DateFormat("yyyyMMdd").format(now!.subtract(Duration(days: 1)));
  }

  //초단기 실황조회
  convWeatherApiTimeUltraSrtNcst(){
    var rs ={};
    print("초단기 실황");
    if(now!.minute>=10){
      rs['basetime'] = DateFormat("HH00").format(now!);
      rs['basedate'] = getDateTime();
    }else{
      if(now!.hour==0){
        rs['basetime'] = "2300";
        rs['basedate'] = getYesDateTime();
      }else{
        rs['basetime'] = DateFormat("HH00").format(now!.subtract(Duration(hours: 1)));
        rs['basedate'] = getDateTime();
      }
    }
    print("초단기실황 시간"+rs['basetime']+"날짜"+rs['basedate']);
    return rs;
  }
  //초단기예보조회
  convWeatherApiTimeUltraSrtFcst(){
    var rs ={};
    print("초단기 예보");

    if(now!.minute>=45){
      rs['basetime'] = DateFormat("HH30").format(now!);
      rs['basedate'] = getDateTime();
    }else{
      if(now!.hour==0){
        rs['basetime'] = "2330";
        rs['basedate'] = getYesDateTime();
      }else{
        rs['basetime'] = DateFormat("HH30").format(now!.subtract(Duration(hours: 1)));
        rs['basedate'] = getDateTime();
      }
    }
    print("초단기예보 시간"+rs['basetime']+"날짜"+rs['basedate']);
    return rs;
  }
  //단기예보
  convWeatherApiTimeVilageFcst(){
    var rs ={};
    print("단기예보");
    //Base_time : 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 (1일 8회)
    //api제공    : 0210, 0510, 0810, 1110, 1410, 1710, 2010, 2310 (1일 8회)
    if(now!.minute>=10){ //매 시각 10분~59분
      if(now!.hour<2){  // 00:10~ / 01:10~
        rs['basetime'] = "2300";
        rs['basedate'] = getYesDateTime();
      }else if(now!.hour<5){ // 02:10~ / 03:10~ / 04:10~
        rs['basetime'] = "0200";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<8){ // 05:10~ / 06:10~ / 07:10~
        rs['basetime'] = "0500";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<11){ // 08:10~ / 09:10~ / 10:10~
        rs['basetime'] = "0800";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<14){ // 11:10~ / 12:10~ / 13:10~
        rs['basetime'] = "1100";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<17){ // 14:10~ / 15:10~ / 16:10~
        rs['basetime'] = "1400";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<20){ // 17:10~ / 18:10~ / 19:10~
        rs['basetime'] = "1700";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<23){ // 20:10~ / 21:10~ / 22:10~
        rs['basetime'] = "2000";
        rs['basedate'] = getDateTime();
      }else if(now!.hour ==23){ // 23:10~
        rs['basetime'] = "2300";
        rs['basedate'] = getDateTime();
      }
    }else if(now!.minute<10){
      if(now!.hour<3){  // ~00:09 / ~01:09 / ~02:09
        rs['basetime'] = "2300";
        rs['basedate'] = getYesDateTime();
      }else if(now!.hour<6){ // ~03:09 / ~04:09 / ~05:09
        rs['basetime'] = "0200";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<9){ // ~06:09 / ~07:09 / ~08:09
        rs['basetime'] = "0500";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<12){ // ~09:09 / ~10:09 / ~11:09
        rs['basetime'] = "0800";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<15){ // ~12:09 / ~13:09 / ~14:09
        rs['basetime'] = "1100";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<18){ // ~15:09 / ~16:09 / ~17:09
        rs['basetime'] = "1400";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<21){ // ~18:09 / ~19:09 / ~20:09
        rs['basetime'] = "1700";
        rs['basedate'] = getDateTime();
      }else if(now!.hour<=23){ // ~21:09 / ~22:09 / ~23:09
        rs['basetime'] = "2000";
        rs['basedate'] = getDateTime();
      }
    }
    print("단기예보 시간"+rs['basetime']+"날짜"+rs['basedate']);
    return rs;
  }
  //예보버전
  // convWeatherApiTimeFcstVersion(){
  //   print("예보버전");
  // }
}