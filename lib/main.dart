import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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

  void patchFindHandler(Coordinates coords) {
    setState(() {
      coordsOfDestination = coords;
      _pageNumber = 2;
    });
  }

  Future<CameraPosition> getCurrentLocation() async {
    bool serviceEnabled;
    //LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var status = await Permission.location.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> status =
          await [Permission.location].request();
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }

    Position _currentPosition = await Geolocator.getCurrentPosition();
    print('Device`s position: $_currentPosition');
    LatLng convertedPosition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);
    return CameraPosition(target: convertedPosition, zoom: 15);
  }

  void enterPage(int pageNumber) {
    setState(() {
      _pageNumber = pageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              title: 'Temple Finder',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: Colors.white,
              ),
              home: (_pageNumber == 0)
                  ? StartMapScreen(enterPage, snapshot.data!)
                  : (_pageNumber == 1)
                      ? PropList(enterPage, snapshot.data!, patchFindHandler)
                      : PatchFind(
                          LatLng(coordsOfDestination!.latitude!,
                              coordsOfDestination!.longitude!),
                          LatLng(snapshot.data!.target.latitude,
                              snapshot.data!.target.longitude)),
            );
          } else {
            return const Align(
                alignment: Alignment.center,
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator()));
          }
        });
  }
}
