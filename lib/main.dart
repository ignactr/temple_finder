import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'list.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
  var devicesLocation = const CameraPosition(
    target: LatLng(53.130, 23.164),
    zoom: 15,
  );

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //if (!serviceEnabled) {
    //  print('Location services are disabled');
    //}
    //permission = await Geolocator.checkPermission();
    //if (permission == LocationPermission.denied) {
    //  print(
    //      'Location permissions are permanently denied, we cannot request permissions');
    //}
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
    setState(() {
      devicesLocation = CameraPosition(target: convertedPosition, zoom: 15);
    });
  }

  int _pageNumber = 0;
  void enterPage(int pageNumber) {
    setState(() {
      _pageNumber = pageNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
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
          ? MapScreen(enterPage, devicesLocation)
          : PropList(enterPage, devicesLocation),
    );
  }
}

class MapScreen extends StatefulWidget {
  final Function enterPage;
  final CameraPosition devicesLocation;

  MapScreen(Function this.enterPage, CameraPosition this.devicesLocation);

  @override
  _MapScreenState createState() =>
      _MapScreenState(enterPage, this.devicesLocation);
}

class _MapScreenState extends State<MapScreen> {
  final enterPage;
  final CameraPosition devicesLocation;

  _MapScreenState(
      @required this.enterPage, CameraPosition this.devicesLocation);

  late GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext content) {
    return Scaffold(
        backgroundColor: const Color(0xFF0f172a),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100,
                  child: Scaffold(
                    body: GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: devicesLocation,
                      //initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (controller) =>
                          _googleMapController = controller,
                    ),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      onPressed: () => _googleMapController
                          .animateCamera(CameraUpdate.newCameraPosition(
                              //_initialCameraPosition)),
                              devicesLocation)),
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 180,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () => {enterPage(1)},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151)),
                      child: Text('Szukaj nabożeństwa',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20))))
            ])));
  }
}
