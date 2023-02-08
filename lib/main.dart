import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temple Finder',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37, -122),
    zoom: 14,
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
                  width: MediaQuery.of(context)
                      .size
                      .width, // or use fixed size like 200
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
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151)),
                      child: const Text('Wyszukaj Nabożeństwa',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20))))
            ])));
  }
}
