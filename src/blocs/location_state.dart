import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iot_project_berry/src/data/convlocation.dart';

String kakaoApiKey = dotenv.env['kakaoapikey'].toString();

//State 정의
abstract class LocationState extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LocationInitial extends LocationState{}
class LocationLoading extends LocationState{}
class LocationLoaded extends LocationState{
  final double? latitude;
  final double? longitude;
  final int? latx;
  final int? laty;
  final String? error;
  final String? address;
  final String? city;
  LocationLoaded({this.latitude,this.longitude,this.error,this.latx,this.laty,this.address,this.city});

  @override
  // TODO: implement props
  List<Object?> get props => [latitude,longitude];
}
class LocationUnchanged extends LocationState{
  final double? latitude;
  final double? longitude;
  final int? latx;
  final int? laty;
  final String? error;
  LocationUnchanged({this.latitude,this.longitude,this.error,this.latx,this.laty});

  @override
  // TODO: implement props
  List<Object?> get props => [latitude,longitude,latx,laty];
}
class LocationError extends LocationState{
  final String message;

  LocationError({required this.message});
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}


//이벤트 정의
abstract class LocationEvent extends Equatable{
  const LocationEvent();
}
class GetMyCurrentLocation extends LocationEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
//Bloc 정의
class LocationBloc extends Bloc<LocationEvent,LocationState>{
  Position? _previousePosition;
  int? latx;
  int? laty;
  String? city;
  String? address;
  Map<String, dynamic>? addressJson;
  LocationBloc(): super(LocationInitial()){
    on<GetMyCurrentLocation>(_onGetLocation);
  }
  Future<void> _onGetLocation(GetMyCurrentLocation event,Emitter<LocationState> emit) async{
    emit(LocationLoading());
    try{
      LocationPermission permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if(_previousePosition == null|| _previousePosition!.latitude != position.latitude||_previousePosition!.longitude!=position.longitude){
        _previousePosition = position;

        var grid = ConvGridGps.gpsToGRID(position.latitude, position.longitude);
        latx=grid['x'];
        laty=grid['y'];
        print('여긴옴');
        addressJson= await getAddressFromCoordinates( position.longitude,position.latitude);
        city = addressJson?['documents'][0]['address']['region_1depth_name']??'error';
        address = addressJson?['documents'][0]['address']['address_name']??'error';
        print(city);
        print(address);
        print('x좌표: ${position.latitude} y좌표: ${position.longitude} x격자: ${latx} y격자:${laty} test:${address}');
        emit(LocationLoaded(latitude: position.latitude,longitude: position.longitude,latx: latx,laty: laty,address: address,city: city));
      }
      else{
        _previousePosition = position;
        var grid = ConvGridGps.gpsToGRID(position.latitude, position.longitude);
        print('같음');
        emit(LocationLoaded(latitude: position.latitude,longitude: position.longitude,latx: latx,laty: laty));
        //emit(LocationUnchanged(latitude: position.latitude,longitude: position.longitude));
      }
    }catch(e){
      emit(LocationError(message: 'There was a problem getting the location.'));
    }
  }

  Future<Map<String, dynamic>> getAddressFromCoordinates(double x, double y) async {
    // Kakao API 엔드포인트
    final String url = 'https://dapi.kakao.com/v2/local/geo/coord2address.json';

    // 헤더에 Kakao REST API 키 추가
    final headers = {
      'Authorization': kakaoApiKey, // 여기에 실제 REST API 키를 입력하세요.
    };

    // 쿼리 파라미터 설정
    final queryParams = {
      'x': x.toString(),
      'y': y.toString(),
      'input_coord': 'WGS84',
    };

    // Uri 객체 생성 (쿼리 파라미터 포함)
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    print(uri);
    // GET 요청 보내기
    final response = await http.get(uri, headers: headers);
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