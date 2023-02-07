import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  @override
  Widget build(BuildContext content) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
        body: Padding(padding:EdgeInsets.all(10), child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,  // or use fixed size like 200
              height: MediaQuery.of(context).size.height-100,
              child: const GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: _initialCameraPosition,
                    )
            ),
            SizedBox(height:10),
            SizedBox(
              width: 180,
              height: 60,
              child:ElevatedButton(onPressed: ()=>{}, style: ElevatedButton.styleFrom(primary: Color(0xFF374151)),child: Text('Wyszukaj Nabożeństwa',textAlign: TextAlign.center, style: TextStyle(fontSize: 20)))
            )
    ])
    ));
  }
}
