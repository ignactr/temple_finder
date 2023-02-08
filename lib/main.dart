import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'list.dart';

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
  void enterPage(int pageNumber) {
    setState(() {
      _pageNumber = pageNumber;
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
      home: (_pageNumber == 1) ? MapScreen(enterPage) : PropList(enterPage),
    );
  }
}

class MapScreen extends StatefulWidget {
  final enterPage;

  MapScreen(@required this.enterPage);

  @override
  _MapScreenState createState() => _MapScreenState(enterPage);
}

class _MapScreenState extends State<MapScreen> {
  final enterPage;

  _MapScreenState(@required this.enterPage);

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(53.130, 23.164),
    zoom: 15,
  );

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
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (controller) =>
                          _googleMapController = controller,
                    ),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      onPressed: () => _googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                              _initialCameraPosition)),
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
