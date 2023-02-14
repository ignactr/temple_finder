import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StartMapScreen extends StatefulWidget {
  final Function enterPage;
  final CameraPosition devicesLocation;

  StartMapScreen(Function this.enterPage, CameraPosition this.devicesLocation);

  @override
  _StartMapScreenState createState() =>
      _StartMapScreenState(enterPage, this.devicesLocation);
}

class _StartMapScreenState extends State<StartMapScreen> {
  final enterPage;
  final CameraPosition devicesLocation;

  _StartMapScreenState(
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
