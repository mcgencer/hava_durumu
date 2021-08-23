// @dart=2.9

import 'package:flutter/material.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Ankara';
  int sicaklik;
  var locationData;
  var woeid;
  String abbr;
  Position position;
  List<int> temps = List(5);
  List<String> abbrs = List(5);
  List<String> dates = List(5);

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      print('Şu hata oluştu $e');
    }
  }

  Future<void> getLocationTemperature() async {
    var response =
        await http.get('https://www.metaweather.com/api/location/$woeid/');

    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik =
          temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();

      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed['consolidated_weather'][i + 1]
                ['the_temp']
            .round();
      }
      for (int i = 0; i < abbrs.length; i++) {
        abbrs[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
      }

      for (int i = 0; i < dates.length; i++) {
        dates[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['applicable_date'];
      }

      abbr = temperatureDataParsed['consolidated_weather'][0]
          ['weather_state_abbr'];
    });
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get("https://www.metaweather.com/api/location/search/?query=$sehir");

    var locationDataParse = jsonDecode(locationData.body);
    woeid = locationDataParse[0]['woeid'];
  }

  Future<void> getLocationDataLattLong() async {
    locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}");

    var locationDataParse = jsonDecode(utf8.decode(locationData.bodyBytes));
    woeid = locationDataParse[0]['woeid'];
    sehir = locationDataParse[0]['title'];
  }

  void getDataFromAPI() async {
    await getDevicePosition(); // cihazdan konum bilgisini  çekiyoruz
    await getLocationDataLattLong(); // lat ve long ile woeid bilgisini çekiyoruz APIden
    getLocationTemperature(); // woeid bilgisi ile sıcaklık verisini çekiyoruz
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: AssetImage("assets/$abbr.jpg")),
      ),
      child: sicaklik == null
          ? Center(child: SpinKitDoubleBounce(color: Colors.white, size: 50))
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          "https://www.metaweather.com/static/img/weather/png/$abbr.png"),
                    ),
                    Text(
                      '$sicaklik ° C',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 70,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(-3, 3),
                            )
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$sehir",
                          style: TextStyle(fontSize: 30, shadows: <Shadow>[
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(-3, 3),
                            )
                          ]),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                            getDataFromAPIbyCity();
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    buildDailyWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyWeatherCards(BuildContext context) {

    List <Widget> cards=List(5);

    for(int i=0;i<cards.length;i++){
      cards[i]=DailyWeather(image: abbrs[i], temp: temps[i].toString(), date: dates[i]);
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key key, @required this.image, @required this.temp, @required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://www.metaweather.com/static/img/weather/png/$image.png",
              height: 50,
              width: 50,
            ),
            Text("$temp ° C"),
            Text("$date"),
          ],
        ),
      ),
    );
  }
}
