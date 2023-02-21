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
  String? time;

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
        time = '${result.hour}:${result.minute}';
      });
    }
  }

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
              const SizedBox(height: 20),
              SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Row(children: [
                    SizedBox(
                        width: 180,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () => {_show()},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF374151)),
                            child: Text('godzina: ${time ?? 'auto'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14))))
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
                      onPressed: () => {enterPage(1)},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF374151)),
                      child: Text('Szukaj nabożeństwa',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20))))
            ])));
  }
}
