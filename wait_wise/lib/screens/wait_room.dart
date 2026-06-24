import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wait_wise/widgets/LiveClock.dart';

class WaitRoom extends StatefulWidget {
  const WaitRoom({super.key});

  @override
  State<WaitRoom> createState() => _WaitRoomState();
}

class _WaitRoomState extends State<WaitRoom> {
  Timer? _timer;
  final now = DateTime.now();
  String currWeek = "";
  @override
  void initState() {
    super.initState();
    currWeek = week(now.weekday);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String week(int day) {
    switch (day) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        "null";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E5E8),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 12),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // time day date and weather row !
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currWeek} ${now.day}/${now.month}/${now.year}',
                          style: GoogleFonts.jetBrainsMono(color: Colors.grey),
                        ),
                        const LiveClock(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.shape_line_outlined,
                          color: Colors.grey,
                          size: 15,
                        ),
                        const SizedBox(height: 20),
                        const _LiveWeather(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        height: 400,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          // border: Bor,
                          color: const Color.fromARGB(255, 220, 221, 222),
                          boxShadow: [
                            // dark edge
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 4,
                              blurRadius: 10,
                              blurStyle: BlurStyle.inner,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "CURRENTLY_SERVING",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 20,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "#7",
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 81,
                                        color: Colors.deepOrange,
                                        letterSpacing: 6,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 400,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          boxShadow: [
                            // dark edge
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),

                              blurRadius: 6,
                            ),

                            // highlight edge
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(-3, -3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 2,
                              ),
                              child: Text(
                                'Up_Next',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Divider(color: Colors.grey[300]),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 8,
                                itemBuilder: (_, index) {
                                  return _upnextToken(
                                    index + 1,
                                    "PRC",
                                    index % 2 == 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Wait_Wise',
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    // color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      colors: [
                        Colors.deepOrange,
                        const Color.fromARGB(255, 20, 19, 19),
                      ],
                      radius: 50,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "BOOT",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "VERIFY",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                color: Colors.black,
                                value: 1,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: LinearProgressIndicator(
                                color: Colors.black,
                                value: 1,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "RDY",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "PRC",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _upnextToken(int token, String name, bool isOdd) {
    Color col = isOdd ? Colors.deepOrangeAccent : Colors.grey;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("#$token", style: GoogleFonts.jetBrainsMono(color: col)),
          Divider(),
          Text("Name : $name", style: GoogleFonts.jetBrainsMono(color: col)),
        ],
      ),
    );
  }
}

class _LiveWeather extends StatefulWidget {
  const _LiveWeather();

  @override
  State<_LiveWeather> createState() => __LiveWeatherState();
}

class __LiveWeatherState extends State<_LiveWeather> {
  late Timer _timer;
  double? _temp;
  String? _city;
  @override
  void initState() {
    super.initState();
    _fetchWeatherWeb();
    _timer = Timer.periodic(const Duration(minutes: 25), (_) async {
      _fetchWeatherWeb();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "$_temp°C , $_city",
      style: GoogleFonts.jetBrainsMono(color: Colors.grey),
    );
  }

  void _fetchWeatherWeb() {
  html.window.navigator.geolocation.getCurrentPosition().then((pos) async {
    final lat = pos.coords!.latitude!;
    final lon = pos.coords!.longitude!;

    // run both requests in parallel
    final results = await Future.wait([
      Dio().get(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon&current_weather=true'
      ),
      Dio().get(
        
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=$lat&lon=$lon&format=json'
        ,
        options:Options(headers:  {'User-Agent': 'WaitWise/1.0'}), // nominatim requires this
      ),
    ]);

    final weather = (results[0].data);
    final geo = (results[1].data);

    setState(() {
      _temp = weather['current_weather']['temperature'];
      // falls back through options: city → town → suburb → county
      _city = geo['address']['city'] 
           ?? geo['address']['town'] 
           ?? geo['address']['suburb'] 
           ?? geo['address']['county']
           ?? 'Unknown';
    });
  }).catchError((e) {
    debugPrint('Location error: $e');
  });
}
}
