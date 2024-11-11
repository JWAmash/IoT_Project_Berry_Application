//state
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iot_project_berry/src/data/timeCalculator.dart';

String weatherapikey = dotenv.env['weatherapikey'].toString();

abstract class WeatherState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Map<String, dynamic> weatherUSNData;
  final Map<String, dynamic> weatherUSFData;
  final Map<String, dynamic> weatherVFData;
  Map<String, Map<String, Map<String, dynamic>>>? processedWeatherUSNData;
  final Map<String, Map<String, Map<String, dynamic>>> processedWeatherUSFData;
  final Map<String, Map<String, Map<String, dynamic>>> processedWeatherVFData;

  WeatherLoaded(
      {required this.weatherUSNData,
      required this.weatherUSFData,
      required this.weatherVFData,this.processedWeatherUSNData ,required this.processedWeatherUSFData,required this.processedWeatherVFData});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class WeatherProcessed extends WeatherState {
  final Map<String, dynamic> processedWeatherUSNData;
  final Map<String, dynamic> processedWeatherUSFData;
  final Map<String, dynamic> processedWeatherVFData;

  WeatherProcessed(
      {required this.processedWeatherUSNData,
      required this.processedWeatherUSFData,
      required this.processedWeatherVFData});
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

//Event
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchWeather extends WeatherEvent {
  final int latx;
  final int laty;

  const FetchWeather({required this.latx, required this.laty});

  @override
  // TODO: implement props
  List<Object?> get props => [latx, laty];
}

// WeatherService
class WeatherService {
  final String apikey;
  final String baseUrl =
      'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';

  WeatherService({required this.apikey});
  TimeCalculator calsystime = TimeCalculator();


  //수정이 필요한 부분
  Future<Map<String, dynamic>> getWeatherUltraSrtNcstData(
      {required int latx, required int laty}) async {
    var ultraSrtNcst = calsystime.convWeatherApiTimeUltraSrtNcst();
    String ultraSrtNcstDate = ultraSrtNcst['basedate'];
    String ultraSrtNcstTime = ultraSrtNcst['basetime'];

    final url =
        '$baseUrl/getUltraSrtNcst?serviceKey=$weatherapikey&numOfRows=100&pageNo=1&dataType=JSON&base_date=$ultraSrtNcstDate&base_time=$ultraSrtNcstTime&nx=$latx&ny=$laty';
    print(
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=$weatherapikey&numOfRows=100&pageNo=1&dataType=JSON&base_date=$ultraSrtNcstDate&base_time=$ultraSrtNcstTime&nx=$latx&ny=$laty');
    return _getData(url);
  }

  Future<Map<String, dynamic>> getWeatherUltraSrtFcstData(
      {required int latx, required int laty}) async {

    var ultraSrtFcst = calsystime.convWeatherApiTimeUltraSrtFcst();
    String ultraSrtFcstDate = ultraSrtFcst['basedate'];
    String ultraSrtFcstTime = ultraSrtFcst['basetime'];

    final url =
        '$baseUrl/getUltraSrtFcst?serviceKey=$weatherapikey&numOfRows=100&pageNo=1&dataType=JSON&base_date=$ultraSrtFcstDate&base_time=$ultraSrtFcstTime&nx=$latx&ny=$laty';
    return _getData(url);
  }

  Future<Map<String, dynamic>> getWeatherVilageFcstData(
      {required int latx, required int laty}) async {
    var vilageFcst = calsystime.convWeatherApiTimeVilageFcst();
    String vilageFcstDate = vilageFcst['basedate'];
    String vilageFcstTime = vilageFcst['basetime'];

    final url =
        '$baseUrl/getVilageFcst?serviceKey=$weatherapikey&numOfRows=100&pageNo=1&dataType=JSON&base_date=$vilageFcstDate&base_time=$vilageFcstTime&nx=$latx&ny=$laty';
    return _getData(url);
  }

  Future<Map<String, dynamic>> _getData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('이게 바디인가: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load Data');
    }
  }
  //초단기 실황
  dynamic ProcessedUSNData(
      dynamic weatherUSNData) {
    var USND = weatherUSNData;
    print("초단기 실황 정리 예정");
    print(USND);
    // print(organizedVFData['20240904']);
    // print(organizedVFData['20240905']);
    // print(organizedVFData['20240906']);
  }

  //초단기 예보
  Map<String, Map<String, Map<String, dynamic>>> ProcessedUSFData(
      dynamic weatherUSFData) {
    var USFD = weatherUSFData['response']['body']['items']['item'];
    Map<String, Map<String, Map<String, dynamic>>>? organizedUSFData = {};
    // print('여기서 막혔나');
    // print(USFD);
    for (var item in USFD) {
      String date = item['fcstDate'];
      String time = item['fcstTime'];
      String category = item['category'];
      dynamic value = item['fcstValue'];
      if (!organizedUSFData.containsKey(date)) {
        organizedUSFData[date] = {};
      }
      if (!organizedUSFData[date]!.containsKey(time)) {
        organizedUSFData[date]![time] = {};
      }
      organizedUSFData[date]![time]![category] = value;
    }
    
    print("초단기예보 정리");
    print(organizedUSFData);
    return organizedUSFData;
    // print(organizedVFData['20240904']);
    // print(organizedVFData['20240905']);
    // print(organizedVFData['20240906']);
  }

  Map<String, Map<String, Map<String, dynamic>>> ProcessedVFData(
      dynamic weatherVFData) {
    var VFD = weatherVFData['response']['body']['items']['item'];
    Map<String, Map<String, Map<String, dynamic>>> organizedVFData = {}; //단기예보 정리
    for (var item in VFD) {
      String date = item['fcstDate'];
      String time = item['fcstTime'];
      String category = item['category'];
      dynamic value = item['fcstValue'];
      if (!organizedVFData.containsKey(date)) {
        organizedVFData[date] = {};
      }
      if (!organizedVFData[date]!.containsKey(time)) {
        organizedVFData[date]![time] = {};
      }
      organizedVFData[date]![time]![category] = value;
    }
    print("정리값들 단기예보정리");
    print(organizedVFData);
    return organizedVFData;
  }
  
  
  
  

}

