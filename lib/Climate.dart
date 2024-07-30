import 'package:flutter/material.dart';
import 'utils/apifile.dart' as util;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

String? weatherDescription;
String weatherIcon = 'images/clear.png';

void updateIcons() {
  if (weatherDescription == "clear sky") {
    weatherIcon = 'images/sun.png';
  } else if (weatherDescription == "few clouds") {
    weatherIcon = 'images/clearSky.png';
  } else if (weatherDescription == "scattered clouds" ||
      weatherDescription == "broken clouds") {
    weatherIcon = 'images/clouds.png';
  } else if (weatherDescription == "overcast clouds") {
    weatherIcon = 'images/blackClouds.png';
  } else if (weatherDescription == "light rain" ||
      weatherDescription == "moderate rain") {
    weatherIcon = 'images/rain.png';
  } else if (weatherDescription == "heavy intensity rain") {
    weatherIcon = 'images/stormy.png';
  } else if (weatherDescription == "smoke") {
    weatherIcon = 'images/smoke2.png';
  }
}

class ChangeCity extends StatelessWidget {
  final TextEditingController _cityFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF68A1B4),
        title: Text("Change City"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/umbrella.jpg',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          ListView(
            children: [
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter City Name',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: TextButton(
                  onPressed: () {
                    Navigator.pop(
                        context, {'enter': _cityFieldController.text});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade400,
                  ),
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(10, 130, 0, 0)),
              Text('  Suggestions'),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {'enter': 'lahore'});
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.white10,
                ),
                child: Text("    Lahore    "),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {'enter': 'islamabad'});
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.white10,
                ),
                child: Text(" Islamabad "),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {'enter': 'faisalabad'});
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.white10,
                ),
                child: Text(" Faislabad "),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, {'enter': 'multan'});
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.white10,
                ),
                child: Text("    Multan    "),
              ),
            ],
          ),
        ],
      ),
      // debugShowCheckedModeBanner: false,
    );
  }
}

class Climate extends StatefulWidget {
  const Climate({super.key});

  @override
  State<Climate> createState() => _ClimateState();
}

class _ClimateState extends State<Climate> {
  String? _cityEntered;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    fetchWeather();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchWeather();
    });
  }

  void fetchWeather() async {
    Map data = await getWeather(util.apiId, _cityEntered ?? util.defaultCity);
    setState(() {
      weatherDescription = data['weather'][0]['description'];
      updateIcons();
    });
  }

  Future _goToNextScreen(BuildContext context) async {
    Map? results = await Navigator.of(context).push(
      MaterialPageRoute<Map>(builder: (BuildContext context) {
        return ChangeCity();
      }),
    );

    if (results != null && results.containsKey('enter')) {
      setState(() {
        _cityEntered = results['enter'];
        fetchWeather();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        backgroundColor: Color(0xFF68A1B4),
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _goToNextScreen(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'images/umbrella.jpg',
              height: 1200.0,
              width: 470,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: updateTempWidget('${_cityEntered ?? util.defaultCity}'),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              '${_cityEntered ?? util.defaultCity}',
              style: cityStyle(),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(70, 80, 160, 0),
            child: Image.asset(
              weatherIcon,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appID, String city) async {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$appID&units=imperial';
    http.Response response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
      future: getWeather(util.apiId, city),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No Data Available'));
        } else {
          Map content = snapshot.data!;
          double tempF = content['main']['temp'];
          double tempC = (tempF - 32) * 5 / 9;
          double tempMinF = content['main']['temp_min'];
          double tempMinC = (tempMinF - 32) * 5 / 9;
          double tempMaxF = content['main']['temp_max'];
          double tempMaxC = (tempMaxF - 32) * 5 / 9;
          double feelsLikeF = content['main']['feels_like'];
          double feelsLikeC = (feelsLikeF - 32) * 5 / 9;
          weatherDescription = content['weather'][0]['description'];
          updateIcons();

          return Container(
            margin: const EdgeInsets.fromLTRB(30.0, 240.0, 0.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: Text(
                    tempC.toStringAsFixed(2) + "°C",
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 49.9,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: ListTile(
                    title: Text(
                      "Humidity: ${content['main']['humidity'].toString()}\n"
                      "Min: ${tempMinC.toStringAsFixed(2)}°C\n"
                      "Max: ${tempMaxC.toStringAsFixed(2)}°C\n"
                      "Feels Like: ${feelsLikeC.toStringAsFixed(2)}°C\n"
                      "Condition: $weatherDescription",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 25.9,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold);
}

TextStyle extraData() {
  return TextStyle(
    color: Colors.white70,
    fontSize: 17.0,
    fontStyle: FontStyle.normal,
  );
}
