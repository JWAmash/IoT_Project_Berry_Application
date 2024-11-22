import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String tmLocateApiKey = dotenv.env['tmLocateApiKey'].toString();
String airPollutionApiKey = dotenv.env['airPollutionApiKey'].toString();
abstract class AirPollutionState extends Equatable{
  List<Object?> get props => [];
}

class AirPollutionInitial extends AirPollutionState{}
class AirPollutionLoading extends AirPollutionState{}
class AirPollutionLoadedTmAddress extends AirPollutionState{
  final String? tmx;
  final String? tmy;
  AirPollutionLoadedTmAddress({this.tmx,this.tmy});
  @override
  List<Object?> get props => [tmx,tmy];
}
class AirPollutionLoadedAirData extends AirPollutionState{
  final int? pm;
  final int? fpm;
  final String? time;
  final String? station;
  AirPollutionLoadedAirData({required this.pm,required this.fpm,required this.time,required this.station});

  @override
  List<Object?> get props =>[pm,fpm];
}

class AirPollutionError extends AirPollutionState{
  final String? message;
  AirPollutionError({this.message});
  @override
  List<Object?> get props => [message];
}



abstract class AirPollutionEvent{}

class AirPollutionTmAddressForSearch extends AirPollutionEvent{
  final String address;
  AirPollutionTmAddressForSearch({required this.address});
}

class AirPollutionBloc extends Bloc<AirPollutionEvent,AirPollutionState>{

  AirPollutionBloc(): super(AirPollutionInitial()){
    on<AirPollutionTmAddressForSearch>(_onGetTmAddress);
  }


  Future<void> _onGetTmAddress(AirPollutionTmAddressForSearch event,Emitter<AirPollutionState> emit) async{
    emit(AirPollutionLoading());
    try{

      // tm좌표 확인
      Map<String, dynamic> tmData = await getTmAddress(event.address);
      print("테스트: $tmData");
      var tmX = tmData['response']['body']['items'][0]["tmX"];
      var tmY = tmData['response']['body']['items'][0]["tmY"];

      // 관측소 좌표 확인
      Map<String, dynamic> stationData = await getStation(tmX,tmY);
      var firstUmdName = stationData['response']['body']['items'][0]["stationName"];
      print('첫 관측소: $firstUmdName');


      // 공기질 확인
      Map<String, dynamic> airData = await getAirPollutionData(firstUmdName);
      print('공기데이터: $airData');
      var pm = 0;
      var fpm = -1;
      var rawPmData = airData['response']['body']['items'][0]['pm10Value'];
      var rawFpmData = airData['response']['body']['items'][0]['pm25Value'];
      if(rawPmData=='-'||rawPmData=='통신장애'||rawPmData==null){
        print('여기');
        pm = -1;
      }else{
        print('저기');
        pm = int.parse(rawPmData);
      }
      print('넘음');
      if(rawFpmData=='-'||rawFpmData=='통신장애'||rawFpmData==null){
        fpm = -1;
      }else{
        fpm = int.parse(rawFpmData);
      }
      var time = airData['response']['body']['items'][0]['dataTime'];

      print('가공데이터: $pm  / $fpm');

      emit(AirPollutionLoadedAirData(pm: pm, fpm: fpm, time: time, station: firstUmdName));
    }catch(e){
      emit(AirPollutionError(message: 'There was a problem getting the location.'));
    }
  }
  Future<Map<String, dynamic>> getTmAddress(String address)async{

    final String url = 'https://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getTMStdrCrdnt?serviceKey=$tmLocateApiKey&returnType=json&numOfRows=100&pageNo=1&umdName=$address';

    // GET 요청 보내기
    final response = await http.get(Uri.parse(url));
    // 응답 상태 확인 및 데이터 처리
    if (response.statusCode == 200) {
      print('응답 바디: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('오류: ${response.statusCode}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStation(String tmX,String tmY)async{

    final String url = 'https://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?serviceKey=$tmLocateApiKey&returnType=json&tmX=$tmX&tmY=$tmY&ver=1.1';

    // GET 요청 보내기
    final response = await http.get(Uri.parse(url));
    // 응답 상태 확인 및 데이터 처리
    if (response.statusCode == 200) {
      print('응답 바디: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('오류: ${response.statusCode}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getAirPollutionData(String firstUmdName)async{

    final encodedStationName = Uri.encodeComponent(firstUmdName);
    final String url = 'https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?serviceKey=$airPollutionApiKey&returnType=json&numOfRows=100&pageNo=1&stationName=$encodedStationName&dataTerm=DAILY&ver=1.0';
    // GET 요청 보내기
    print(url);
    final response = await http.get(Uri.parse(url));
    // 응답 상태 확인 및 데이터 처리
    if (response.statusCode == 200) {
      print('응답 바디: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('오류: ${response.statusCode}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}