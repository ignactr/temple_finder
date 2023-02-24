import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'list.dart';
import 'startmapscreen.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'patchfind.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  int _pageNumber = 0;
  Coordinates? coordsOfDestination;
  String? time;
  String? weekDay;
  CameraPosition? currentLocation;

  void setTimeAndWeekDay(String timeToSet, String weekDayToSet) {
    setState(() {
      time = timeToSet;
      weekDay = weekDayToSet;
    });
  }

  void patchFindHandler(Coordinates coords) {
    setState(() {
      coordsOfDestination = coords;
      _pageNumber = 2;
    });
  }

  void enterPage(int pageNumber) {
    setState(() {
      _pageNumber = pageNumber;
    });
  }

  void handleCancel() {
    coordsOfDestination = null;
    time = null;
    weekDay = null;
    enterPage(0);
  }

  void setCurrentLocation(CameraPosition currentLocationToSet) {
    setState(() {
      currentLocation = currentLocationToSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temple Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: (_pageNumber == 0)
          ? StartMapScreen(enterPage, setTimeAndWeekDay, setCurrentLocation)
          : (_pageNumber == 1)
              ? PropList(handleCancel, currentLocation!, patchFindHandler,
                  time!, weekDay!)
              : PatchFind(
                  LatLng(coordsOfDestination!.latitude!,
                      coordsOfDestination!.longitude!),
                  LatLng(currentLocation!.target.latitude,
                      currentLocation!.target.longitude),
                  handleCancel),
    );
  }
}
