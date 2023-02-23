import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class StartMapScreen extends StatefulWidget {
  final Function enterPage;
  final Function setTimeAndWeekDay;
  final CameraPosition devicesLocation;

  StartMapScreen(Function this.enterPage, Function this.setTimeAndWeekDay,
      CameraPosition this.devicesLocation);

  @override
  _StartMapScreenState createState() =>
      _StartMapScreenState(enterPage, setTimeAndWeekDay, this.devicesLocation);
}

class _StartMapScreenState extends State<StartMapScreen> {
  final enterPage;
  final Function setTimeAndWeekDay;
  final CameraPosition devicesLocation;

  _StartMapScreenState(this.enterPage, Function this.setTimeAndWeekDay,
      CameraPosition this.devicesLocation);

  late GoogleMapController _googleMapController;
  String? time;
  String? currentTime;
  Timer? timer;
  String? weekDay;

  void _whichWeekDay() {
    DateTime day = DateTime.now();
    if (day.weekday == 7) {
      setState(() {
        weekDay = 'niedziela';
      });
    } else {
      setState(() {
        weekDay = 'pon-pt';
      });
    }
  }

  void _changeWeekDay() {
    setState(() {
      if (weekDay == 'niedziela') {
        weekDay = 'pon-pt';
      } else {
        weekDay = 'niedziela';
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void getCurrentTime() {
    TimeOfDay timeNotFormatted = TimeOfDay.now();
    setStateIfMounted(() {
      currentTime = '${timeNotFormatted.hour}:${timeNotFormatted.minute}';
    });
  }

  Future<void> _show() async {
    final TimeOfDay? result = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, childWidget) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  // Using 24-Hour format
                  alwaysUse24HourFormat: true),
              child: childWidget!);
        });
    if (result != null) {
      setState(() {
        time =
            '${(result.hour < 10) ? '0' + result.hour.toString() : result.hour}:${(result.minute < 10) ? '0' + result.minute.toString() : result.minute}';
      });
    }
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getCurrentTime();
    _whichWeekDay();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => getCurrentTime());
    super.initState();
  }

  @override
  Widget build(BuildContext content) {
    return Scaffold(
        backgroundColor: const Color(0xFF0f172a),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              const SizedBox(height: 20),
              SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: 180,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () => {_show()},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF374151)),
                                child: Text('godzina: ${time ?? currentTime}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 15)))),
                        SizedBox(
                            width: 180,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () => {_changeWeekDay()},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF374151)),
                                child: Text('dzień: $weekDay',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 15)))),
                      ])),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 160,
                  child: Scaffold(
                    body: GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: devicesLocation,
                      onMapCreated: (controller) =>
                          _googleMapController = controller,
                    ),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      onPressed: () => _googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(devicesLocation)),
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 180,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        setTimeAndWeekDay(time ?? currentTime, weekDay);
                        enterPage(1);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151)),
                      child: Text('Szukaj nabożeństwa',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20))))
            ])));
  }
}
