import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'dart:ui' as ui;

class PatchFind extends StatefulWidget {
  final LatLng coordsOfDestination;
  final LatLng sourceLocation;
  final Function handleCancel;
  const PatchFind(
      this.coordsOfDestination, this.sourceLocation, this.handleCancel,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PatchFindState(
        coordsOfDestination, sourceLocation, this.handleCancel);
  }
}

class _PatchFindState extends State<PatchFind> {
  final LatLng coordsOfDestination;
  final LatLng sourceLocation;
  final Function handleCancel;
  _PatchFindState(
      this.coordsOfDestination, this.sourceLocation, this.handleCancel);

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  LatLng? currentLocation;
  Timer? timer;
  // = BitmapDescriptor.defaultMarker;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? currentLocationIcon;
  BitmapDescriptor? sourceIcon;

  //function adds images from assets floder to BitmapDescriptor variables
  /*void setCustomMarkerIcon() {
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
  }*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> setCustomMarkerIcon() async {
    Uint8List destMarkerIcon =
        await getBytesFromAsset('assets/church.jpg', 100);
    Uint8List currMarkerIcon =
        await getBytesFromAsset('assets/person.jpg', 100);
    Uint8List sourMarkerIcon = await getBytesFromAsset('assets/start.png', 100);

    destinationIcon = BitmapDescriptor.fromBytes(destMarkerIcon);
    currentLocationIcon = BitmapDescriptor.fromBytes(currMarkerIcon);
    sourceIcon = BitmapDescriptor.fromBytes(sourMarkerIcon);
  }

  //function that saves route between coordinates in polylineCoordinates variable
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

  //function gets the current devices location and saves it in currentLocation <LatLng>, function is being invoked every second in initState()
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
  //to do: finish icons

  @override
  Widget build(BuildContext context) {
    return (currentLocation == null ||
            destinationIcon == null ||
            currentLocationIcon == null ||
            sourceIcon == null)
        ? const Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: 200, height: 200, child: CircularProgressIndicator()))
        : Column(children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 100,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: sourceLocation, zoom: 15),
                  markers: {
                    Marker(
                        markerId: const MarkerId("source"),
                        position: sourceLocation,
                        icon: sourceIcon!),
                    Marker(
                        markerId: const MarkerId("current location"),
                        position: currentLocation!,
                        icon: currentLocationIcon!),
                    Marker(
                        markerId: const MarkerId("destination"),
                        position: coordsOfDestination,
                        icon: destinationIcon!)
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
                )),
            Container(
                margin: const EdgeInsets.only(top: 15, right: 5, left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 180,
                        height: 60,
                        child: ElevatedButton(
                            onPressed: () => {handleCancel()},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF374151)),
                            child: Text('Anuluj',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20)))),
                    SizedBox(
                        width: 180,
                        height: 60,
                        child: ElevatedButton(
                            onPressed: () => {
                                  MapsLauncher.launchCoordinates(
                                      coordsOfDestination.latitude,
                                      coordsOfDestination.longitude)
                                },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF374151)),
                            child: Text('Google Maps',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20))))
                  ],
                ))
          ]);
  }
}
