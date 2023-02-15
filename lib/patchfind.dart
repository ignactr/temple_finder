import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PatchFind extends StatefulWidget {
  final LatLng coordsOfDestination;
  final LatLng sourceLocation;
  const PatchFind(this.coordsOfDestination, this.sourceLocation, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PatchFindState(coordsOfDestination, sourceLocation);
  }
}

class _PatchFindState extends State<PatchFind> {
  final LatLng coordsOfDestination;
  final LatLng sourceLocation;
  _PatchFindState(this.coordsOfDestination, this.sourceLocation);

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: sourceLocation, zoom: 15),
      markers: {
        Marker(markerId: const MarkerId("początek"), position: sourceLocation),
        Marker(markerId: const MarkerId("cel"), position: coordsOfDestination)
      },
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
    );
  }
}