//Bloc
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService weatherService;

  WeatherBloc({required this.weatherService}) : super(WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
  }

  Future<void> _onFetchWeather(
      FetchWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      //초단기 실황
      weatherService..calsystime.setCurSystime();
      var weatherUltraSrtNcstData =
          await weatherService.getWeatherUltraSrtNcstData(
        latx: event.latx,
        laty: event.laty,
      );
      //초단기 예보
      var weatherUltraSrtFcstData = await weatherService
          .getWeatherUltraSrtFcstData(latx: event.latx, laty: event.laty);
      //단기 예보
      var weatherVilageFcstData = await weatherService
          .getWeatherVilageFcstData(latx: event.latx, laty: event.laty);
      
      print('초단기 실황');
      print(weatherUltraSrtNcstData);
      print('초단기 예보');
      print(weatherUltraSrtFcstData);
      print('단기예보');
      print(weatherVilageFcstData);
      var pUSND = weatherService.ProcessedUSNData(weatherUltraSrtNcstData);
      var pUSFD = weatherService.ProcessedUSFData(weatherUltraSrtFcstData);
      var pVFD = weatherService.ProcessedVFData(weatherVilageFcstData);
      print('이부분 안들어감 문제인가');
      emit(WeatherLoaded(
          weatherUSNData: weatherUltraSrtNcstData,
          weatherUSFData: weatherUltraSrtFcstData,
          weatherVFData: weatherVilageFcstData,processedWeatherUSFData: pUSFD,processedWeatherUSNData: pUSND,processedWeatherVFData: pVFD));
      print('여기 문제인가 마즌');
    } catch (e) {
      emit(WeatherError(
          message: 'Failed to fetch weather data: ${e.toString()}'));
    }
  }
}
