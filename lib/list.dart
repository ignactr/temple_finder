import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'test_data.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'dart:math';

class PropListItem extends StatelessWidget {
  final String name;
  final Coordinates coords;
  final double distance;
  final String address;
  PropListItem(this.name, this.coords, this.distance, this.address);

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  String formattedAddress() {
    if (address.length > 50) {
      return address.substring(0, 51) + '...';
    } else {
      return address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: 'znajdź drogę do tego miejsca',
        child: Card(
            color: const Color(0xFFe5e7eb),
            shadowColor: const Color(0xFFe5e7eb),
            child: InkWell(
                onTap: () => {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontSize: 21)),
                      ),
                      Text('${roundDouble(distance, 1)} km',
                          style: const TextStyle(fontSize: 21)),
                    ]),
                    Text(formattedAddress(),
                        style: const TextStyle(fontSize: 15))
                  ]),
                ))));
  }
}

class PropList extends StatefulWidget {
  final Function enterPage;
  final CameraPosition devicesLocation;
  PropList(this.enterPage, this.devicesLocation);

  @override
  _PropList createState() => _PropList(enterPage, devicesLocation);
}

class _PropList extends State<PropList> {
  final Function enterPage;
  final CameraPosition devicesLocation;
  _PropList(this.enterPage, this.devicesLocation);

  List<List> listWithCoords = [];

  //function getDistance takes coordinates of two locations and returns distance between them in straight line (km)
  double getDistance(lat1, lon1, lat2, lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //function nameAndLocationList uses geocoder packages to turn adress from givenList to coordinates and then display them with names of locations in listToReturn
  Future<void> nameAndLocationList(
      List<List<String>> givenList, CameraPosition position2) async {
    List<List> listToReturn = [];
    await Future.forEach(
      givenList,
      (row) async {
        var query = row[1];
        var results = await Geocoder.local.findAddressesFromQuery(query);
        var firstResult = results.first;
        listToReturn.add([
          row[0],
          firstResult.coordinates,
          getDistance(
              firstResult.coordinates.latitude,
              firstResult.coordinates.longitude,
              position2.target.latitude,
              position2.target.longitude),
          row[1]
        ]);
      },
    );
    setState(() {
      listWithCoords = listToReturn;
    });
  }

  @override
  void initState() {
    super.initState();
    nameAndLocationList(templeList, devicesLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 20),
      PropListItem(listWithCoords[0][0], listWithCoords[0][1],
          listWithCoords[0][2], listWithCoords[0][3]),
      PropListItem(listWithCoords[1][0], listWithCoords[1][1],
          listWithCoords[1][2], listWithCoords[1][3]),
      PropListItem(listWithCoords[2][0], listWithCoords[2][1],
          listWithCoords[2][2], listWithCoords[2][3]),
      PropListItem(listWithCoords[3][0], listWithCoords[3][1],
          listWithCoords[3][2], listWithCoords[3][3]),
      Expanded(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () => {enterPage(0)},
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: const Color(0xFF374151)),
                  child: const Text(
                    'Powrót',
                    style: TextStyle(fontSize: 21),
                  ),
                ))),
      )
    ]);
  }
}
