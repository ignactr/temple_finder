import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCquYlfmsgzS99xqkDw17cY8RWaH1og-EI",
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(
            coordsOfDestination.latitude, coordsOfDestination.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
    }
    setState(() {});
  }

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: sourceLocation, zoom: 15),
      markers: {
        Marker(markerId: const MarkerId("początek"), position: sourceLocation),
        Marker(markerId: const MarkerId("cel"), position: coordsOfDestination)
      },
      polylines: {
        Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: const Color(0xFF334155),
            width: 5),
      },
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
    );
  }
}
