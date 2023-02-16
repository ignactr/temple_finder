import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

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
  LatLng? currentLocation;
  Timer? timer;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/church.jpg")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/person.jpg")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/start.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
  }

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

  Future<void> getCurrentLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation =
          LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => getCurrentLocation());
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentLocation == null
        ? const Center(child: Text('Loading'))
        : GoogleMap(
            initialCameraPosition:
                CameraPosition(target: currentLocation!, zoom: 15),
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: currentLocation!,
                //icon: currentLocationIcon
              ),
              Marker(
                markerId: const MarkerId("sourceLocation"),
                position: sourceLocation,
                //icon: sourceIcon
              ),
              Marker(
                markerId: const MarkerId("destination"),
                position: coordsOfDestination,
                //icon: destinationIcon
              )
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
